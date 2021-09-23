//
//  Eye.swift
//  hi
//
//  Created by Tom Stoev on 8/29/21.
//

import SpriteKit

class Eye: SKSpriteNode, Entity {
    private var initialSize: CGSize = CGSize(width: 200, height: 200)
    private var textureAtlas: SKTextureAtlas = SKTextureAtlas(named: "Eye")
    private var sprite_orientation = constants.orientation_right
    private var movement_status = constants.idle
    
    private var can_take_damage = true
    private var hp = CGFloat(50)
    private let hp_max = CGFloat(50)
    private let dmg = Int(3)
    private var is_alive = true
    
    private var origin = CGPoint()
    private var flying = false
    private var a = CGFloat()
    private var slope = CGFloat()
    private var flight_direction = 1
    private var speed_factor = CGFloat()
    private let left_to_right = 1
    
    private let hpBar = SKSpriteNode(color: .green, size: CGSize(width: CGFloat(30), height: CGFloat(5)))
    private let dmgTicker = SKLabelNode(fontNamed: "AppleSDGothicNeo-Bold")
    
    private var can_attack = true
    private let max_velocity = CGFloat(100)
    
    
    var x = 0

    init() {
        super.init(texture: textureAtlas.textureNamed("eye_idle000"), color: .clear, size:initialSize)
        idleAnimation()
        self.physicsBody = SKPhysicsBody(circleOfRadius: 22, center: CGPoint(x:self.position.x, y: self.position.y-1))
        self.name = "update_eye"
        self.physicsBody?.linearDamping = 0
        self.physicsBody?.restitution = 0
        self.physicsBody?.angularDamping = 0
        self.physicsBody?.angularVelocity = 0
        self.physicsBody?.friction = 0
        self.physicsBody?.allowsRotation = false
        self.zPosition = 8
        self.physicsBody?.affectedByGravity = false
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
        hpBar.position = CGPoint(x: self.position.x, y: self.position.y + CGFloat(22))
        
        dmgTicker.text = ""
        dmgTicker.alpha = 1
        dmgTicker.zPosition = 9
        dmgTicker.position = CGPoint(x: self.position.x+35, y: self.position.y + CGFloat(7))
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
    
    func genFlightPath(bottom: CGPoint){
        origin = CGPoint(x: bottom.x, y: bottom.y)
        a = abs(self.position.x - bottom.x)
        slope = abs((self.position.y - bottom.y)/(self.position.x - bottom.x))
        
        if self.position.x < bottom.x {
            flight_direction = left_to_right
        } else {
            flight_direction = -1 * left_to_right
        }
        speed_factor = a * CGFloat(1.25)
        return
    }
    
    func findVelocity(){
        if self.position.x > origin.x {
            self.physicsBody?.velocity = CGVector(dx: speed_factor*CGFloat(flight_direction), dy: speed_factor*CGFloat(flight_direction)*slope)
        } else if self.position.x <= origin.x {
            self.physicsBody?.velocity = CGVector(dx: speed_factor*CGFloat(flight_direction), dy: speed_factor*CGFloat(-1*flight_direction)*slope)
        }
        
        if self.position.y < origin.y{
            self.physicsBody?.velocity.dy = speed_factor * slope
        }
        
        if abs(self.position.x - origin.x) > a {
            self.physicsBody?.velocity = CGVector(dx: CGFloat(0), dy: CGFloat(0))
            flying = false
            movement_status = constants.finished_attack
        }
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
        
        if flying {
            findVelocity()
            return
        }
        
        // orientation update
        if(sprite_orientation == constants.orientation_left && pos.x > self.position.x){
            sprite_orientation = constants.orientation_right
            self.run(SKAction.scaleX(to: 1, duration: 0))
        } else if(sprite_orientation == constants.orientation_right && pos.x < self.position.x){
            sprite_orientation = constants.orientation_left
            self.run(SKAction.scaleX(to: -1, duration: 0))
        }

        // select animation
        if can_attack && abs(self.position.x - pos.x) <= (200) && abs(self.position.y - pos.y) <= 300 && self.position.y > pos.y{
            genFlightPath(bottom: pos)
            flying = true
            can_attack = false
            movement_status = constants.attacking
        }
        if !can_attack && movement_status != constants.idle{
            movement_status = constants.idle
            idleAnimation()
        }
    }
    
    func idleAnimation(){
        let idleFrames:[SKTexture] =
            [textureAtlas.textureNamed("eye_idle000"),
             textureAtlas.textureNamed("eye_idle001"),
             textureAtlas.textureNamed("eye_idle002"),
             textureAtlas.textureNamed("eye_idle003"),
             textureAtlas.textureNamed("eye_idle004"),
             textureAtlas.textureNamed("eye_idle005"),
             textureAtlas.textureNamed("eye_idle006"),
             textureAtlas.textureNamed("eye_idle007")]
        let idleAction = SKAction.animate(with: idleFrames,
                                         timePerFrame: 0.12)
        let reset = SKAction.run { [weak self] in
            self?.can_attack = true
        }
        self.run(SKAction.sequence([SKAction.repeat(idleAction, count: 2), reset, SKAction.repeatForever(idleAction)]), withKey: "idle")
    }
    
    func runAnimation() {
        // ugly animation, idle looks better
    }
    
    func attackAnimation(){
        let attackFrames:[SKTexture] =
            [textureAtlas.textureNamed("eye_attack000"),
             textureAtlas.textureNamed("eye_attack001"),
             textureAtlas.textureNamed("eye_attack002"),
             textureAtlas.textureNamed("eye_attack003"),
             textureAtlas.textureNamed("eye_attack004"),
             textureAtlas.textureNamed("eye_attack005"),
             textureAtlas.textureNamed("eye_attack006"),
             textureAtlas.textureNamed("eye_attack007")]
        let attackAction = SKAction.animate(with: attackFrames, timePerFrame: 0.1)
        let reset = SKAction.run { [weak self] in
            self?.movement_status = constants.finished_attack
        }
        // after attack is finished, go to idle animation for a while
        self.run(SKAction.sequence([attackAction, reset]), withKey: "attack")
    }
    
    func deathAnimation(){
        self.flying = false
        self.removeAction(forKey: "idle")
        self.removeAction(forKey: "attack")
        let deathFrames:[SKTexture] =
            [textureAtlas.textureNamed("eye_death000"),
             textureAtlas.textureNamed("eye_death001"),
             textureAtlas.textureNamed("eye_death002"),
             textureAtlas.textureNamed("eye_death003")]
        let death = SKAction.animate(with: deathFrames, timePerFrame: 0.1)
        let remove = SKAction.run { [weak self] in
            self?.removeAllChildren()
            self?.removeFromParent()
        }
        // after attack is finished, go to idle animation for a while
        self.run(SKAction.sequence([death, remove]), withKey: "death")
    }
    
    // damage functions
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
        if !flying {
            return false
        }
        let w = constants.player_width
        let h = constants.player_height
        let x1 = location.x - CGFloat(w/2)
        let y1 = location.y - CGFloat(h/2)
        let x2 = location.x + CGFloat(w/2)
        let y2 = location.y + CGFloat(h/2)
        
        // keep damaging circle smaller on purpose, enlarged only to make giving damage to eye more accurate 
        let b = checkOverlap(R: 18, Xc: self.position.x, Yc: self.position.y - CGFloat(1), X1: x1, Y1: y1, X2: x2, Y2: y2)
        if b {
            if let poison = SKEmitterNode(fileNamed: "Poison"){
                poison.particleZPosition = 10
                poison.name = "particle_delete"
                let setPoison = SKAction.run{ [weak self] in
                    self?.parent?.parent?.addChild(poison)
                    poison.targetNode = nil
                    poison.particlePosition = self?.position ?? CGPoint(x: 0, y: 0)
                }
                let del = SKAction.run { [weak self] in
                    for i in self?.parent?.parent?.children ?? []{
                        if i.name == "particle_delete" {
                            i.removeFromParent()
                        }
                    } // cooler to let the flames be in the background tbh 
                    self?.removeFromParent()
                    self?.removeAllChildren()
                    
                }
                self.run(SKAction.sequence([SKAction.fadeOut(withDuration: 0), setPoison, SKAction.fadeOut(withDuration: 0.5), del]))
            }
        }
        return b
    }
    
}

