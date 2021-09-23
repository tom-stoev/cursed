//
//  Malphas.swift
//  hi
//
//  Created by Tom Stoev on 9/4/21.
//

import SpriteKit

class Malphas: SKSpriteNode, Entity {
    private var initialSize: CGSize = CGSize(width: 180, height: 180)
    private var textureAtlas: SKTextureAtlas = SKTextureAtlas(named: "Malphas")
    private var sprite_orientation = constants.orientation_left
    private var movement_status = constants.initial
    private let max_velocity = CGFloat(200)
    
    private var can_take_damage = true
    private var on_final_life = false
    private var do_nothing = false
    private var decline_dying = SKLabelNode()
    private var hp = CGFloat(300)
    private let hp_max = CGFloat(300)
    private let dmg = Int(21) // 21
    private let orb_dmg = Int(15) // 15
    private var is_alive = true
    private var giving_damage = false
    private var can_attack = [0]
    private var b = 0 // tally # of orbs that are colliding with player
    
    private var attack_field_shift = CGFloat(20)
    private var attack_field2_shift = CGFloat(30)
    
    private var should_update_orbs = false
    private var orb1 = SKShapeNode(circleOfRadius: 13)
    private var orb2 = SKShapeNode(circleOfRadius: 13)
    private var orb3 = SKShapeNode(circleOfRadius: 13)
    private var orb4 = SKShapeNode(circleOfRadius: 13)
    private var orb5 = SKShapeNode(circleOfRadius: 13)
    private var orb6 = SKShapeNode(circleOfRadius: 13)
    
    private let hpBar = SKSpriteNode(color: .green, size: CGSize(width: CGFloat(30), height: CGFloat(5)))
    private let dmgTicker = SKLabelNode(fontNamed: "AppleSDGothicNeo-Bold")

