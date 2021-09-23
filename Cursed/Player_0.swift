//
//  Player_0.swift
//  hi
//
//  Created by Tom Stoev on 9/11/21.
//

import SpriteKit

class Player_0: SKSpriteNode{
    var initialSize: CGSize = CGSize(width: 253, height: 171)
    var textureAtlas: SKTextureAtlas = SKTextureAtlas(named: "Player")
    var sprite_orientation = constants.orientation_right
    var movement_status = constants.idle
    var keep_moving = false
    var canAttack = true
    var giving_damage = false
    var owes_soul = false
    var is_alive = true
    
    var damage = Int(25)
    
    private var last_dir = constants.orientation_right
    private let max_velocity = CGFloat(450)
    private var lives = Int(100)
    private let hp_max = Int(1000)
    
    
    private var attack_field_shift = CGFloat(20)
    private var attack_field2_shift = CGFloat(67)
    private var attack_field3_shift = CGFloat(44)
    
//    private let attackField = SKSpriteNode(color: .clear, size: CGSize(width: 4, height: 4))
//    private let attackField2 = SKSpriteNode(color: .clear, size: CGSize(width: 4, height: 4))
//    private let attackField3 = SKSpriteNode(color: .clear, size: CGSize(width: 4, height: 4))
    
    // HeroKnight_Attack1_0
    init() {
        super.init(texture: textureAtlas.textureNamed("player0_idle000"), color: .clear, size: initialSize)
        self.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: 30, height: 74), center: CGPoint(x: 6, y: -34))
        self.name = "player_0"
        self.physicsBody?.restitution = 0
        self.physicsBody?.friction = 0.9
        self.physicsBody?.allowsRotation = false
        self.physicsBody?.linearDamping = 0
        self.physicsBody?.angularDamping = 0
        self.physicsBody?.angularVelocity = 0
        self.zPosition = 15
        self.alpha = 1
        self.physicsBody?.categoryBitMask = physicsCategory.player.rawValue
        self.physicsBody?.collisionBitMask = physicsCategory.ground.rawValue
        self.physicsBody?.contactTestBitMask = 0
        idleAnimation()
        
        
