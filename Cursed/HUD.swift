//
//  HUD.swift
//  hi
//
//  Created by Tom Stoev on 8/17/21.
//

import SpriteKit
class HUD: SKNode{
    private var textureAtlas: SKTextureAtlas = SKTextureAtlas(named: "hud&menu")
    
    private var left_button = SKSpriteNode()
    private var right_button = SKSpriteNode()
    private var jump_button = SKSpriteNode()
    private var attack_button = SKSpriteNode()
    private var livesLabel = SKLabelNode(fontNamed: "Chalkduster")
    private var dmgLabel = SKLabelNode(fontNamed: "Chalkduster")
    private var hpGainedLabel = SKLabelNode(fontNamed: "Chalkduster")
    private var lvlLabel = SKLabelNode(fontNamed: "Chalkduster")
    private var timer = SKLabelNode(fontNamed: "Chalkduster")
    
    private var square1 = SKSpriteNode()
    private var square2 = SKSpriteNode()
    private var square3 = SKSpriteNode()
    private var square4 = SKSpriteNode()
    
    private  let restartButton = SKSpriteNode()
    private  let menuButton = SKSpriteNode()
    
    private var last_lives = 0
    private var absolute_time = Int(0)
    
    private var heart = SKSpriteNode()
    var cameraOrigin = CGPoint()
    
