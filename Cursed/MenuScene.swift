//
//  MenuScene.swift
//  hi
//
//  Created by Tom Stoev on 8/17/21.
//

import SpriteKit
import GameKit
class MenuScene: SKScene, GKGameCenterControllerDelegate{
    
    let textureAtlas = SKTextureAtlas(named: "hud&menu")
    let startButton = SKSpriteNode()
    let creditsButton = SKSpriteNode()
    let highScore = SKSpriteNode()
    let waiting_text = SKLabelNode(fontNamed: "Chalkduster")
    
    var play_start_animation = true
    var leaderboardText: SKLabelNode!
    
    var is_authenticated = false
    
    override func didMove(to view: SKView) {
        self.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        let background = SKSpriteNode(imageNamed: "front")
        background.size = CGSize(width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height)
        background.zPosition = -1
        self.addChild(background)
        
        createLogo()
        createButtons()
        createLeaderboardButton()
    }
    
    func createLogo(){
        let logo = SKLabelNode(fontNamed: "Chalkduster")
        logo.text = "Cursed"
        logo.fontColor = .white
        logo.position = CGPoint(x: 0, y: 85)
        logo.fontSize = 65
        logo.zPosition = 100
        self.addChild(logo)
    }
    
    func createButtons(){
        startButton.texture = textureAtlas.textureNamed("start")
        startButton.size = CGSize(width: 150, height: 65) // 225 76
        startButton.name = "start"
        startButton.position = CGPoint(x: 0, y: 30) // -15
        
        let startText = SKLabelNode(fontNamed: "Chalkduster")
        startText.text = "START"
        startText.name = "start_text"
        startText.verticalAlignmentMode = .center
        startText.position = CGPoint(x: 2, y: 0)
        startText.fontSize = 32
        startText.zPosition = 5
        startButton.addChild(startText)
        self.addChild(startButton)
        
        let pulseAction = SKAction.sequence([SKAction.fadeAlpha(to: 0.5, duration: 0.9),
                                             SKAction.fadeAlpha(to: 1, duration: 0.9)])
        startText.run(SKAction.repeatForever(pulseAction))
        
        let creditsText = SKLabelNode(fontNamed: "Chalkduster")
        creditsText.text = "CREDITS"
        creditsText.name = "credits_text"
        creditsText.verticalAlignmentMode = .center
        creditsText.position = CGPoint(x: self.size.width/2 - 100, y: -self.size.height/2 + 60)
        creditsText.fontSize = 24
        creditsText.zPosition = 5
        self.addChild(creditsText)
        creditsText.run(SKAction.repeatForever(pulseAction))
        
        waiting_text.text = "* waiting for authentication *"
        waiting_text.fontColor = .red 
        waiting_text.verticalAlignmentMode = .center
        waiting_text.position = CGPoint(x: 0, y: -100)
        waiting_text.fontSize = 24
        waiting_text.zPosition = 5
        waiting_text.alpha = 0
        self.addChild(waiting_text)
        
        
        
    }
    
    func dontPlayAnimation() {
        play_start_animation = false
    }
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in (touches){
            let location = touch.location(in: self)
            let nodeTouched = atPoint(location)
            if nodeTouched.name == "start" || nodeTouched.name == "start_text"{
                let gameScene = GameScene(size: self.size)
                if play_start_animation {
                    gameScene.setLevel(set: 0) // 0
                } else {
                    gameScene.setLevel(set: 1)
                }
                self.view?.presentScene(gameScene, transition: .crossFade(withDuration: 0.6))
                
                //self.view?.presentScene(GameScene(size: self.size), transition: .crossFade(withDuration: 0.6))
            } else if nodeTouched.name == "credits_text" {
                
                let creditScene = CreditScene(size: self.size)
                if !play_start_animation {
                    creditScene.disableAnimation()
                }
                self.view?.presentScene(creditScene, transition: .crossFade(withDuration: 0.6))
            }  else if nodeTouched.name == "leaderboard_button" || nodeTouched.name == "high_score"{
                if GKLocalPlayer.local.isAuthenticated {
                    showLeaderboard()
                } else {
                    self.waiting_text.run(SKAction.sequence([SKAction.fadeIn(withDuration: 0.7), SKAction.fadeOut(withDuration: 0.7)]))
                }
            }
        }
    }
    
    
    func createLeaderboardButton(){
        highScore.texture = textureAtlas.textureNamed("start")
        highScore.size = CGSize(width: 150, height: 65) // 225 76
        highScore.name = "credits"
        highScore.name = "high_score"
        highScore.position = CGPoint(x: 0, y: -50)
        highScore.zPosition = 14
        
        
        leaderboardText = SKLabelNode(fontNamed: "Chalkduster")
        leaderboardText.text = "Ranking"
        leaderboardText.name = "leaderboard_button"
        leaderboardText.alpha = 1
        leaderboardText.fontColor = .brown
        leaderboardText.position = CGPoint(x: 0, y: -5)
        leaderboardText.fontSize = 23
        leaderboardText.zPosition = 15
        let pulseAction = SKAction.sequence([SKAction.fadeAlpha(to: 0.5, duration: 0.9),
                                             SKAction.fadeAlpha(to: 1, duration: 0.9)])
        leaderboardText.run(SKAction.repeatForever(pulseAction))
        highScore.addChild(leaderboardText)
        self.addChild(highScore)
    }
    
    func showLeaderboard() {
        let gameCenter = GKGameCenterViewController(state: GKGameCenterViewControllerState.leaderboards)
        gameCenter.gameCenterDelegate = self
        if let gameViewController = self.view?.window?.rootViewController {
            gameViewController.show(gameCenter, sender: self)
            gameViewController.navigationController?.pushViewController(gameCenter, animated: true)
        }
        
    }
    
    func gameCenterViewControllerDidFinish(_ gameCenterViewController: GKGameCenterViewController) {
        gameCenterViewController.dismiss(animated: true, completion: nil)
    }
    
    override var isUserInteractionEnabled: Bool{
        get {
            return true
        } set{
            
        }
    }
}
