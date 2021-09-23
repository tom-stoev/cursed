//
//  CreditScene.swift
//  hi
//
//  Created by Tom Stoev on 9/9/21.
//

import SpriteKit
import SwiftUI

class CreditScene: SKScene {
    let main_title = SKLabelNode()
    let title = SKLabelNode()
    let title2 = SKLabelNode()
    
    var should_play_animation = true 
    
    let c1 = SKLabelNode()
    let c2 = SKLabelNode()
    let c3 = SKLabelNode()
    let c4 = SKLabelNode()
    let c5 = SKLabelNode()
    let c6 = SKLabelNode()
    let c7 = SKLabelNode()
    let c8 = SKLabelNode()
    
    let c11 = SKLabelNode()
    let c12 = SKLabelNode()
    let c13 = SKLabelNode()
    let c14 = SKLabelNode()
    let c15 = SKLabelNode()
    let c16 = SKLabelNode()
    
    override func didMove(to view: SKView) {
        
        let bg = SKSpriteNode(imageNamed: "woods")
        bg.size = UIScreen.main.bounds.size
        bg.position = CGPoint(x: self.size.width/2, y: self.size.height/2)
        self.addChild(bg)
        
        title.text = "Sprite Textures: "
        title.name = "0"
        title.fontName = "AppleSDGothicNeo-Bold"
        title.fontSize = 30
        title.fontColor = .white
        title.zPosition = 2
        title.horizontalAlignmentMode = .left
        title.position = CGPoint(x: 15, y: self.size.height - 90)
        self.addChild(title)
        
        
        
        
        c1.text = "https://www.creativegameassets.com/"
        c1.name = "1"
        c1.fontName = "AppleSDGothicNeo-Bold"
        c1.fontSize = 15
        c1.fontColor = .white
        c1.zPosition = 2
        c1.horizontalAlignmentMode = .left
        c1.position = CGPoint(x: 15, y: self.size.height - 120)
        self.addChild(c1)
        
        c2.text = "https://admurin.itch.io"
        c2.name = "2"
        c2.fontName = "AppleSDGothicNeo-Bold"
        c2.fontSize = 15
        c2.fontColor = .white
        c2.zPosition = 2
        c2.horizontalAlignmentMode = .left
        c2.position = CGPoint(x: 15, y: self.size.height - 140)
        self.addChild(c2)
        
        c3.text = "https://luizmelo.itch.io"
        c3.name = "3"
        c3.fontName = "AppleSDGothicNeo-Bold"
        c3.fontSize = 15
        c3.fontColor = .white
        c3.zPosition = 2
        c3.horizontalAlignmentMode = .left
        c3.position = CGPoint(x: 15, y: self.size.height - 160)
        self.addChild(c3)
        
        c4.text = "https://elthen.itch.io"
        c4.name = "4"
        c4.fontName = "AppleSDGothicNeo-Bold"
        c4.fontSize = 15
        c4.fontColor = .white
        c4.zPosition = 2
        c4.horizontalAlignmentMode = .left
        c4.position = CGPoint(x: 15, y: self.size.height - 180)
        self.addChild(c4)
        
        c5.text = "https://oco.itch.io"
        c5.name = "5"
        c5.fontName = "AppleSDGothicNeo-Bold"
        c5.fontSize = 15
        c5.fontColor = .white
        c5.zPosition = 2
        c5.horizontalAlignmentMode = .left
        c5.position = CGPoint(x: 15, y: self.size.height - 200)
        self.addChild(c5)
        
        c6.text = "https://creativekind.itch.io"
        c6.name = "6"
        c6.fontName = "AppleSDGothicNeo-Bold"
        c6.fontSize = 15
        c6.fontColor = .white
        c6.zPosition = 2
        c6.horizontalAlignmentMode = .left
        c6.position = CGPoint(x: 15, y: self.size.height - 220)
        self.addChild(c6)
        
        c7.text = "https://craigsnedeker.itch.io"
        c7.name = "7"
        c7.fontName = "AppleSDGothicNeo-Bold"
        c7.fontSize = 15
        c7.fontColor = .white
        c7.zPosition = 2
        c7.horizontalAlignmentMode = .left
        c7.position = CGPoint(x: 15, y: self.size.height - 240)
        self.addChild(c7)
        
        c8.text = "https://sanctumpixel.itch.io"
        c8.name = "7"
        c8.fontName = "AppleSDGothicNeo-Bold"
        c8.fontSize = 15
        c8.fontColor = .white
        c8.zPosition = 2
        c8.horizontalAlignmentMode = .left
        c8.position = CGPoint(x: 15, y: self.size.height - 260)
        self.addChild(c8)
        
        title2.text = "Background Images: "
        title2.name = "0"
        title2.fontName = "AppleSDGothicNeo-Bold"
        title2.fontSize = 30
        title2.fontColor = .white
        title2.zPosition = 2
        title2.horizontalAlignmentMode = .left
        title2.position = CGPoint(x: self.size.width/2 + 50, y: self.size.height - 90)
        self.addChild(title2)
        
        
        c11.text = "https://aethrall.itch.io"
        c11.fontName = "AppleSDGothicNeo-Bold"
        c11.fontSize = 15
        c11.fontColor = .white
        c11.zPosition = 2
        c11.horizontalAlignmentMode = .left
        c11.position = CGPoint(x: self.size.width/2 + 50, y: self.size.height - 120)
        self.addChild(c11)
        
        c12.text = "https://miontomaru.itch.io"
        c12.fontName = "AppleSDGothicNeo-Bold"
        c12.fontSize = 15
        c12.fontColor = .white
        c12.zPosition = 2
        c12.horizontalAlignmentMode = .left
        c12.position = CGPoint(x: self.size.width/2 + 50, y: self.size.height - 140)
        self.addChild(c12)
        
        c13.text = "https://saurabhkgp.itch.io"
        c13.fontName = "AppleSDGothicNeo-Bold"
        c13.fontSize = 15
        c13.fontColor = .white
        c13.zPosition = 2
        c13.horizontalAlignmentMode = .left
        c13.position = CGPoint(x: self.size.width/2 + 50, y: self.size.height - 160)
        self.addChild(c13)
        
        c14.text = "https://ansimuz.itch.io"
        c14.fontName = "AppleSDGothicNeo-Bold"
        c14.fontSize = 15
        c14.fontColor = .white
        c14.zPosition = 2
        c14.horizontalAlignmentMode = .left
        c14.position = CGPoint(x: self.size.width/2 + 50, y: self.size.height - 180)
        self.addChild(c14)
        
        c15.text = "https://thewisehedgehog.itch.io"
        c15.fontName = "AppleSDGothicNeo-Bold"
        c15.fontSize = 15
        c15.fontColor = .white
        c15.zPosition = 2
        c15.horizontalAlignmentMode = .left
        c15.position = CGPoint(x: self.size.width/2 + 50, y: self.size.height - 200)
        self.addChild(c15)
        
        
        let menuButton = SKSpriteNode()
        menuButton.texture = SKTextureAtlas(named: "hud&menu").textureNamed("start")
        menuButton.name = "menu_button"
        menuButton.position = CGPoint(x: self.size.width/2, y: 70)
        menuButton.zPosition = 2
        menuButton.size = CGSize(width: 100, height: 55)
        
        let menuText = SKLabelNode(fontNamed: "Chalkduster")
        menuText.name = "menu_text"
        menuText.text = "menu"
        menuText.verticalAlignmentMode = .center
        menuText.position = CGPoint(x: 0, y: 2)
        menuText.fontSize = 28
        menuText.zPosition = 11
        menuButton.addChild(menuText)
        self.addChild(menuButton)
    }
    