    func createHudNodes(screenSize: CGSize){
        cameraOrigin = CGPoint(x: screenSize.width / 2, y: screenSize.height / 2)
        
        heart = SKSpriteNode(texture: textureAtlas.textureNamed("heart_2"))
        heart.size = CGSize (width: 45, height: 45)
        heart.run(SKAction.colorize(with: UIColor(red: CGFloat(0.345), green: CGFloat(0.004), blue: CGFloat(0.086), alpha: 1), colorBlendFactor: CGFloat(0.6), duration: 0))
        // rgba(88,1,22,255)
        let xP = -cameraOrigin.x + CGFloat(80)
        let yP = cameraOrigin.y - 75
        heart.position = CGPoint(x: xP, y: yP)
        
        let expand = SKAction.scale(to: 1.15, duration: 1)
        let contract = SKAction.scale(to: 1/1.15, duration: 1)
        let ordering = SKAction.sequence([expand, contract])
        self.heart.run(SKAction.repeatForever(ordering), withKey: "idle")
        self.addChild(heart)
        

        let configuration = UIImage.SymbolConfiguration(pointSize: 25, weight: .regular, scale: .large)
        guard let b1 = UIImage(systemName: "arrow.left.square", withConfiguration: configuration) else { return  }
        let texture = SKTexture(image: b1)
        left_button = SKSpriteNode(texture: texture, size: CGSize(width: 70, height: 65))
        left_button.position = CGPoint(x: -cameraOrigin.x + CGFloat(91), y: -cameraOrigin.y + 40)
        left_button.zPosition = 11
        left_button.name = "left"
        self.addChild(left_button)
        square1 = SKSpriteNode(color: UIColor(red: CGFloat(0.788), green: CGFloat(0), blue: CGFloat(0.251), alpha:  CGFloat(0.46)), size: CGSize(width: CGFloat(60), height: CGFloat(58)))
        square1.name = "left_square"
        square1.zPosition = 10
        square1.position = CGPoint(x: -cameraOrigin.x + CGFloat(91), y: -cameraOrigin.y + 40)
        self.addChild(square1)
        
        
        
        
        guard let b2 = UIImage(systemName: "arrow.right.square", withConfiguration: configuration) else { return  }
        let texture2 = SKTexture(image: b2)
        right_button = SKSpriteNode(texture: texture2, size: CGSize(width: 70, height: 65))
        right_button.position = CGPoint(x: -cameraOrigin.x + CGFloat(185), y: -cameraOrigin.y + 40)
        right_button.zPosition = 11
        right_button.name = "right"
        self.addChild(right_button)
        square2 = SKSpriteNode(color: UIColor(red: CGFloat(0.788), green: CGFloat(0), blue: CGFloat(0.251), alpha:  CGFloat(0.46)), size: CGSize(width: CGFloat(60), height: CGFloat(58)))
        square2.name = "right_square"
        square2.zPosition = 10
        square2.position = CGPoint(x: -cameraOrigin.x + CGFloat(185), y: -cameraOrigin.y + 40)
        self.addChild(square2)
        
        
        
        
        
        guard let b3 = UIImage(systemName: "arrow.up.square", withConfiguration: configuration) else { return  }
        let texture3 = SKTexture(image: b3)
        jump_button = SKSpriteNode(texture: texture3, size: CGSize(width: 70, height: 65))
        jump_button.position = CGPoint(x: cameraOrigin.x - CGFloat(91), y: -cameraOrigin.y + 40)
        jump_button.zPosition = 11
        jump_button.name = "jump"
        self.addChild(jump_button)
        square3 = SKSpriteNode(color: UIColor(red: CGFloat(0.788), green: CGFloat(0), blue: CGFloat(0.251), alpha:  CGFloat(0.46)), size: CGSize(width: CGFloat(60), height: CGFloat(58)))
        square3.name = "jump_square"
        square3.zPosition = 10
        square3.position = CGPoint(x: cameraOrigin.x - CGFloat(91), y: -cameraOrigin.y + 40)
        self.addChild(square3)
        
        
        
        guard let b4 = UIImage(systemName: "multiply.square", withConfiguration: configuration) else { return  }
        let texture4 = SKTexture(image: b4)
        attack_button = SKSpriteNode(texture: texture4, size: CGSize(width: 70, height: 65))
        attack_button.position = CGPoint(x: cameraOrigin.x - CGFloat(185), y: -cameraOrigin.y + 40)
        attack_button.zPosition = 11
        attack_button.name = "attack"
        self.addChild(attack_button)    // old alpha = 0.46
        square4 = SKSpriteNode(color: UIColor(red: CGFloat(0.788), green: CGFloat(0), blue: CGFloat(0.251), alpha:  CGFloat(0.46)), size: CGSize(width: CGFloat(60), height: CGFloat(58)))
        square4.name = "attack_square"
        square4.zPosition = 10
        square4.position = CGPoint(x: cameraOrigin.x - CGFloat(185), y: -cameraOrigin.y + 40)
        self.addChild(square4)
        
        
        
        livesLabel.fontColor = .white
        livesLabel.fontSize = 35
        livesLabel.zPosition = 20
        //livesLabel.text = "x25"
        livesLabel.position = CGPoint(x: -cameraOrigin.x + 150, y: cameraOrigin.y - 80)
        self.addChild(livesLabel)
        
        dmgLabel.fontColor = .red
        dmgLabel.fontSize = 35
        dmgLabel.position = CGPoint(x: -cameraOrigin.x + 220, y: cameraOrigin.y - 80)
        self.addChild(dmgLabel)
        
        hpGainedLabel.fontColor = .green
        hpGainedLabel.fontSize = 35
        hpGainedLabel.position = CGPoint(x: -cameraOrigin.x + 320, y: cameraOrigin.y - 80)
        self.addChild(hpGainedLabel)
        
        lvlLabel.fontColor = .white
        lvlLabel.fontSize = 35
        lvlLabel.position = CGPoint(x: cameraOrigin.x - 100, y: cameraOrigin.y - 70)
        self.addChild(lvlLabel)
        
        restartButton.texture = textureAtlas.textureNamed("start")
        menuButton.texture = textureAtlas.textureNamed("start")
        restartButton.name = "restart_button"
        menuButton.name = "menu_button"
        restartButton.position = CGPoint(x: 0, y: 40)
        menuButton.position = CGPoint(x: 0, y: -100)
        restartButton.size = CGSize(width: 200, height: 80)
        restartButton.zPosition = 10
        menuButton.zPosition = 10
        menuButton.size = CGSize(width: 100, height: 55)
        
        
        let restartText = SKLabelNode(fontNamed: "Chalkduster")
        restartText.name = "restart_text"
        restartText.text = "RESTART"
        restartText.verticalAlignmentMode = .center
        restartText.position = CGPoint(x: 0, y: 2)
        restartText.fontSize = 33
        restartText.zPosition = 11
        restartButton.addChild(restartText)
        
        let menuText = SKLabelNode(fontNamed: "Chalkduster")
        menuText.name = "menu_text"
        menuText.text = "menu"
        menuText.verticalAlignmentMode = .center
        menuText.position = CGPoint(x: 0, y: 2)
        menuText.fontSize = 28
        menuText.zPosition = 11
        menuButton.addChild(menuText)
        
        timer.fontSize = 35
        timer.fontColor = .white
        timer.position = CGPoint(x: cameraOrigin.x - 100, y: cameraOrigin.y - 120)
        var seconds_time = Int(0)
        timer.text = "0:00"
        let wait = SKAction.wait(forDuration: 1)
        let inc = SKAction.run { [weak self] in
            self?.absolute_time += 1
            let minutes = self!.absolute_time/60
            seconds_time = self!.absolute_time % 60
            if seconds_time < 10 {
                self?.timer.text = "\(minutes):0\(seconds_time)"
            } else {
                self?.timer.text = "\(minutes):\(seconds_time)"
            }
        }
        
        timer.run(SKAction.repeatForever(SKAction.sequence([wait, inc])), withKey: "timer")
        
        self.addChild(timer)
        
    }
    