//                attackField.physicsBody = SKPhysicsBody(circleOfRadius: CGFloat(27), center: CGPoint(x: self.position.x + attack_field_shift, y: self.position.y - 9))
//                attackField.physicsBody?.affectedByGravity = false
//                attackField.physicsBody?.categoryBitMask = physicsCategory.attack.rawValue
//                attackField.physicsBody?.collisionBitMask = 0
//                attackField.physicsBody?.contactTestBitMask = 0
//                attackField.physicsBody?.isDynamic = false
//                attackField2.physicsBody = SKPhysicsBody(circleOfRadius: CGFloat(16), center: CGPoint(x: self.position.x + attack_field2_shift, y:  self.position.y - 10))
//                attackField2.physicsBody?.affectedByGravity = false
//                attackField2.physicsBody?.isDynamic = false
//                attackField2.physicsBody?.categoryBitMask = physicsCategory.attack.rawValue
//                attackField2.physicsBody?.collisionBitMask = 0
//                attackField2.physicsBody?.contactTestBitMask = 0
//
//                attackField3.physicsBody = SKPhysicsBody(circleOfRadius: CGFloat(24), center: CGPoint(x: self.position.x +                           attack_field3_shift, y: self.position.y - 9))
//                attackField3.physicsBody?.affectedByGravity = false
//                attackField3.physicsBody?.categoryBitMask = physicsCategory.attack.rawValue
//                attackField3.physicsBody?.collisionBitMask = 0
//                attackField3.physicsBody?.contactTestBitMask = 0
//                attackField3.physicsBody?.isDynamic = false
//
//
//                self.addChild(attackField)
//                self.addChild(attackField2)
//                self.addChild(attackField3)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        fatalError("init(coder:) has not been implemented")
    }
    
    func lastDirection(orientation: Int){
        last_dir = orientation
    }
    func getLives()->Int{
        return self.lives
    }
    
    func setMoving(){
        keep_moving = true
    }
    
    func setStill(){
        keep_moving = false
    }
    
    func setAttack(){
        movement_status = constants.attacking
    }
    
    func getDamage()-> Int{
        return damage
    }
    
    func getOrientation()->Int{
        return sprite_orientation
    }
    
    func setLives(health: Int){
        lives = health
    }
    
    func regen(health: Int){
        lives += health
        if lives > hp_max {
            lives = hp_max
        }
    }
    
    
    func move() {
        
        if sprite_orientation == constants.orientation_right {
            if self.physicsBody?.velocity.dx ?? 0 < CGFloat(75) {
                self.physicsBody?.applyImpulse(CGVector(dx: 4, dy: 0))
                return
            }
            self.physicsBody?.applyImpulse(CGVector(dx: 1, dy: 0))
        } else {
            if self.physicsBody?.velocity.dx ?? 0 > CGFloat(-75) {
                self.physicsBody?.applyImpulse(CGVector(dx: -4, dy: 0))
                return
            }
            self.physicsBody?.applyImpulse(CGVector(dx: -1, dy: 0))
        }
    }
    
    func takeDamage(dmg: Int) -> Bool{
        if self.physicsBody?.categoryBitMask == physicsCategory.player.rawValue {
            self.physicsBody?.categoryBitMask = physicsCategory.hurtPlayer.rawValue
            self.lives-=dmg
            if(self.lives <= 0){
                is_alive = false
                if let gameScene = self.parent as? GameScene {
                    gameScene.outOfLives()
                    // update lives
                }
                
                self.deathAnimation()
            } else {
            self.damageAnimation()
            return true
            }
        }
        return false
    }
    
    func transform(){
        idleAnimation2()
    }
    
    func update(){
//       // determine orientation
        if(self.physicsBody!.velocity.dx < 0 && last_dir == constants.orientation_right
        || self.physicsBody!.velocity.dx > 0 && last_dir == constants.orientation_left){
            self.physicsBody!.velocity = CGVector(dx: 0, dy: self.physicsBody!.velocity.dy)
        }
        
        if(last_dir == constants.orientation_left && sprite_orientation == constants.orientation_right){
            self.run(SKAction.scaleX(to: -1, duration: 0))
            sprite_orientation = constants.orientation_left
        } else if(last_dir == constants.orientation_right && sprite_orientation != constants.orientation_right){
            self.run(SKAction.scaleX(to: 1, duration: 0))
            sprite_orientation = constants.orientation_right
        }
        
        if keep_moving {
            move()
        }
        
        // cap speed at max
        if(self.physicsBody!.velocity.dx > max_velocity) {self.physicsBody!.velocity.dx = max_velocity}
        if(self.physicsBody!.velocity.dx < -max_velocity) {self.physicsBody!.velocity.dx = -max_velocity}
        
        
        
        // determine correct animation
        // PRIORITY (decreasing): attack, jump, run, idle
        if movement_status == constants.attacking {
            if canAttack {
            self.removeAction(forKey: "jump")
            self.removeAction(forKey: "idle")
            self.removeAction(forKey: "run")
            self.removeAction(forKey: "fall")
            canAttack = false
            attackAnimation()
            }
        }
        else if(self.physicsBody!.velocity.dy != 0){
            if(movement_status != constants.jumping && self.physicsBody!.velocity.dy > 0){
                self.removeAction(forKey: "idle")
                self.removeAction(forKey: "run")
                self.removeAction(forKey: "fall")
                movement_status = constants.jumping
            jumpAnimation()
            } else if self.physicsBody!.velocity.dy < 0 && movement_status != constants.falling{
                movement_status = constants.falling
                self.removeAction(forKey: "jump")
                fallAnimation()
            }
        }
        else if(self.physicsBody!.velocity.dx != 0){
            // additional code to determine other animations
            if(movement_status != constants.is_running){
                self.removeAction(forKey: "idle")
                self.removeAction(forKey: "fall")
                runAnimation()
                movement_status = constants.is_running
            }
            
        } else {
            if(movement_status != constants.idle){
                self.removeAction(forKey: "fall")
                idleAnimation()
                movement_status = constants.idle
                self.physicsBody!.velocity = CGVector(dx: 0, dy: 0)
            }
        }
    }
    
    // ANIMATIONS
    // HeroKnight_Idle_0
    
    func idleAnimation2(){
        let idleFrames:[SKTexture] = [SKTextureAtlas(named: "Player2").textureNamed("player_idle000"),
                                      SKTextureAtlas(named: "Player2").textureNamed("player_idle001"),
                                      SKTextureAtlas(named: "Player2").textureNamed("player_idle002"),
                                      SKTextureAtlas(named: "Player2").textureNamed("player_idle003"),
                                      SKTextureAtlas(named: "Player2").textureNamed("player_idle004"),
                                      SKTextureAtlas(named: "Player2").textureNamed("player_idle005"),
                                      SKTextureAtlas(named: "Player2").textureNamed("player_idle006"),
                                      SKTextureAtlas(named: "Player2").textureNamed("player_idle007"),
                                      SKTextureAtlas(named: "Player2").textureNamed("player_idle008"),
                                      SKTextureAtlas(named: "Player2").textureNamed("player_idle009")]
        let waiveAction = SKAction.animate(with: idleFrames, timePerFrame: 0.15)
        self.run(SKAction.repeatForever(waiveAction), withKey: "idle")
        
        
    }
    func idleAnimation(){
       let idleFrames:[SKTexture]=[textureAtlas.textureNamed("player0_idle000"),
                                   textureAtlas.textureNamed("player0_idle001"),
                                   textureAtlas.textureNamed("player0_idle002"),
                                   textureAtlas.textureNamed("player0_idle003"),
                                   textureAtlas.textureNamed("player0_idle004"),
                                   textureAtlas.textureNamed("player0_idle005"),
                                   textureAtlas.textureNamed("player0_idle006"),
                                   textureAtlas.textureNamed("player0_idle007")]
        let waiveAction = SKAction.animate(with: idleFrames, timePerFrame: 0.15)
        self.run(SKAction.repeatForever(waiveAction), withKey: "idle")
    }
 // HeroKnight_Attack1_0
    func runAnimation(){
       let playerFrames:[SKTexture]=[textureAtlas.textureNamed("player0_run000"),
                                     textureAtlas.textureNamed("player0_run001"),
                                     textureAtlas.textureNamed("player0_run002"),
                                     textureAtlas.textureNamed("player0_run003"),
                                     textureAtlas.textureNamed("player0_run004"),
                                     textureAtlas.textureNamed("player0_run005"),
                                     textureAtlas.textureNamed("player0_run006"),
                                     textureAtlas.textureNamed("player0_run007")]
        let runAction = SKAction.animate(with: playerFrames, timePerFrame: 0.1)
        self.run(SKAction.repeatForever(runAction), withKey: "run")
    }

    func jumpAnimation(){
     let playerFrames:[SKTexture] = [textureAtlas.textureNamed("player0_jump000"),
                                     textureAtlas.textureNamed("player0_jump001")]
        let jumpAction = SKAction.animate(with: playerFrames, timePerFrame: 0.1)
        self.run(jumpAction, withKey: "jump")
    }
    
    func fallAnimation(){
        let playerFrames:[SKTexture] = [textureAtlas.textureNamed("player0_fall000"),
                                        textureAtlas.textureNamed("player0_fall001")]
           let fallAction = SKAction.animate(with: playerFrames, timePerFrame: 0.1)
        self.run(SKAction.repeatForever(fallAction), withKey: "fall")
    }
    // HeroKnight_Attack1_0
    func attackAnimation(){
        let playerFrames:[SKTexture] = [textureAtlas.textureNamed("player0_attack000"),
                                        textureAtlas.textureNamed("player0_attack001")]
        let playerFrames2:[SKTexture] = [
                                        textureAtlas.textureNamed("player0_attack002"),
                                        textureAtlas.textureNamed("player0_attack003")]
        
        let attackAction = SKAction.animate(with: playerFrames, timePerFrame: 0.07)
        let attackAction2 = SKAction.animate(with: playerFrames2, timePerFrame: 0.07)
        let damageSet = SKAction.run { [weak self] in
            self?.giving_damage = true
        }
        let reset = SKAction.run { [weak self] in
            self?.canAttack = true
            self?.movement_status = constants.finished_attack
            self?.giving_damage = false
        }
        self.run(SKAction.sequence([attackAction, damageSet, attackAction2, reset]), withKey: "attack")
    }
    
    func damageAnimation(){
        let reset = SKAction.run { [weak self] in
            self?.physicsBody?.categoryBitMask = physicsCategory.player.rawValue
        }
        let damageEnd = (SKAction.fadeIn(withDuration: 0.15))
        let damageStart = (SKAction.fadeOut(withDuration: 0.15))
        let flashAnimate = SKAction.repeat(SKAction.sequence([damageStart, damageEnd]), count: 3)
        let damaged = SKAction.sequence([flashAnimate, reset])
        self.run(damaged)
    }
    
    func deathAnimation(){
        self.removeAction(forKey: "run")
        self.removeAction(forKey: "jump")
        self.removeAction(forKey: "fall")
        self.removeAction(forKey: "idle")
        let playerFrames:[SKTexture]=[textureAtlas.textureNamed("player0_death001"),
                                      textureAtlas.textureNamed("player0_death002"),
                                      textureAtlas.textureNamed("player0_death003"),
                                      textureAtlas.textureNamed("player0_death004"),
                                      textureAtlas.textureNamed("player0_death005")]
        let deathAction = SKAction.animate(with: playerFrames, timePerFrame: 0.12)
        self.run(deathAction, withKey: "death")
    }

    
    func checkOverlap(R: CGFloat, Xc: CGFloat, Yc: CGFloat,
                      X1: CGFloat, Y1: CGFloat,
                      X2: CGFloat, Y2: CGFloat) -> Bool
    {
        let Xn = max(X1, min(Xc, X2));
        let Yn = max(Y1, min(Yc, Y2));
        let Dx = Xn - Xc;
        let Dy = Yn - Yc;
        return (Dx * Dx + Dy * Dy) <= R * R;
    }
    
    func circleCollision(c1x: CGFloat, c1y: CGFloat, c1r: CGFloat, c2x: CGFloat, c2y: CGFloat, c2r: CGFloat)->Bool{

      let distX = c1x - c2x;
      let distY = c1y - c2y;
      let distance = sqrt( (distX*distX) + (distY*distY) );
        
      if (distance <= c1r+c2r) {
        return true;
      }
      return false;
    }
    
    /*
     func shouldGiveDamage()->Bool{
         return self.giving_damage
     }
     */
    func shouldGiveDamage(location: CGPoint, type: Int) -> Bool {
        if !giving_damage {
            return false
        }
        var w = 0
        var h = 0
        switch(type){
        case constants.wizard:
            w = constants.wizard_width
            h = constants.wizard_height
            break
        case constants.wizard2:
            w = constants.wizard2_width
            h = constants.wizard2_height
            break
        case constants.samurai:
            w = constants.samurai_width
            h = constants.samurai_height
            break
        case constants.eye:
            return circleCollision(c1x: self.position.x + CGFloat(sprite_orientation) * attack_field_shift, c1y: self.position.y - CGFloat(9), c1r: CGFloat(27), c2x: location.x, c2y: location.y, c2r: CGFloat(constants.eye_radius)) ||
                circleCollision(c1x: self.position.x + CGFloat(sprite_orientation) * attack_field2_shift, c1y: self.position.y - CGFloat(10), c1r: CGFloat(16), c2x: location.x, c2y: location.y, c2r: CGFloat(constants.eye_radius)) ||
                circleCollision(c1x: self.position.x + CGFloat(sprite_orientation) * attack_field3_shift, c1y: self.position.y - CGFloat(9), c1r: CGFloat(24), c2x: location.x, c2y: location.y, c2r: CGFloat(constants.eye_radius))

        case constants.mushroom:
            w = constants.mushroom_width
            h = constants.mushroom_height
            break
        case constants.santa:
            w = constants.santa_width
            h = constants.santa_height
            break
        case constants.malphas:
            w = constants.malphas_width
            h = constants.malphas_height
            break
        default:
            break
        }
        let x1 = location.x - CGFloat(w/2)
        let y1 = location.y - CGFloat(h/2)
        let x2 = location.x + CGFloat(w/2)
        let y2 = location.y + CGFloat(h/2)
        
        
        /* attackField.physicsBody = SKPhysicsBody(circleOfRadius: CGFloat(27), center: CGPoint(x: self.position.x + attack_field_shift, y: self.position.y - 9))*/
        /*attackField2.physicsBody = SKPhysicsBody(circleOfRadius: CGFloat(16), center: CGPoint(x: self.position.x + attack_field2_shift, y:  self.position.y - 10))*/
        /* attackField3.physicsBody = SKPhysicsBody(circleOfRadius: CGFloat(24), center: CGPoint(x: self.position.x +                           attack_field3_shift, y: self.position.y - 9)) */
        return checkOverlap(R: 27, Xc: self.position.x + CGFloat(sprite_orientation) * attack_field_shift, Yc: self.position.y - CGFloat(9), X1: x1, Y1: y1, X2: x2, Y2: y2) ||
        checkOverlap(R: CGFloat(16), Xc: self.position.x + CGFloat(sprite_orientation) * attack_field2_shift, Yc: self.position.y - CGFloat(10), X1: x1, Y1: y1, X2: x2, Y2: y2) ||
            checkOverlap(R: CGFloat(24), Xc: self.position.x + CGFloat(sprite_orientation) * attack_field3_shift, Yc: self.position.y - CGFloat(9), X1: x1, Y1: y1, X2: x2, Y2: y2)
    }
    
}

