//
//  Heart.swift
//  hi
//
//  Created by Tom Stoev on 8/16/21.
//

import SpriteKit
class Heart: SKSpriteNode{
    
    var textureAtlas: SKTextureAtlas = SKTextureAtlas(named: "Status Effects")
    var initialSize: CGSize = CGSize(width: 45, height: 45)
    init(){
        super.init(texture: textureAtlas.textureNamed("heart"), color: .clear, size: initialSize)
        self.zPosition = 1
        idleAnimation()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    func idleAnimation(){
        let expand = SKAction.scale(to: 1.15, duration: 1)
        let contract = SKAction.scale(to: 1/1.15, duration: 1)
        let ordering = SKAction.sequence([expand, contract])
        self.run(SKAction.repeatForever(ordering), withKey: "idle")
    }
    
    func playerDied(){
        
    }
    func update(pos: CGFloat, lives: Int){
        self.position = CGPoint(x: -315 + pos, y: 305)
    }
}
