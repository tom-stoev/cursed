//
//  File.swift
//  hi
//
//  Created by Tom Stoev on 8/17/21.
//

import SpriteKit

class Ledge: SKSpriteNode{
    let initialSize = CGSize(width: 300, height: 50)
    let textureAtlas = SKTextureAtlas(named: "Environment")
    
    init(){
        super.init(texture: nil, color: .clear, size:initialSize)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
}

