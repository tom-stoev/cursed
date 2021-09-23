//
//  Wizard2.swift
//  hi
//
//  Created by Tom Stoev on 8/17/21.
//

import SpriteKit

class Wizard2: SKSpriteNode, Entity{
    // sprite info
    private var initialSize: CGSize = CGSize(width: 200, height: 150)
    private var textureAtlas: SKTextureAtlas = SKTextureAtlas(named: "Wizard2")
    private var sprite_orientation = constants.orientation_right
    private var movement_status = constants.initial
    private let max_velocity = CGFloat(200)
    
    
    // damage / hp variables
    private var particles_on = false
    private var can_take_damage = true
    private var hp = CGFloat(75)
    private let hp_max = CGFloat(75)
    private let dmg = Int(8)
    private var is_alive = true
    private var can_attack = true

    // indicators
    private let hpBar = SKSpriteNode(color: .green, size: CGSize(width: CGFloat(30), height: CGFloat(5)))
    private let dmgTicker = SKLabelNode(fontNamed: "AppleSDGothicNeo-Bold")

    init() {
        super.init(texture: textureAtlas.textureNamed("wizard_2_idle000"), color: .clear, size:initialSize)
        self.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: 35, height: 85), center: CGPoint(x:self.position.x-8, y: self.position.y-5))
        self.name = "update_wizard2"
        self.physicsBody?.linearDamping = 0
        self.physicsBody?.angularDamping = 0
        self.physicsBody?.angularVelocity = 0
        self.physicsBody?.restitution = 0
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
    
    func getDamage()->Int{
        return dmg
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
    
    func update(pos: CGPoint, status: Bool, orientation: Int, damage: Int){
        if !is_alive{
            return
        }
        
        // check if needs to take damage 
        if status && can_take_damage{
            self.takeDamage(dmg: damage)
            self.can_take_damage = false
        }
        
        // orientation update
        if(movement_status != constants.attacking) && can_take_damage {
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
        // check if can attack & in range
        if abs(self.position.x - pos.x) <= (225) && can_attack && abs(self.position.y - pos.y) <= 100{
            self.removeAction(forKey: "idle")
                movement_status = constants.attacking
                can_attack = false
                attackAnimation()
        }  else if movement_status == constants.finished_attack{
            self.removeAction(forKey: "attack")
            if(movement_status != constants.idle){
                idleAnimation()
                movement_status = constants.idle
            }
        }
        
        // decide if going to chase player
        if movement_status != constants.attacking {
            if abs(self.position.x - pos.x) <= 250 && abs(self.position.x - pos.x) > 30 && abs(self.position.y - pos.y) <= 70{
                if sprite_orientation == constants.orientation_left {
                    self.physicsBody?.applyImpulse(CGVector(dx: -2, dy: 0))
                } else {
                    self.physicsBody?.applyImpulse(CGVector(dx: 2, dy: 0))
                }
            } else if abs(self.position.x - pos.x) <= 30 { // stop if getting too close (to prevent switching back & forth glitch)
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
            dmgTicker.run(SKAction.scaleX(to: 1, duration: 0))
            dmgTicker.alpha = 1
        }
        let fade = SKAction.fadeOut(withDuration: 1)
        dmgTicker.run(fade)
        if(hp <= 0){
            is_alive = false
            if let gameScene = self.parent?.parent as? GameScene {
                gameScene.onEnemyDeath()
            }
            deathAnimation()
        }
    
    }
    
    func idleAnimation(){
        let idleFrames:[SKTexture] =
            [textureAtlas.textureNamed("wizard_2_idle000"),
             textureAtlas.textureNamed("wizard_2_idle001"),
             textureAtlas.textureNamed("wizard_2_idle002"),
             textureAtlas.textureNamed("wizard_2_idle003"),
             textureAtlas.textureNamed("wizard_2_idle004"),
             textureAtlas.textureNamed("wizard_2_idle005")]
        let idleAction = SKAction.animate(with: idleFrames,
                                         timePerFrame: 0.2)
        let reset = SKAction.run { [weak self] in
            self?.can_attack = true
        }
        // run idle animation 1x then reset attacking then repeat idle till player gets close
        let idle = SKAction.repeat(idleAction, count: 1)
        let first = (SKAction.sequence([idle, reset]))
        let second = SKAction.repeatForever(idleAction)
        self.run(SKAction.sequence([first, second]), withKey: "idle")
    }
    
    func attackAnimation(){
        let attackFrames:[SKTexture] =
            [textureAtlas.textureNamed("wizard_2_attack2000"),
             textureAtlas.textureNamed("wizard_2_attack2001"),
             textureAtlas.textureNamed("wizard_2_attack2002"),
             textureAtlas.textureNamed("wizard_2_attack2003"),
             textureAtlas.textureNamed("wizard_2_attack2004"),
             textureAtlas.textureNamed("wizard_2_attack2005")]
        let attackFrames2:[SKTexture] = [textureAtlas.textureNamed("wizard_2_attack2006"),
                                       textureAtlas.textureNamed("wizard_2_attack2007")]
        let attackAction = SKAction.animate(with: attackFrames, timePerFrame: 0.2)
        let attackAction2 = SKAction.animate(with: attackFrames2, timePerFrame: 0.3)
        let reset = SKAction.run { [weak self] in
            self?.movement_status = constants.finished_attack
            for i in (self?.children)! {
                if i.name == "particle_delete" {
                    i.removeFromParent()
                    break
                }
            }
            self?.particles_on = false
        }
        // after attack is finished, go to idle animation for a while
        self.run(SKAction.sequence([attackAction, reset]), withKey: "attack")
        let particles = SKAction.run { [weak self] in
            if let dots = SKEmitterNode(fileNamed: "Wizard2_attack2"){
            dots.particleZPosition = 0
            self?.addChild(dots)
            dots.targetNode = self
            self?.particles_on = true
                dots.name = "particle_delete"
            }
        }
        self.run(SKAction.sequence([attackAction, particles, attackAction2, reset]), withKey: "attack")
    }
    
    func runAnimation() {
        // animation is ugly -> dont implement
    }

    func deathAnimation(){
        self.movement_status = constants.initial
        self.removeAction(forKey: "idle")
        self.removeAction(forKey: "attack")
        let deathFrames:[SKTexture] =
            [textureAtlas.textureNamed("wizard_2_death000"),
             textureAtlas.textureNamed("wizard_2_death001"),
             textureAtlas.textureNamed("wizard_2_death002"),
             textureAtlas.textureNamed("wizard_2_death003"),
             textureAtlas.textureNamed("wizard_2_death004"),
             textureAtlas.textureNamed("wizard_2_death005"),
             textureAtlas.textureNamed("wizard_2_death006")]
        let death = SKAction.animate(with: deathFrames, timePerFrame: 0.1)
        let remove = SKAction.run { [weak self] in
            self?.removeAllChildren()
            self?.removeFromParent()
        }
        // after attack is finished, go to idle animation for a while
        self.run(SKAction.sequence([death, remove]), withKey: "death")
    }
    
    func shouldGiveDamage(location: CGPoint) -> Bool {
        if !particles_on {
            return false
        }
        let xDist = abs(location.x - self.position.x); // subtract half player width
        let yDist = abs(location.y - self.position.y); // subtract half player height
        if xDist <= 145 && yDist <= 157 { // xDist + 15, yDist + 27
            return true
        }
        return false
    }
    
}
