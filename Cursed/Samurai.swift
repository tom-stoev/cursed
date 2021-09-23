//
//  Samurai.swift
//  hi
//
//  Created by Tom Stoev on 8/27/21.
//

import SpriteKit

class Samurai: SKSpriteNode, Entity {
    
    
    private var initialSize: CGSize = CGSize(width: 300, height: 300)
    private var textureAtlas: SKTextureAtlas = SKTextureAtlas(named: "Samurai")
    private var sprite_orientation = constants.orientation_right
    private var movement_status = constants.initial
    private let max_velocity = CGFloat(100)
    private var has_faded_in = false

    private var hp = CGFloat(350)
    private let hp_max = CGFloat(350)
    private let dmg = Int(21)
    private var is_alive = false
    private var giving_damage = false
    private var can_attack = true
    private var can_take_damage = true
    private var ready_to_teleport = false

    private var attack_field_shift = CGFloat(98)
    private var attack_field2_shift = CGFloat(30)
    
    private let hpBar = SKSpriteNode(color: .green, size: CGSize(width: CGFloat(30), height: CGFloat(5)))
    private let dmgTicker = SKLabelNode(fontNamed: "AppleSDGothicNeo-Bold")
    


    init() {
        super.init(texture: textureAtlas.textureNamed("samurai_idle000"), color: .clear, size:initialSize)
        self.alpha = 0
        self.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: 44, height: 68), center: CGPoint(x:self.position.x, y: self.position.y))
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
        
        addIndicators()
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func addIndicators() {
        self.addChild(hpBar)
        hpBar.name = "hp_bar"
        hpBar.zPosition = 9
        hpBar.position = CGPoint(x: self.position.x, y: self.position.y + CGFloat(45))
        
        dmgTicker.text = ""
        dmgTicker.alpha = 1
        dmgTicker.zPosition = 9
        dmgTicker.position = CGPoint(x: self.position.x+35, y: self.position.y + CGFloat(35))
        dmgTicker.fontColor = .red
        dmgTicker.fontSize = 23
        self.addChild(dmgTicker)
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
        return dmg
    }
    
    func update(pos: CGPoint, status: Bool, orientation: Int, damage: Int){
        if !has_faded_in {
            let set_alive = SKAction.run { [weak self] in
                self?.is_alive = true
                self?.has_faded_in = true
            }
            self.run(SKAction.sequence([SKAction.fadeIn(withDuration: 2), set_alive]))
        }
        if !is_alive{ // dont need to do anything if out of view
            return
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
                //self.dmgTicker.alpha = 0
                self.run(SKAction.scaleX(to: -1, duration: 0))
            }
        }
        
        // cap velocity
        if(self.physicsBody!.velocity.dx > max_velocity) {self.physicsBody!.velocity.dx = max_velocity}
        if(self.physicsBody!.velocity.dx < -max_velocity) {self.physicsBody!.velocity.dx = -max_velocity}
        
        if(self.physicsBody!.velocity.dy < 0){
            self.physicsBody!.applyImpulse(CGVector(dx: 0, dy: -5))
        }
        
        if ready_to_teleport {
            teleport(position: pos)
            attackAnimation()
            ready_to_teleport = false
            return
        }
        
        // select animation
        if abs(self.position.x - pos.x) <= (450) && can_attack && abs(self.position.y - pos.y) <= 300{
            if movement_status != constants.attacking {
                self.removeAction(forKey: "idle")
                movement_status = constants.attacking
                can_attack = false
                let preAttackFrames:[SKTexture] = [textureAtlas.textureNamed("samurai_before_attack000"),
                                                   textureAtlas.textureNamed("samurai_before_attack001")]
                let preAttackAction = SKAction.animate(with: preAttackFrames, timePerFrame: 0.15)
                let preAttack = SKAction.repeat(preAttackAction, count: 2)
                let setTeleport = SKAction.run { [weak self] in
                    self?.ready_to_teleport = true
                }
                self.run(SKAction.sequence([preAttack, setTeleport]))
            }

        }
        // chase player
        if movement_status != constants.attacking {
            if movement_status != constants.idle {
                idleAnimation()
                movement_status = constants.idle
            }
            
            if abs(self.position.x - pos.x) <= 250 && abs(self.position.x - pos.x) > 50 && abs(self.position.y - pos.y) <= 70{
                if sprite_orientation == constants.orientation_left {
                    self.physicsBody?.applyImpulse(CGVector(dx: -2, dy: 0))
                } else {
                    self.physicsBody?.applyImpulse(CGVector(dx: 2, dy: 0))
                }
            } else { // stop if getting too close (to prevent switching back & forth glitch)
                self.physicsBody?.velocity = CGVector(dx: 0, dy: 0)
            }
        }

    }
    
    func teleport(position: CGPoint){
        let side = Int.random(in: 0...1)
        if side == 0 { // teleport to the left side
            self.physicsBody?.applyForce(CGVector(dx: -2, dy: 0))
            self.position.x = position.x + CGFloat.random(in: 38..<55)
            if sprite_orientation != constants.orientation_left {
                self.run(SKAction.scaleX(to: -1, duration: 0))
                sprite_orientation = constants.orientation_left
            }
        } else {
            self.physicsBody?.applyForce(CGVector(dx: 2, dy: 0))
            self.position.x = position.x - CGFloat.random(in: 38..<55)
            if sprite_orientation != constants.orientation_right {
                self.run(SKAction.scaleX(to: 1, duration: 0))
                sprite_orientation = constants.orientation_right
            }
        }
        
        // x: -290 to 10 & y: 320 to 350
        // x: 140 to 440 & y: 200 to 230
        if self.position.x <= 10 && self.position.x >= -290 && position.y <= 350+35 && position.y >= 320-35 {
            self.position.y = CGFloat(380+35 + constants.samurai_height/2)
        } else  if self.position.x <= 440 && self.position.x >= 140 && position.y <= 230+35 && position.y >= 200-35 {
            self.position.y = CGFloat(260+35 + constants.samurai_height/2)
        } else {
        self.position.y = position.y
        }
    }
    
    // animations
    func idleAnimation(){
        let idleFrames:[SKTexture] =
            [textureAtlas.textureNamed("samurai_idle000"),
             textureAtlas.textureNamed("samurai_idle001"),
             textureAtlas.textureNamed("samurai_idle002"),
             textureAtlas.textureNamed("samurai_idle003"),
             textureAtlas.textureNamed("samurai_idle004"),
             textureAtlas.textureNamed("samurai_idle005"),
             textureAtlas.textureNamed("samurai_idle006"),
             textureAtlas.textureNamed("samurai_idle007")]
        let idleAction = SKAction.animate(with: idleFrames,
                                         timePerFrame: 0.15)
        let reset = SKAction.run { [weak self] in
            self?.can_attack = true
        }
        // run idle animation 2x in a loop and then enable attacking if the player
        // comes close to the samurai
        let idle = SKAction.repeat(idleAction, count: 2)
        let first = (SKAction.sequence([idle, reset]))
        let second = SKAction.repeatForever(idleAction)
        self.run(SKAction.sequence([first, second]), withKey: "idle")
    }
    
    func runAnimation() {
        // ugly animation, idle looks better
    }
    
    func attackAnimation(){
        let attackFrames:[SKTexture] =
            [textureAtlas.textureNamed("samurai_attack000"),
             textureAtlas.textureNamed("samurai_attack001"),
             textureAtlas.textureNamed("samurai_attack002"),
             textureAtlas.textureNamed("samurai_attack003")]
        let attackFrames2:[SKTexture] = [
            textureAtlas.textureNamed("samurai_attack004"),
            textureAtlas.textureNamed("samurai_attack005")]
        let attackAction = SKAction.animate(with: attackFrames, timePerFrame: 0.1)
        let attack2Action = SKAction.animate(with: attackFrames2, timePerFrame: 0.1)
        let damageSet = SKAction.run { [weak self] in
            self?.giving_damage = true
        }
        
        let reset = SKAction.run { [weak self] in
            self?.movement_status = constants.finished_attack
            self?.giving_damage = false
        }
        // after attack is finished, go to idle animation for a while
        self.run(SKAction.sequence([attackAction, damageSet, attack2Action, reset]), withKey: "attack")
    }
    
    func deathAnimation(){
        self.giving_damage = false
        self.removeAction(forKey: "idle")
        self.removeAction(forKey: "attack")
        let deathFrames:[SKTexture] =
            [textureAtlas.textureNamed("samurai_death000"),
             textureAtlas.textureNamed("samurai_death001"),
             textureAtlas.textureNamed("samurai_death002"),
             textureAtlas.textureNamed("samurai_death003"),
             textureAtlas.textureNamed("samurai_death004"),
             textureAtlas.textureNamed("samurai_death005")]
        let death = SKAction.animate(with: deathFrames, timePerFrame: 0.1)
        let remove = SKAction.run { [weak self] in
            self?.removeAllChildren()
            self?.removeFromParent()
        }
        self.run(SKAction.sequence([death, remove]), withKey: "death")
    }
    
    // DAMAGE functions
    
    func takeDamage(dmg: Int) {
        hp -= CGFloat(dmg)
        if hp > 0 {
            hpBar.size = CGSize(width: CGFloat(hp/hp_max * 30), height: CGFloat(5))
        } else {
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
            
            let hp_drop = HealthPotion()
            hp_drop.position = CGPoint(x: 0, y: self.position.y + 50)
            hp_drop.name = "update_hp"
            let gen = Int.random(in: 0...1)
            if gen == 0 {
                hp_drop.setLarge()
            } else {
                hp_drop.setRegular()
            }
            self.parent?.addChild(hp_drop)
            deathAnimation()
            if let gameScene = self.parent?.parent as? GameScene {
                gameScene.onEnemyDeath()
            }
        }
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
    func shouldGiveDamage(location: CGPoint) -> Bool {
        if !giving_damage {
            return false 
        }
        if self.sprite_orientation == constants.orientation_left && location.x > self.position.x {
            return false
        } else if self.sprite_orientation == constants.orientation_right && location.x < self.position.x{
            return false
        }
        
        let x1 = location.x - CGFloat(constants.player_width/2)
        let y1 = location.y - CGFloat(constants.player_height/2)
        let x2 = location.x + CGFloat(constants.player_width/2)
        let y2 = location.y + CGFloat(constants.player_height/2)
        
        return checkOverlap(R: 33, Xc: self.position.x + CGFloat(sprite_orientation) * attack_field_shift, Yc: self.position.y + CGFloat(20), X1: x1, Y1: y1, X2: x2, Y2: y2) || checkOverlap(R: CGFloat(48), Xc: self.position.x + CGFloat(sprite_orientation) * attack_field2_shift, Yc: self.position.y + CGFloat(18), X1: x1, Y1: y1, X2: x2, Y2: y2)
    }
    
}


