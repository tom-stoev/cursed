//
//  HealthPotion.swift
//  hi
//
//  Created by Tom Stoev on 9/6/21.
//

import SpriteKit

class HealthPotion: SKSpriteNode{
    let initialSize = CGSize(width: 50, height: 50)
    var healing_power = 10
    init() {
        super.init(texture: nil, color: .clear, size: initialSize)
        self.name = "potion"
        self.zPosition = 7
        self.physicsBody = SKPhysicsBody(circleOfRadius: 15)
        self.physicsBody?.contactTestBitMask = 0
        self.physicsBody?.collisionBitMask = physicsCategory.ground.rawValue
        self.physicsBody?.categoryBitMask = physicsCategory.misc.rawValue
        self.physicsBody?.allowsRotation = false 
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func setRegular(){
        self.texture = SKTexture(imageNamed: "hp_potion")
        healing_power = 10
    }
    
    func setLarge(){
        self.texture = SKTexture(imageNamed: "hp_m_potion")
        healing_power = 20
    }
    
    func setExalted(){
        self.texture = SKTexture(imageNamed: "hp_L_potion")
        healing_power = 50
    }
    
    func getRegen()->Int{
        return healing_power
    }
    
    
}
