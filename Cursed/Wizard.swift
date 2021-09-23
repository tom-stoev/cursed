//
//  LeafeSprite.swift
//  hi
//
//  Created by Tom Stoev on 8/14/21.
//

import SpriteKit

class Wizard: SKSpriteNode, Entity {
    private var initialSize: CGSize = CGSize(width: 300, height: 300)
    private var textureAtlas: SKTextureAtlas = SKTextureAtlas(named: "Wizard")
    private var sprite_orientation = constants.orientation_right
    private var movement_status = constants.initial
    private let max_velocity = CGFloat(100)
    
    private var hp = CGFloat(75)
    private let hp_max = CGFloat(75)
    private var can_take_damage = true
    private let dmg = Int(10)
    private var is_alive = true
    private var can_attack = true

    private var attack_field_shift = CGFloat(95)
    private var attack_field2_shift = CGFloat(55)

    private let hpBar = SKSpriteNode(color: .green, size: CGSize(width: CGFloat(30), height: CGFloat(5)))
    private let dmgTicker = SKLabelNode(fontNamed: "AppleSDGothicNeo-Bold")

    init() {
        super.init(texture: textureAtlas.textureNamed("wizard_1_idle000"), color: .clear, size:initialSize)
        self.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: 47, height: 85), center: CGPoint(x:self.position.x-3, y: self.position.y-5))
        self.name = "update_wizard"
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
        if !is_alive{ // dont need to do anything if out of view
            return
        }
        
        // check if needs to take damage 
        if status && can_take_damage{
            self.takeDamage(dmg: damage)
            self.can_take_damage = false
        }
        
        // orientation update to face player
        if movement_status != constants.attacking && can_take_damage{
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
        
        if(self.physicsBody!.velocity.dy < 0){
            self.physicsBody!.applyImpulse(CGVector(dx: 0, dy: -5))
        }

        // select animation
        if abs(self.position.x - pos.x) <= (190) && can_attack && abs(self.position.y - pos.y) <= 70{
            if movement_status != constants.attacking {
                self.removeAction(forKey: "idle")
                movement_status = constants.attacking
                can_attack = false
                attackAnimation()
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
    
    func idleAnimation(){
        let idleFrames:[SKTexture] =
            [textureAtlas.textureNamed("wizard_1_idle000"),
             textureAtlas.textureNamed("wizard_1_idle001"),
             textureAtlas.textureNamed("wizard_1_idle002"),
             textureAtlas.textureNamed("wizard_1_idle003"),
             textureAtlas.textureNamed("wizard_1_idle004"),
             textureAtlas.textureNamed("wizard_1_idle005"),
             textureAtlas.textureNamed("wizard_1_idle006"),
             textureAtlas.textureNamed("wizard_1_idle007")]
        let idleAction = SKAction.animate(with: idleFrames,
                                         timePerFrame: 0.12)
        let reset = SKAction.run { [weak self] in
            self?.can_attack = true // enable attacking
        }
        // run idle animation 3x in a loop and then enable attacking (serves as cooldown)
        let idle = SKAction.repeat(idleAction, count: 3)
        let first = (SKAction.sequence([idle, reset]))
        let second = SKAction.repeatForever(idleAction)
        self.run(SKAction.sequence([first, second]), withKey: "idle")
    }
    
    func runAnimation() {
        // ugly animation, idle looks better
    }
    
    func attackAnimation(){
        let attackFrames:[SKTexture] =
            [textureAtlas.textureNamed("wizard_1_attack000"),
             textureAtlas.textureNamed("wizard_1_attack001"),
             textureAtlas.textureNamed("wizard_1_attack002"),
             textureAtlas.textureNamed("wizard_1_attack003"),
             textureAtlas.textureNamed("wizard_1_attack004"),
             textureAtlas.textureNamed("wizard_1_attack005"),
             textureAtlas.textureNamed("wizard_1_attack006"),
             textureAtlas.textureNamed("wizard_1_attack007")]
        let attackAction = SKAction.animate(with: attackFrames, timePerFrame: 0.1)
        let reset = SKAction.run { [weak self] in
            self?.movement_status = constants.finished_attack
        }
        // after attack is finished, go to idle animation for cooldown
        self.run(SKAction.sequence([attackAction, reset]), withKey: "attack")
    }
    
    func deathAnimation(){
        //self.movement_status = constants.initial
//        self.removeAction(forKey: "idle")
//        self.removeAction(forKey: "attack")
        self.removeAllActions()
        let deathFrames:[SKTexture] =
            [textureAtlas.textureNamed("wizard_1_death000"),
             textureAtlas.textureNamed("wizard_1_death001"),
             textureAtlas.textureNamed("wizard_1_death002"),
             textureAtlas.textureNamed("wizard_1_death003"),
             textureAtlas.textureNamed("wizard_1_death004")]
        let death = SKAction.animate(with: deathFrames, timePerFrame: 0.1)
        let remove = SKAction.run { [weak self] in
            self?.removeAllChildren()
            self?.removeFromParent()
        }
        self.run(SKAction.sequence([death, remove]), withKey: "death")
    }
    
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
            let gen = Int.random(in: 0...1)
            if gen == 0 {
                let hp_drop = HealthPotion()
                hp_drop.position = CGPoint(x: self.position.x, y: self.position.y + 50)
                hp_drop.name = "update_hp"
                hp_drop.setRegular()
                self.parent?.addChild(hp_drop)
            }
            if let gameScene = self.parent?.parent as? GameScene {
                gameScene.onEnemyDeath()
            }
            deathAnimation()
        }
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
    
    func shouldGiveDamage(location: CGPoint) -> Bool {
        if self.movement_status != constants.attacking{
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
        
        return checkOverlap(R: CGFloat(27), Xc: self.position.x + CGFloat(sprite_orientation) * attack_field_shift, Yc: self.position.y + CGFloat(5), X1: x1, Y1: y1, X2: x2, Y2: y2) || checkOverlap(R: CGFloat(16), Xc: self.position.x + CGFloat(sprite_orientation) * attack_field2_shift, Yc: self.position.y + CGFloat(6), X1: x1, Y1: y1, X2: x2, Y2: y2) || abs(location.x - self.position.x) <= 40 && abs(location.y - self.position.y) <= 40

    }
    
}


/*
 
 //   private let attackField = SKSpriteNode(color: .clear, size: CGSize(width: 4, height: 4))
 //    private let attackField2 = SKSpriteNode(color: .clear, size: CGSize(width: 4, height: 4))
 //        attackField.physicsBody = SKPhysicsBody(circleOfRadius: CGFloat(33), center: CGPoint(x: self.position.x + attack_field_shift, y: self.position.y + 20))
 //        attackField.physicsBody?.affectedByGravity = false
 //        attackField.physicsBody?.categoryBitMask = physicsCategory.attack.rawValue
 //        attackField.physicsBody?.collisionBitMask = 0
 //        attackField.physicsBody?.contactTestBitMask = 0
 //        attackField.physicsBody?.isDynamic = false
 //        attackField2.physicsBody = SKPhysicsBody(circleOfRadius: CGFloat(48), center: CGPoint(x: self.position.x + attack_field2_shift, y:  self.position.y+18))
 //        attackField2.physicsBody?.affectedByGravity = false
 //        attackField2.physicsBody?.isDynamic = false
 //        attackField2.physicsBody?.categoryBitMask = physicsCategory.attack.rawValue
 //        attackField2.physicsBody?.collisionBitMask = 0
 //        attackField2.physicsBody?.contactTestBitMask = 0
 //
 //
 //        self.addChild(attackField)
 //        self.addChild(attackField2)
 
 */

