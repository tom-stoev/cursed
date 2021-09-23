//
//  Platform.swift
//  hi
//
//  Created by Tom Stoev on 8/21/21.
//

import SpriteKit
// TODO LIST:

// fix malphas AI
// test on various phone screens -> launch on TestFlight
// what to test?
// : button positions
// : dialogue positions
// : credits scene
// : boundaries for lvl 2 


// run through game on 5 different sims
// then VVVVVV
// launch on TestFlight


class Platform: SKSpriteNode {
    let textureAtlas = SKTextureAtlas(named: "Environment")
    let initialSize = CGSize(width: 300, height: 45)
    var initialX = CGFloat(-5000)
    init() {
        super.init(texture: nil, color: .clear, size:initialSize)
        createSelf()
        self.name = "platform"
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        //fatalError("init(coder:) has not been implemented")
    }
    
    func createSelf() {
            self.anchorPoint = CGPoint(x: 0, y: 1)
            let texture = textureAtlas.textureNamed("brick_rough_blue") //brick_rough_blue
            var tileCount: CGFloat = 0
            let tileSize = CGSize(width: 50, height: 30)
        while tileCount * tileSize.width < initialSize.width {
                let tileNode = SKSpriteNode(texture: texture)
                tileNode.size = CGSize(width: CGFloat(50), height: CGFloat(30))
                tileNode.position.x = tileCount * tileSize.width
                tileNode.anchorPoint = CGPoint(x: 0, y: 1)
                 self.addChild(tileNode)
                 tileCount += 1
            }
             
     self.physicsBody = SKPhysicsBody(edgeFrom: CGPoint(x: 0,y: 0), to: CGPoint(x: size.width, y: 0))
        let rec = CGRect(x: 0, y: -30, width: 300, height: 30)
        //var transform = CGAffineTransform.identity
        let path = CGPath(rect: rec, transform: nil)
        self.physicsBody = SKPhysicsBody(edgeLoopFrom: path)
        self.physicsBody?.friction = 0.3
     self.physicsBody?.restitution = 0
     self.physicsBody?.categoryBitMask = physicsCategory.ground.rawValue
    }

}




