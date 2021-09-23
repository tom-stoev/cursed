//
//  Fox.swift
//  hi
//
//  Created by Tom Stoev on 8/11/21.
//


// USE FOR LATER STATUS EFFECT


import SpriteKit
class Fox: SKSpriteNode, Entity{
    private var initialSize: CGSize = CGSize(width: 65, height: 65)
    private var textureAtlas: SKTextureAtlas = SKTextureAtlas(named: "Fox")
    private var sprite_orientation = constants.orientation_left
    private var movement_status = constants.idle
    
    private var last_dir = constants.orientation_left
    private let max_velocity = CGFloat(500)
    
    private var gave_power = false
    private var has_transformed = false
    private var offer = SKLabelNode(fontNamed: "Chalkduster")
    private var hint = SKLabelNode()
    private var see_again = SKLabelNode()
    
    init() {
        super.init(texture: nil, color: .clear, size: initialSize)
        idleAnimation()
        self.run(SKAction.scaleX(to: -1, duration: 0))
        self.physicsBody = SKPhysicsBody(circleOfRadius: 16, center: CGPoint(x: self.position.x, y: self.position.y-16))
        self.name = "update_fox"
        self.physicsBody?.restitution = 0
        self.physicsBody?.friction = 0.8
        self.physicsBody?.allowsRotation = false
        self.physicsBody?.linearDamping = 0.5
        self.physicsBody?.mass = 0.1
        self.zPosition = 1
        self.alpha = 1
        self.physicsBody?.categoryBitMask = physicsCategory.fox.rawValue
        self.physicsBody?.collisionBitMask = physicsCategory.ground.rawValue 
        self.physicsBody?.contactTestBitMask = physicsCategory.enemy.rawValue
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func addIndicators() {
        // don't need
    }
    
    func lastDirection(orientation: Int){
        last_dir = orientation
    }
    func getMovementStatus()->Int{
        return self.movement_status
    }
    
    func avoidGrantingPower() {
        gave_power = true
    }
    
    func hasTransformed()->Bool{
       return has_transformed
    }
    
    func transform() {
        has_transformed = true
        offer.run(SKAction.scaleX(to: CGFloat(-1), duration: 0))
        offer.position = CGPoint(x: CGFloat(150), y: CGFloat(130))
        offer.fontSize = 28
        offer.text =  "The power I lent you helped didn't it?" //offer.text =  "I have come for my possession"
        offer.alpha = 0
        self.addChild(offer)
        
        let change = SKAction.run { [weak self] in
            self?.offer.fontColor = .red
            self?.offer.fontSize = 34
            self?.offer.text = "now I've come for something"
        }
        
        let change2 = SKAction.run { [weak self] in
            self?.offer.fontColor = .black
            self?.offer.fontSize = 34
            self?.offer.text = "your soul"
        }
        
        let del = SKAction.run { [weak self] in
            self?.offer.removeFromParent()
        }
        
        let changeTexture = SKAction.run{ [weak self] in
            self?.removeAction(forKey: "idle")
            self?.texture = SKTextureAtlas(named: "Malphas").textureNamed("malphas_idle000")
        }
        
        let spawnMalphas = SKAction.run{ [weak self] in
            if let gameScene = self?.parent?.parent as? GameScene {
                gameScene.spawnMalphas()
            }
            self?.removeFromParent()
        }
        let scaling = SKAction.group([SKAction.scaleX(to: -2.5, duration: 1), SKAction.scaleY(to: 2.5, duration: 1)])
        
        let morph = SKAction.sequence([scaling, SKAction.colorize(with: .black, colorBlendFactor: CGFloat(1), duration: 1), changeTexture, SKAction.fadeIn(withDuration: 1), spawnMalphas])
        let beginTransform = SKAction.run{ [weak self] in
            self?.run(morph)
        }
        
        let dialogue = SKAction.sequence([SKAction.fadeOut(withDuration: 2), SKAction.fadeIn(withDuration: 2), SKAction.fadeOut(withDuration: 2), change, SKAction.fadeIn(withDuration: 2), SKAction.fadeOut(withDuration: 2), change2, SKAction.fadeIn(withDuration: 2), del, beginTransform])
        
        offer.run(dialogue)
        
    }
    
    func update(pos: CGPoint, status: Bool, orientation: Int, damage: Int){
        if self.position.x > 200 {
            self.physicsBody?.applyImpulse(CGVector(dx: -1, dy: 0))
        } else if !gave_power && self.physicsBody?.velocity.dx == 0{
            offerContract()
            gave_power = true
        }
        
        // determine correct animation
        if(self.physicsBody!.velocity.dy != 0){
            self.removeAction(forKey: "idle")
            self.removeAction(forKey: "run")
            if(movement_status != constants.jumping){
                movement_status = constants.jumping
            jumpAnimation()
            }
        } 
        else if(self.physicsBody!.velocity.dx != 0){
            self.removeAction(forKey: "idle")
            self.removeAction(forKey: "jump")
            // additional code to determine other animations
            if(movement_status != constants.is_running){
                runAnimation()
                movement_status = constants.is_running
            }
            
        } else {
            self.removeAction(forKey: "run")
            self.removeAction(forKey: "jump")
            if(movement_status != constants.idle){
            idleAnimation()
                movement_status = constants.idle
            self.physicsBody!.velocity = CGVector(dx: 0, dy: 0)
            }
        }
    }
    
    // ANIMATIONS
    
    func idleAnimation(){
        let foxFrames:[SKTexture] = [textureAtlas.textureNamed("fox000"), textureAtlas.textureNamed("fox001"),textureAtlas.textureNamed("fox002"),textureAtlas.textureNamed("fox003"),textureAtlas.textureNamed("fox004")]
        let waiveAction = SKAction.animate(with: foxFrames, timePerFrame: 0.15)
        self.run(SKAction.repeatForever(waiveAction), withKey: "idle")    
    }
 
    func runAnimation(){
        let foxFrames:[SKTexture] = [textureAtlas.textureNamed("fox028"),
                                     textureAtlas.textureNamed("fox029"),
                                     textureAtlas.textureNamed("fox030"),
                                     textureAtlas.textureNamed("fox031"),
                                     textureAtlas.textureNamed("fox032"),
                                     textureAtlas.textureNamed("fox033"),
                                     textureAtlas.textureNamed("fox034"),
                                     textureAtlas.textureNamed("fox035")]
        let runAction = SKAction.animate(with: foxFrames, timePerFrame: 0.10)
        self.run(SKAction.repeatForever(runAction), withKey: "run")
    }

    func jumpAnimation(){
        let foxFrames:[SKTexture] = [textureAtlas.textureNamed("fox045"),
                                     textureAtlas.textureNamed("fox046"),
                                     textureAtlas.textureNamed("fox047"),
                                     textureAtlas.textureNamed("fox048"),
                                     textureAtlas.textureNamed("fox049"),
                                     textureAtlas.textureNamed("fox050"),
                                     textureAtlas.textureNamed("fox051"),
                                     textureAtlas.textureNamed("fox052")]
        let jumpAction = SKAction.animate(with: foxFrames, timePerFrame: 0.1)
        self.run(jumpAction, withKey: "jump")
    }
    
    func attackAnimation(){
        
    }
    
    func damageAnimation(){
        let reset = SKAction.run { [weak self] in
            self?.physicsBody?.categoryBitMask = physicsCategory.fox.rawValue
        }
        let damageEnd = (SKAction.fadeIn(withDuration: 0.15))
        let damageStart = (SKAction.fadeOut(withDuration: 0.15))
        let flashAnimate = SKAction.repeat(SKAction.sequence([damageStart, damageEnd]), count: 8)
        let damaged = SKAction.sequence([flashAnimate, reset])
        self.run(damaged)
    }
    
    func deathAnimation(){
    }
    
    func bidFarewell(){
        let change = SKAction.run{ [weak self] in
            self?.offer.text = "I bid you farewell"
        }
        
        let delFox = SKAction.run { [weak self] in
            self?.offer.removeFromParent()
            self?.removeFromParent()
            
        }
        offer.run(SKAction.sequence([SKAction.fadeOut(withDuration: 1), change, SKAction.fadeIn(withDuration: 1), SKAction.fadeOut(withDuration: 1), delFox]))
    }
    
    func takeDamage(dmg: Int) {
        // do nothing
    }
    
    func offerContract(){ // not really an offer ...
        offer.fontSize = 26
        offer.fontColor = .white
        offer.alpha = 1
        offer.text = ""
        offer.zPosition = 10
        offer.position = CGPoint(x: CGFloat(200), y: CGFloat(150))
        offer.run(SKAction.scaleX(to: CGFloat(-1), duration: 0))
        
        self.addChild(offer)
        let change =  SKAction.run{ [weak self] in
            self?.offer.text = "A great foe lies ahead ..."
        }
        let change2 =  SKAction.run{ [weak self] in
            self?.offer.text = "I will lend you "
        }
        let change3 =  SKAction.run{ [weak self] in
            self?.offer.text = "a portion of my power"
        }
        let change4 =  SKAction.run{ [weak self] in
            self?.offer.text = " in exchange ... "
        } // I get to take one of your possesions
        
        let change5 =  SKAction.run{ [weak self] in
            self?.offer.text = "I get one of your possesions"
        }
        
        let change6 =  SKAction.run{ [weak self] in
            self?.offer.text = "whatever it may be"
        }
        
        let adios = SKAction.run { [weak self] in
            self?.bidFarewell()
            if let gameScene = self?.parent?.parent as? GameScene {
                gameScene.setOP()
            }
        }
        let next = SKAction.sequence([SKAction.fadeOut(withDuration: 1), change, SKAction.fadeIn(withDuration: 1), SKAction.fadeOut(withDuration: 1), change2, SKAction.fadeIn(withDuration: 1), SKAction.fadeOut(withDuration: 1), change3, SKAction.fadeIn(withDuration: 1), SKAction.fadeOut(withDuration: 1), change4, SKAction.fadeIn(withDuration: 1), SKAction.fadeOut(withDuration: 1), change5, SKAction.fadeIn(withDuration: 1), SKAction.fadeOut(withDuration: 1), change6, SKAction.fadeIn(withDuration: 1), SKAction.fadeOut(withDuration: 1), adios])
        offer.run(next)
    }
    
    
    
    func takeDamage() -> Bool{
        return false 
    }
    
    
}
