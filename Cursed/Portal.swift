//
//  Entrance.swift
//  hi
//
//  Created by Tom Stoev on 8/26/21.
//

import SpriteKit

class Portal: SKSpriteNode{
    let textureAtlas = SKTextureAtlas(named: "Portal")
    let initialSize = CGSize(width: 125, height: 150)
    init() {
        super.init(texture: nil, color: .clear, size: initialSize)
        idleAnimation()
        self.name = "portal"
        self.zPosition = 7
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func idleAnimation(){
        let portalFrames:[SKTexture]=[textureAtlas.textureNamed("portal000"),
                                      textureAtlas.textureNamed("portal001"),
                                      textureAtlas.textureNamed("portal002"),
                                      textureAtlas.textureNamed("portal003"),
                                      textureAtlas.textureNamed("portal004"),
                                      textureAtlas.textureNamed("portal005"),
                                      textureAtlas.textureNamed("portal006"),
                                      textureAtlas.textureNamed("portal007")]
         let idleAction = SKAction.animate(with: portalFrames, timePerFrame: 0.20)
         self.run(SKAction.repeatForever(idleAction), withKey: "idle")
    }
    
}
