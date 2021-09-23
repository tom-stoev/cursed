//
//  Ground.swift
//  hi
//
//  Created by Tom Stoev on 8/14/21.
//

import SpriteKit
class Ground: SKSpriteNode{
    var textureAtlas: SKTextureAtlas = SKTextureAtlas(named: "Environment")
    var initialSize = CGSize.zero
    
    private var posEdge = CGFloat()
    private var negEdge = CGFloat()
    func createChildren(texture: SKTexture) {
           self.anchorPoint = CGPoint(x: 0, y: 1)
           let texture = textureAtlas.textureNamed("brick_rough_blue") //brick_rough_blue
           var tileCount: CGFloat = 0
           let tileSize = CGSize(width: 35, height: 60)
           while tileCount * tileSize.width < self.size.width {
               let tileNode = SKSpriteNode(texture: texture)
               tileNode.size = tileSize
               tileNode.position.x = tileCount * tileSize.width
               tileNode.anchorPoint = CGPoint(x: 0, y: 1)
                self.addChild(tileNode)
                tileCount += 1
           }
        createBoundary(h: 0)
   }
    
    func createBoundary(h: CGFloat){
        self.physicsBody = SKPhysicsBody(edgeFrom: CGPoint(x: 0, y: h), to: CGPoint(x: size.width, y: h))
        self.physicsBody?.friction = 0.3
        self.physicsBody?.restitution = 0
        self.physicsBody?.categoryBitMask = physicsCategory.ground.rawValue
    }

 }