    func disableAnimation(){
        should_play_animation = false
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            let location = touch.location(in: self)
            let nodeTouched = atPoint(location)
            
            if nodeTouched.name == "menu_button" || nodeTouched.name == "menu_text"{
                let menu = MenuScene(size: self.size)
                if !should_play_animation {
                    menu.dontPlayAnimation()
                }
                self.view?.presentScene(MenuScene(size: self.size), transition: .crossFade(withDuration: 0.6))
            }
        }
    }
    
}

/*
  ::::CREDITS::::
 heart icon: https://www.creativegameassets.com/
 buttons: https://www.creativegameassets.com/
 health potions: https://admurin.itch.io
 Wizard: https://luizmelo.itch.io
 Wizard2: https://luizmelo.itch.io
 Samurai: https://luizmelo.itch.io
 Eye: https://luizmelo.itch.io
 Mushroom: https://luizmelo.itch.io
 Fox: https://elthen.itch.io
 Santa: https://oco.itch.io
 Malphas: https://creativekind.itch.io
 Portal: https://elthen.itch.io
 Ground texture: https://craigsnedeker.itch.io
 lightning: https://sanctumpixel.itch.io
 
 Background images:
 demon woods: https://aethrall.itch.io (level 1)
 destroyed city: https://miontomaru.itch.io (level 2)
 dawn: https://saurabhkgp.itch.io (level 3/5)
 cyber punk: https://ansimuz.itch.io (start/end)
 warped city: https://ansimuz.itch.io (level 4)
 night: https://swapnilrane24.itch.io
 midnight: https://thewisehedgehog.itch.io
 
 MUSIC: https://www.dl-sounds.com/royalty-free/bobber-loop/
 
 
 ::::CREDITS::::
 https://www.creativegameassets.com/
 https://admurin.itch.io
 https://luizmelo.itch.io
 https://elthen.itch.io
 https://oco.itch.io
 https://creativekind.itch.io
 https://craigsnedeker.itch.io
 https://aethrall.itch.io
 https://miontomaru.itch.io
 https://saurabhkgp.itch.io
 https://ansimuz.itch.io
 https://sanctumpixel.itch.io
 
 
 */

