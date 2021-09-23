//
//  Mushroom.swift
//  hi
//
//  Created by Tom Stoev on 8/29/21.
//

import SpriteKit

class Mushroom: SKSpriteNode, Entity {
    private var initialSize: CGSize = CGSize(width: 250, height: 250)
    private var textureAtlas: SKTextureAtlas = SKTextureAtlas(named: "Mushroom")
    private var sprite_orientation = constants.orientation_right
    private var movement_status = constants.initial
    
    private var can_take_damage = true
    private var hp = CGFloat(50)
    private let hp_max = CGFloat(50)
    private let dmg = Int(6)
    private var is_alive = true
    private var attack_field_shift = CGFloat(35)
    private var giving_damage = false
    
    
    private let hpBar = SKSpriteNode(color: .green, size: CGSize(width: CGFloat(30), height: CGFloat(5)))
    private let dmgTicker = SKLabelNode(fontNamed: "AppleSDGothicNeo-Bold")
    
    private var can_attack = true
    private let max_velocity = CGFloat(160)

    init() {
        super.init(texture: textureAtlas.textureNamed("mushroom_attack007"), color: .clear, size:initialSize)
        self.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: 43, height: 61), center: CGPoint(x:self.position.x, y: self.position.y-12))
        self.name = "update_mushroom"
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
        hpBar.position = CGPoint(x: self.position.x, y: self.position.y + CGFloat(25))
        
        dmgTicker.text = ""
        dmgTicker.alpha = 1
        dmgTicker.zPosition = 9
        dmgTicker.position = CGPoint(x: self.position.x+35, y: self.position.y + CGFloat(15))
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
        // orientation update
        
        
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
        

        // select animation
        if abs(self.position.x - pos.x) <= (70) && can_attack && abs(self.position.y - pos.y) <= 70{
            if movement_status != constants.attacking {
                self.removeAction(forKey: "idle")
                //self.removeAction(forKey: "run")
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
            
            if abs(self.position.x - pos.x) <= 300 && abs(self.position.x - pos.x) > 50 && abs(self.position.y - pos.y) <= 70{
                if sprite_orientation == constants.orientation_left {
                    self.physicsBody?.applyImpulse(CGVector(dx: -5, dy: 0))
                } else {
                    self.physicsBody?.applyImpulse(CGVector(dx: 5, dy: 0))
                }
            } else { // stop if getting too close (to prevent switching back & forth glitch)
                self.physicsBody?.velocity = CGVector(dx: 0, dy: 0)
            }
        }
 
        
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
            if let gameScene = self.parent?.parent as? GameScene{
                gameScene.onEnemyDeath()
            }
            deathAnimation()
        }
    }
    
    
    func deathAnimation(){
        self.giving_damage = false
        self.removeAction(forKey: "idle")
        self.removeAction(forKey: "attack")
        let deathFrames:[SKTexture] =
            [textureAtlas.textureNamed("mushroom_death000"),
             textureAtlas.textureNamed("mushroom_death001"),
             textureAtlas.textureNamed("mushroom_death002"),
             textureAtlas.textureNamed("mushroom_death003")]
        let death = SKAction.animate(with: deathFrames, timePerFrame: 0.15)
        let remove = SKAction.run { [weak self] in
            self?.removeAllChildren()
            self?.removeFromParent()
        }
        // after attack is finished, go to idle animation for a while
        self.run(SKAction.sequence([death, remove]), withKey: "death")
    }
    
    
    func idleAnimation(){
        let idleFrames:[SKTexture] =
            [textureAtlas.textureNamed("mushroom_idle000"),
             textureAtlas.textureNamed("mushroom_idle001"),
             textureAtlas.textureNamed("mushroom_idle002"),
             textureAtlas.textureNamed("mushroom_idle003")]
        let idleAction = SKAction.animate(with: idleFrames,
                                         timePerFrame: 0.12)
        let reset = SKAction.run { [weak self] in
            self?.can_attack = true
        }
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
            [textureAtlas.textureNamed("mushroom_attack000"),
             textureAtlas.textureNamed("mushroom_attack001"),
             textureAtlas.textureNamed("mushroom_attack002"),
             textureAtlas.textureNamed("mushroom_attack003"),
             textureAtlas.textureNamed("mushroom_attack004"),
             textureAtlas.textureNamed("mushroom_attack005")]
        
        let attackFrames2:[SKTexture] = [
            textureAtlas.textureNamed("mushroom_attack006"),
            textureAtlas.textureNamed("mushroom_attack007")]
        
        let attackAction = SKAction.animate(with: attackFrames, timePerFrame: 0.1)
        let attackAction2 = SKAction.animate(with: attackFrames2, timePerFrame: 0.1)
        let give_damage = SKAction.run { [weak self] in
            self?.giving_damage = true
        }
        let reset = SKAction.run { [weak self] in
            self?.movement_status = constants.finished_attack
            self?.giving_damage = false
        }
        self.run(SKAction.sequence([attackAction, give_damage, attackAction2, reset]), withKey: "attack")
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
        if !giving_damage{
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
        
        return checkOverlap(R: CGFloat(28), Xc: self.position.x + CGFloat(sprite_orientation) * attack_field_shift, Yc: self.position.y - CGFloat(10), X1: x1, Y1: y1, X2: x2, Y2: y2)

    }

    
}