    init() {
        super.init(texture: nil, color: .clear, size:initialSize)
        self.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: 50, height: 54), center: CGPoint(x:self.position.x + 8, y: self.position.y - 20))
        self.name = "update_malphas"
        self.physicsBody?.linearDamping = 0
        self.physicsBody?.restitution = 0
        self.physicsBody?.angularDamping = 0
        self.physicsBody?.angularVelocity = 0
        self.physicsBody?.friction = 0.3
        self.physicsBody?.allowsRotation = false
        self.zPosition = 8
        self.physicsBody?.affectedByGravity = true
        self.physicsBody?.categoryBitMask = physicsCategory.enemy.rawValue
        self.physicsBody?.collisionBitMask = physicsCategory.ground.rawValue
        self.physicsBody?.contactTestBitMask = 0
        
        self.run(SKAction.scaleX(to: -1, duration: 0))
        //idleAnimation()
        
        addIndicators()
        initOrbs()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func addIndicators() {
        self.addChild(hpBar)
        hpBar.name = "hp_bar"
        hpBar.zPosition = 9
        hpBar.position = CGPoint(x: self.position.x, y: self.position.y + CGFloat(20))
        
        dmgTicker.text = ""
        dmgTicker.alpha = 1
        dmgTicker.zPosition = 9
        dmgTicker.position = CGPoint(x: self.position.x+35, y: self.position.y + CGFloat(35))
        dmgTicker.fontColor = .red
        dmgTicker.fontSize = 23
        self.addChild(dmgTicker)
    }
    
    func initOrbs() {
        orb1.physicsBody = SKPhysicsBody(circleOfRadius: CGFloat(13), center: self.position)
        orb1.physicsBody?.affectedByGravity = false
        orb1.physicsBody?.collisionBitMask = 0
        orb1.physicsBody?.contactTestBitMask = 0
        orb1.physicsBody?.categoryBitMask = physicsCategory.attack.rawValue
        orb1.fillColor = .white
        orb1.position = self.position
        orb1.name = "orb"
        
        orb2.physicsBody = SKPhysicsBody(circleOfRadius: CGFloat(13), center: self.position)
        orb2.physicsBody?.affectedByGravity = false
        orb2.physicsBody?.collisionBitMask = 0
        orb2.physicsBody?.contactTestBitMask = 0
        orb2.physicsBody?.categoryBitMask = physicsCategory.attack.rawValue
        orb2.fillColor = .white
        orb2.position = self.position
        orb2.name = "orb"
        
        orb3.physicsBody = SKPhysicsBody(circleOfRadius: CGFloat(13), center: self.position)
        orb3.physicsBody?.affectedByGravity = false
        orb3.physicsBody?.collisionBitMask = 0
        orb3.physicsBody?.contactTestBitMask = 0
        orb3.physicsBody?.categoryBitMask = physicsCategory.attack.rawValue
        orb3.fillColor = .white
        orb3.position = self.position
        orb3.name = "orb"
        
        orb4.physicsBody = SKPhysicsBody(circleOfRadius: CGFloat(13), center: self.position)
        orb4.physicsBody?.affectedByGravity = false
        orb4.physicsBody?.collisionBitMask = 0
        orb4.physicsBody?.contactTestBitMask = 0
        orb4.physicsBody?.categoryBitMask = physicsCategory.attack.rawValue
        // rgba(16,134,126,255)
        orb4.fillColor = .white
        orb4.position = self.position
        orb4.name = "orb"
        
        orb5.physicsBody = SKPhysicsBody(circleOfRadius: CGFloat(13), center: self.position)
        orb5.physicsBody?.affectedByGravity = false
        orb5.physicsBody?.collisionBitMask = 0
        orb5.physicsBody?.contactTestBitMask = 0
        orb5.physicsBody?.categoryBitMask = physicsCategory.attack.rawValue
        orb5.fillColor = .white
        orb5.position = self.position
        orb5.name = "orb"
        
        orb6.physicsBody = SKPhysicsBody(circleOfRadius: CGFloat(13), center: self.position)
        orb6.physicsBody?.affectedByGravity = false
        orb6.physicsBody?.collisionBitMask = 0
        orb6.physicsBody?.contactTestBitMask = 0
        orb6.physicsBody?.categoryBitMask = physicsCategory.attack.rawValue
        orb6.fillColor = .white
        orb6.position = self.position
        orb6.name = "orb"
    }
    
    
    func resetVulnerability(){
        self.can_take_damage = true
        dmgTicker.text = " "
        let unfade = SKAction.fadeIn(withDuration: 1)
        dmgTicker.run(unfade)
    }
    
    func isVulnerable()->Bool{
        return can_take_damage
    }
    
    
    func getDamage()->Int{
        if should_update_orbs {
            return b * orb_dmg
        }
        return dmg
    }
    
    func orbAttack() {
        
        let kneelFrames:[SKTexture] =
            [textureAtlas.textureNamed("malphas_explosion092"),
             textureAtlas.textureNamed("malphas_explosion093"),
             textureAtlas.textureNamed("malphas_explosion094"),
             textureAtlas.textureNamed("malphas_explosion095"),
             textureAtlas.textureNamed("malphas_explosion096"),
             textureAtlas.textureNamed("malphas_explosion097")]
        let kneelSummon = SKAction.animate(with: kneelFrames, timePerFrame: 0.12)
        
        let spawn = SKAction.run { [weak self] in
            self?.spawnOrbs()
        }
        
        var revOrbFrames = kneelFrames
        revOrbFrames.reverse()
        let standUp = SKAction.animate(with: revOrbFrames, timePerFrame: 0.12)
        let done = SKAction.run { [weak self] in
            self?.movement_status = constants.finished_attack
            self?.should_update_orbs = false
            self?.removeOrbs()
            self?.can_attack[0] = 2
        }
        self.run(SKAction.sequence([kneelSummon, spawn, SKAction.wait(forDuration: 0.4), standUp, done]), withKey: "orb")
        
    }
    
    func removeOrbs(){
        for i in self.parent?.children ?? []{
            if i.name == "orb" {
                i.removeFromParent()
            }
        }
    }
    
    func spawnOrbs(){
        orb1.position = self.position
        orb2.position = self.position
        orb3.position = self.position
        orb4.position = self.position
        orb5.position = self.position
        orb6.position = self.position
        self.parent?.addChild(orb1)
        self.parent?.addChild(orb2)
        self.parent?.addChild(orb3)
        self.parent?.addChild(orb4)
        self.parent?.addChild(orb5)
        self.parent?.addChild(orb6)
        should_update_orbs = true
    }
    
    func updateOrbs() {
        orb1.physicsBody?.velocity = CGVector(dx: 190, dy: 110)
        orb2.physicsBody?.velocity = CGVector(dx: 220, dy: 0)
        orb3.physicsBody?.velocity = CGVector(dx: 110, dy: 190)
        orb4.physicsBody?.velocity = CGVector(dx: -190, dy: 110)
        orb5.physicsBody?.velocity = CGVector(dx: -220, dy: 0)
        orb6.physicsBody?.velocity = CGVector(dx: -110, dy: 190)
    }
    
    func spawn(){
        let kneelFrames:[SKTexture] =
            [textureAtlas.textureNamed("malphas_explosion092"),
             textureAtlas.textureNamed("malphas_explosion093"),
             textureAtlas.textureNamed("malphas_explosion094"),
             textureAtlas.textureNamed("malphas_explosion095"),
             textureAtlas.textureNamed("malphas_explosion096"),
             textureAtlas.textureNamed("malphas_explosion097")]
        let kneelSummon = SKAction.animate(with: kneelFrames, timePerFrame: 0.12)
        let summon = SKAction.run { [weak self] in
            if let gameScene = self?.parent?.parent as? GameScene {
                let selector = Int.random(in: 1...20)
                if selector < 14 {
                    gameScene.spawnWizard(pos: self?.position ?? CGPoint())
                } else if selector < 19 {
                    gameScene.spawnWizard2(pos: self?.position ?? CGPoint())
                } else {
                    gameScene.spawnSamurai(pos: self?.position ?? CGPoint())
                }
                
            }
        }
        var revOrbFrames = kneelFrames
        revOrbFrames.reverse()
        let standUp = SKAction.animate(with: revOrbFrames, timePerFrame: 0.12)
        
        let end = SKAction.run { [weak self] in
            self?.movement_status = constants.finished_attack
            self?.can_attack[0] = 3
        }
        
        self.run(SKAction.sequence([kneelSummon, summon, standUp, end]))
    }
    
    func update(pos: CGPoint, status: Bool, orientation: Int, damage: Int){
        if !is_alive{ // dont need to do anything if out of view
            return
        }
        
        if should_update_orbs {
            updateOrbs()
        }
        // check if needs to take damage
        if status && can_take_damage{
            self.takeDamage(dmg: damage)
            self.can_take_damage = false
        }
        
        // orientation update
        
        if movement_status != constants.attacking && can_take_damage{ // investigate this can_take_damage
            if(sprite_orientation == constants.orientation_left && pos.x > self.position.x){
                sprite_orientation = constants.orientation_right
                self.run(SKAction.scaleX(to: 1, duration: 0))
            } else if(sprite_orientation == constants.orientation_right && pos.x < self.position.x){
                sprite_orientation = constants.orientation_left
                self.run(SKAction.scaleX(to: -1, duration: 0))
            }
        }
        
        // cap velocity
        if(self.physicsBody!.velocity.dx > max_velocity) {self.physicsBody!.velocity.dx = max_velocity}
        if(self.physicsBody!.velocity.dx < -max_velocity) {self.physicsBody!.velocity.dx = -max_velocity}
        
        // select animation
            switch (can_attack[0]){
                case -1: // vulnerable phase -> blink
                    if !do_nothing {
                        doNothing()
                        do_nothing = true
                    }
                    break
                case 0: // slice attack
                    if movement_status != constants.attacking && abs(self.position.x - pos.x) <= 115 && abs(self.position.y - pos.y) <= 60{
                        self.removeAction(forKey: "idle")
                        self.removeAction(forKey: "run")
                        self.physicsBody?.applyImpulse(CGVector(dx: sprite_orientation * 3, dy: 0))
                        
                        movement_status = constants.attacking
                        attackAnimation2(nextAttack: 1)
                    }
//                    else if abs(self.position.x - pos.x) > 350{
//                        //self.physicsBody?.applyImpulse(CGVector(dx: sprite_orientation * 11, dy: 0))
//                        can_attack[0] = 2
//                    }
                    break
                case 1: // orbs everywhere
                    if !should_update_orbs && movement_status != constants.attacking {
                        self.removeAction(forKey: "idle")
                        self.removeAction(forKey: "run")
                        self.physicsBody?.velocity.dx = 0
                        movement_status = constants.attacking
                        orbAttack()
                        //should_update_orbs = true
                    }
                    break
                case 2: // spawn enemy
//                    let rollDice = Int.random(in: 0...4)
//                    if rollDice == 0 {
                        if movement_status != constants.attacking {
                            self.removeAction(forKey: "idle")
                            self.removeAction(forKey: "run")
                            movement_status = constants.attacking
                            spawn()
                        }
//                    } else {
//                        can_attack[0] = 3
//                    }
                    break
                case 3: // repeat case 1 but go to case -1 after
                    if movement_status != constants.attacking && abs(self.position.x - pos.x) <= 115 && abs(self.position.y - pos.y) <= 60{
                        self.removeAction(forKey: "idle")
                        self.removeAction(forKey: "run")
                        self.physicsBody?.applyImpulse(CGVector(dx: sprite_orientation * 3, dy: 0))
                        
                        movement_status = constants.attacking
                        attackAnimation2(nextAttack: -1)
                    }
                    break
                default:
                    break
            }
        // chase player
        
        if movement_status != constants.attacking{ // prioritize attack animations
            // if can chase player, chase
            if abs(pos.x - self.position.x) > 80 && !do_nothing{
                self.physicsBody?.applyImpulse(CGVector(dx: sprite_orientation * 11, dy: 0))
            }

            if self.physicsBody?.velocity.dx != 0 {
                self.removeAction(forKey: "idle")
                //self.removeAction(forKey: "attack")
                if movement_status != constants.is_running {
                    runAnimation()
                    movement_status = constants.is_running
                }
            } else {
                self.removeAction(forKey: "run")
                //self.removeAction(forKey: "attack")
                if movement_status != constants.idle {
                    idleAnimation()
                    movement_status = constants.idle
                }
            }
        }
        
    }

    func doNothing() {
        let blink = SKAction.repeat(SKAction.sequence([SKAction.fadeOut(withDuration: 0.15), SKAction.fadeIn(withDuration: 0.15)]), count: 8)
        let next = SKAction.run { [weak self] in
            self?.can_attack[0] = 0
            self?.do_nothing = false
        }
        self.run(SKAction.sequence([blink, next]))
    }
    
    func idleAnimation(){
        let idleFrames:[SKTexture] =
            [textureAtlas.textureNamed("malphas_idle000"),
             textureAtlas.textureNamed("malphas_idle001"),
             textureAtlas.textureNamed("malphas_idle002"),
             textureAtlas.textureNamed("malphas_idle003"),
             textureAtlas.textureNamed("malphas_idle004"),
             textureAtlas.textureNamed("malphas_idle005"),
             textureAtlas.textureNamed("malphas_idle006"),
             textureAtlas.textureNamed("malphas_idle007")]
        let idleAction = SKAction.animate(with: idleFrames,
                                         timePerFrame: 0.15)
        let second = SKAction.repeatForever(idleAction)
        self.run((second), withKey: "idle")
        //self.run(SKAction.repeatForever(idleAction), withKey: "idle")
    }
    
    func runAnimation() {
        let runFrames:[SKTexture] =
            [
              textureAtlas.textureNamed("malphas_run023"),
              textureAtlas.textureNamed("malphas_run024"),
              textureAtlas.textureNamed("malphas_run025"),
              textureAtlas.textureNamed("malphas_run026"),
              textureAtlas.textureNamed("malphas_run027"),
              textureAtlas.textureNamed("malphas_run028")]
        let runAction = SKAction.animate(with: runFrames, timePerFrame: 0.1)
        let beforeReset = SKAction.repeat(runAction, count: 2)
        let first = SKAction.sequence([beforeReset])
        
        let run2Action = SKAction.animate(with: runFrames, timePerFrame: 0.09)
        
        let running = SKAction.sequence([first, SKAction.repeatForever(run2Action)])
        self.run(running, withKey: "run")
    }
    
    func attackAnimation(){
        
    }
    
    func attackAnimation2(nextAttack: Int){
        let attackFrames:[SKTexture] =
            [textureAtlas.textureNamed("malphas_attack046"),
             textureAtlas.textureNamed("malphas_attack047"),
             textureAtlas.textureNamed("malphas_attack048"),
             textureAtlas.textureNamed("malphas_attack049"),
             textureAtlas.textureNamed("malphas_attack050"),
             textureAtlas.textureNamed("malphas_attack051"),
             textureAtlas.textureNamed("malphas_attack052"),
             textureAtlas.textureNamed("malphas_attack053"),
             textureAtlas.textureNamed("malphas_attack054")]
    let attackFrames2:[SKTexture] = [
             textureAtlas.textureNamed("malphas_attack055"),
             textureAtlas.textureNamed("malphas_attack056")]
        let attackAction = SKAction.animate(with: attackFrames, timePerFrame: 0.032)
        let attack2Action = SKAction.animate(with: attackFrames2, timePerFrame: 0.1)
        let damageSet = SKAction.run { [weak self] in
            self?.giving_damage = true
        }
        
        let reset = SKAction.run { [weak self] in
            self?.movement_status = constants.finished_attack
            self?.giving_damage = false
            self?.can_attack[0] = nextAttack
        }
        // after attack is finished, go to idle animation for a while
        self.run(SKAction.sequence([attackAction, damageSet, attack2Action, reset]), withKey: "attack")
    }
    
    func deathAnimation(){
        self.giving_damage = false
        self.removeAllActions()
        self.run(SKAction.fadeIn(withDuration: 0))
        let deathFrames:[SKTexture] =
            [textureAtlas.textureNamed("malphas_explosion092"),
             textureAtlas.textureNamed("malphas_explosion093"),
             textureAtlas.textureNamed("malphas_explosion094"),
             textureAtlas.textureNamed("malphas_explosion095"),
             textureAtlas.textureNamed("malphas_explosion096"),
             textureAtlas.textureNamed("malphas_explosion097"),
             textureAtlas.textureNamed("malphas_explosion098"),
             textureAtlas.textureNamed("malphas_explosion099"),
             textureAtlas.textureNamed("malphas_explosion100"),
             textureAtlas.textureNamed("malphas_explosion101"),
             textureAtlas.textureNamed("malphas_explosion102"),
             textureAtlas.textureNamed("malphas_explosion103"),
             textureAtlas.textureNamed("malphas_explosion104"),
             textureAtlas.textureNamed("malphas_explosion105"),
             textureAtlas.textureNamed("malphas_explosion106"),
             textureAtlas.textureNamed("malphas_explosion107"),
             textureAtlas.textureNamed("malphas_explosion108"),
             textureAtlas.textureNamed("malphas_explosion109"),
             textureAtlas.textureNamed("malphas_explosion110"),
             textureAtlas.textureNamed("malphas_explosion111"),
             textureAtlas.textureNamed("malphas_explosion112"),
             textureAtlas.textureNamed("malphas_explosion113"),
             textureAtlas.textureNamed("malphas_explosion114")]
        let death = SKAction.animate(with: deathFrames, timePerFrame: 0.1)
        let remove = SKAction.run { [weak self] in
            self?.removeAllChildren()
            self?.removeFromParent()
        }
        // after attack is finished, go to idle animation for a while
        self.run(SKAction.sequence([death, remove]), withKey: "death")
    }
    
    func revivalAnimation(){
        self.giving_damage = false
        self.removeAction(forKey: "idle")
        self.removeAction(forKey: "attack")
        self.removeAction(forKey: "run")
        self.run(SKAction.fadeIn(withDuration: 0))
        let deathFrames:[SKTexture] =
            [textureAtlas.textureNamed("malphas_explosion092"),
             textureAtlas.textureNamed("malphas_explosion093"),
             textureAtlas.textureNamed("malphas_explosion094"),
             textureAtlas.textureNamed("malphas_explosion095"),
             textureAtlas.textureNamed("malphas_explosion096"),
             textureAtlas.textureNamed("malphas_explosion097"),
             textureAtlas.textureNamed("malphas_explosion098"),
             textureAtlas.textureNamed("malphas_explosion099"),
             textureAtlas.textureNamed("malphas_explosion100"),
             textureAtlas.textureNamed("malphas_explosion101"),
             textureAtlas.textureNamed("malphas_explosion102"),
             textureAtlas.textureNamed("malphas_explosion103"),
             textureAtlas.textureNamed("malphas_explosion104"),
             textureAtlas.textureNamed("malphas_explosion105"),
             textureAtlas.textureNamed("malphas_explosion106"),
             textureAtlas.textureNamed("malphas_explosion107"),
             textureAtlas.textureNamed("malphas_explosion108"),
             textureAtlas.textureNamed("malphas_explosion109"),
             textureAtlas.textureNamed("malphas_explosion110"),
             textureAtlas.textureNamed("malphas_explosion111"),
             textureAtlas.textureNamed("malphas_explosion112"),
             textureAtlas.textureNamed("malphas_explosion113"),
             textureAtlas.textureNamed("malphas_explosion114")]
        let death = SKAction.animate(with: deathFrames, timePerFrame: 0.1)
        var reviveFrames = deathFrames
        reviveFrames.reverse()
        let revive = SKAction.animate(with: reviveFrames, timePerFrame: 0.1)
        
        
        decline_dying = SKLabelNode(fontNamed: "Chalkduster")
        decline_dying.text = "Malphas resisted death"
        decline_dying.name = "decline"
        decline_dying.fontColor = .white
        decline_dying.fontSize = 25
        decline_dying.zPosition = 10
        decline_dying.alpha = 0
        decline_dying.position = CGPoint(x: 0, y: self.position.y + 150)
        self.parent?.addChild(decline_dying)
//        if sprite_orientation == constants.orientation_left{
//            self.decline_dying.run(SKAction.scaleX(to: -1, duration: 0))
//        }
        let declaration = SKAction.sequence([SKAction.fadeIn(withDuration: 1), SKAction.fadeOut(withDuration: 1)])
        let final = SKAction.run { [weak self] in
            self?.hp = self?.hp_max ?? 0
            self?.on_final_life = true
            self?.hpBar.size = CGSize(width: CGFloat(30), height: CGFloat(5))
            self?.is_alive = true
            self?.movement_status = constants.initial
        }
        let blink = SKAction.run { [weak self] in
            self?.decline_dying.run(declaration)
        }
        self.run(SKAction.sequence([death, blink, revive, final]), withKey: "revival")
    }
    
    // DAMAGE functions
    
    func takeDamage(dmg: Int) {
        hp -= CGFloat(dmg)
        if hp > 0 {
        hpBar.size = CGSize(width: CGFloat(hp/hp_max * 30), height: CGFloat(5))
        } else if on_final_life{
            hpBar.removeFromParent()
        }
        dmgTicker.text = "-\(dmg)"
        if sprite_orientation == constants.orientation_left{
            dmgTicker.run(SKAction.scaleX(to: -1, duration: 0))
            dmgTicker.alpha = 1
        } else {
            dmgTicker.alpha = 1
            dmgTicker.run(SKAction.scaleX(to: 1, duration: 0))
        }
       
        let fade = SKAction.fadeOut(withDuration: 1)
        dmgTicker.run(fade)
        if(hp <= 0){
            is_alive = false
            if on_final_life {
                deathAnimation()
                if let gameScene = self.parent?.parent as? GameScene {
                    gameScene.onMalphasDeath()
                }
            } else {
                revivalAnimation()
                
            }
        }
    }

    func checkOverlap2(cx: CGFloat, cy: CGFloat, radius: CGFloat, rx: CGFloat, ry: CGFloat, rw: CGFloat, rh: CGFloat)->Bool{

      // temporary variables to set edges for testing
      var testX = cx;
      var testY = cy;

      // which edge is closest?
        if (cx < rx){      testX = rx;   }   // test left edge
        else if (cx > rx+rw) {testX = rx+rw; }  // right edge
        if (cy < ry) {        testY = ry;    }  // top edge
        else if (cy > ry+rh) {testY = ry+rh;  } // bottom edge

      // get distance from closest edges
      let distX = cx-testX;
      let distY = cy-testY;
      let distance = sqrt( (distX*distX) + (distY*distY) );

      // if the distance is less than the radius, collision!
      if (distance <= radius) {
        return true;
      }
      return false;
    }
    // rectangle & circle collision detection
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
    
    func checkOrbs(location: CGPoint)->Int{
        let x1 = location.x - CGFloat(constants.player_width/2)
        let y1 = location.y - CGFloat(constants.player_height/2)
//        let x2 = location.x + CGFloat(constants.player_width/2)
//        let y2 = location.y + CGFloat(constants.player_height/2)
        b = 0
//        if checkOverlap(R: CGFloat(13), Xc: orb1.position.x, Yc: orb1.position.y, X1: x1, Y1: y1, X2: x2, Y2: y2) {
//            b += 1
//        }
//        if checkOverlap(R: CGFloat(13), Xc: orb2.position.x, Yc: orb2.position.y, X1: x1, Y1: y1, X2: x2, Y2: y2) {
//            b += 1
//        }
//        if checkOverlap(R: CGFloat(13), Xc: orb3.position.x, Yc: orb3.position.y, X1: x1, Y1: y1, X2: x2, Y2: y2) {
//            b += 1
//        }
//        if checkOverlap(R: CGFloat(13), Xc: orb4.position.x, Yc: orb4.position.y, X1: x1, Y1: y1, X2: x2, Y2: y2) {
//            b += 1
//        }
//        if checkOverlap(R: CGFloat(13), Xc: orb5.position.x, Yc: orb5.position.y, X1: x1, Y1: y1, X2: x2, Y2: y2) {
//            b += 1
//        }
//        if checkOverlap(R: CGFloat(13), Xc: orb6.position.x, Yc: orb6.position.y, X1: x1, Y1: y1, X2: x2, Y2: y2) {
//            b += 1
//        }
        
        if checkOverlap2(cx: orb1.position.x, cy: orb1.position.y, radius: CGFloat(13), rx: x1, ry: y1, rw: CGFloat(constants.player_width), rh: CGFloat(constants.player_height)) {
            b+=1
        }
        if checkOverlap2(cx: orb2.position.x, cy: orb2.position.y, radius: CGFloat(13), rx: x1, ry: y1, rw: CGFloat(constants.player_width), rh: CGFloat(constants.player_height)) {
            b+=1
        }
        if checkOverlap2(cx: orb3.position.x, cy: orb3.position.y, radius: CGFloat(13), rx: x1, ry: y1, rw: CGFloat(constants.player_width), rh: CGFloat(constants.player_height)) {
            b+=1
        }
        if checkOverlap2(cx: orb4.position.x, cy: orb4.position.y, radius: CGFloat(13), rx: x1, ry: y1, rw: CGFloat(constants.player_width), rh: CGFloat(constants.player_height)) {
            b+=1
        }
        if checkOverlap2(cx: orb5.position.x, cy: orb5.position.y, radius: CGFloat(13), rx: x1, ry: y1, rw: CGFloat(constants.player_width), rh: CGFloat(constants.player_height)) {
            b+=1
        }
        if checkOverlap2(cx: orb6.position.x, cy: orb6.position.y, radius: CGFloat(13), rx: x1, ry: y1, rw: CGFloat(constants.player_width), rh: CGFloat(constants.player_height)) {
            b+=1
        }
        return b
        
    }
    func shouldGiveDamage(location: CGPoint) -> Bool {
        if should_update_orbs && checkOrbs(location: location) > 0{
            removeOrbs()
            return true
        }
        
        if !giving_damage {
            return false
        }
        
        if self.sprite_orientation == constants.orientation_left && (location.x - 20 ) > self.position.x {
            return false
        } else if self.sprite_orientation == constants.orientation_right && location.x < (self.position.x - 20){
            return false
        }
        
        let x1 = location.x - CGFloat(constants.player_width/2)
        let y1 = location.y - CGFloat(constants.player_height/2)
        let x2 = location.x + CGFloat(constants.player_width/2)
        let y2 = location.y + CGFloat(constants.player_height/2)
        
        return checkOverlap(R: 68, Xc: self.position.x + CGFloat(sprite_orientation) * attack_field_shift, Yc: self.position.y + CGFloat(20), X1: x1, Y1: y1, X2: x2, Y2: y2)
    }
    
}