    func updateLives(lives: Int){
        if last_lives - lives > 0 {
            dmgLabel.text = "-\(last_lives-lives)"
            let reset = SKAction.run { [weak self] in
                self?.dmgLabel.text = " "
            }
            dmgLabel.run(SKAction.sequence([SKAction.fadeOut(withDuration: 0.4), reset, SKAction.fadeIn(withDuration: 0.4)]))
        } else {
            hpGainedLabel.text = "+\(lives-last_lives)"
            let reset = SKAction.run { [weak self] in
                self?.hpGainedLabel.text = " "
            }
            hpGainedLabel.run(SKAction.sequence([SKAction.fadeOut(withDuration: 0.4), reset, SKAction.fadeIn(withDuration: 0.4)]))
        }
        livesLabel.text = "\(lives)"
        last_lives = lives
//        let reset = SKAction.run { [weak self] in
//            self?.dmgLabel.text = " "
//        }
//        dmgLabel.run(SKAction.sequence([SKAction.fadeOut(withDuration: 1), reset, SKAction.fadeIn(withDuration: 1)]))
    }
    
    func startHud(lives: Int, lvl: Int){
        lvlLabel.text = "lvl. \(lvl)"
        livesLabel.text = "\(lives)"
        last_lives = lives
    }
    
    func updateLevel(lvl: Int){
        lvlLabel.text = "lvl. \(lvl)"
        if lvl > 5 {
            lvlLabel.text = "end"
        }
    }
    
    func showScore(level: Int){
        let level_bonus = SKLabelNode(fontNamed: "Copperplate-Light")
        level_bonus.position = CGPoint(x: -185, y: cameraOrigin.y - 60)
        level_bonus.fontColor = .white
        level_bonus.text = "(level bonus)      +\(100*(level-1)) "
        level_bonus.fontSize = 35
        level_bonus.horizontalAlignmentMode = .left
        level_bonus.zPosition = 15
        self.addChild(level_bonus)
        
        let score = SKLabelNode(fontNamed: "Copperplate-Light")
        score.position = CGPoint(x: -185, y: cameraOrigin.y - 85)
        score.fontColor = .white
        score.horizontalAlignmentMode = .left
        score.text = "Score:                 \(100*(level-1))"
        score.fontSize = 35
        self.addChild(score)
    }
    
    func showButtons(){
        restartButton.alpha = 0
        menuButton.alpha = 0
        self.addChild(restartButton)
        self.addChild(menuButton)
        let fadeAnimation = SKAction.fadeAlpha(to: 1, duration: 0.4)
        restartButton.run(fadeAnimation)
        menuButton.run(fadeAnimation)
    }
    
    func removeButtons(){
        for i in self.children {
            if i.name ==
                "jump" || i.name ==
             "jump_square" || i.name ==
             "attack" || i.name ==
             "attack_square" || i.name ==
             "left" || i.name ==
             "left_square" || i.name ==
             "right" || i.name ==
                "right_square" {
                i.removeFromParent()
            }
        }
    }
    
    func getTime()->Int{
        timer.removeAction(forKey: "timer")
        return absolute_time
    }


    
}
