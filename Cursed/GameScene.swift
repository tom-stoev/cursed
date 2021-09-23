//
//  GameScene.swift
//  hi
//
//  Created by Tom Stoev on 8/11/21.
//

import SpriteKit
import SwiftUI
import GameKit
//import CoreMotion


enum physicsCategory: UInt32{
    case ground = 1
    case fox = 2
    case hurtFox = 4
    case enemy = 8
    case player = 16
    case hurtPlayer = 32
    case attack = 64
    case contact = 128
    case misc = 256

}


struct constants{
    // environment
    // width: 812
    // height: 375
    static let game_width = UIScreen.main.bounds.size.width > CGFloat(812) ? UIScreen.main.bounds.size.width: CGFloat(812)
    static let game_height = UIScreen.main.bounds.size.height > CGFloat(375) ? UIScreen.main.bounds.size.height: CGFloat(375)
//    static let game_width = UIScreen.main.bounds.size.width
//    static let game_height = UIScreen.main.bounds.size.height
    
    // player dimensions
    static let player_width = 30
    static let player_height = 55
    
    // orientations
    static let no_orientation = -2
    static let orientation_right = 1
    static let orientation_left = -1
    
    // animation states
    static let initial = -1
    static let idle = 0
    static let is_running = 1
    static let jumping = 2
    static let attacking = 3
    static let finished_attack = 4
    static let falling = 5
    
    // enemy types
    static let wizard = 0
    static let wizard2 = 1
    static let samurai = 2
    static let eye = 3
    static let mushroom = 4
    static let fox = 5
    static let santa = 6
    static let malphas = 7
    
    // enemy physicsBody dimensions
    static let wizard_width = 47
    static let wizard_height = 85
    static let wizard2_width = 35
    static let wizard2_height = 85
    static let samurai_width = 44
    static let samurai_height = 68
    static let eye_radius = 22
    static let mushroom_width = 43
    static let mushroom_height = 61
    static let santa_width = 30
    static let santa_height = 60
    static let malphas_width = 50
    static let malphas_height = 54
}

class GameScene: SKScene, SKPhysicsContactDelegate{
    private let levelManager = LevelManager()
    private let cam = SKCameraNode()
    private let hud = HUD()
    private let player = Player()
    private let player_0 = Player_0()
    private let ground = Ground()
    private let initialPos = CGPoint(x: -100, y: 105)
    
    private var score_level = 6
    private var malphas_level = 5
    private var level = 1
    private var level_complete = false
    private var receiving_contract = false
    private var dialogue_done = false
    private var should_play_dialogue = true
    private var fox_transform_animation_index = 0
    private var backstory = SKLabelNode(fontNamed: "Chalkduster")
    private var backstory_main = SKLabelNode(fontNamed: "Chalkduster")
    
    private let lvlHeader = SKLabelNode(fontNamed: "Chalkduster")
    private let lvlObjective = SKLabelNode(fontNamed: "Copperplate-Light")
    private var leftBoundary = SKSpriteNode()
    private var rightBoundary = SKSpriteNode()
    private var portal = Portal()
    private var completion_requirement:[Int] = [0, 5, 0, 2, 1, 1] // number of enemies that need to be killed per round
                                                            // only specific enemy deaths decrement this

    // these arrays are used to store properties about each level
    // they are indexed with the 'level' variable and the appropriate settings are then loaded in
    private var background:[String] = ["DestroyedCity", "woods", "DestroyedCity", "Dawn", "outskirts", "Dawn", "DestroyedCity"] // images for each level
    private var backgroundWidth:[Int] = [0, 2, 2, 0, 0, 0, 0] // starts from 0 (1 sets width to 2 * constants.game_width) etc
    private var backgroundHeight:[CGFloat] = [1, 1, 4.5, 2, 1, 1, 1] // starts from 1
    private var groundTexture:[String] = ["brick_rough_blue", "brick_rough_blue", "brick_rough_blue", "brick_rough_blue", "brick_rough_blue", "brick_rough_blue", ""]
    private var backgroundColors:[UIColor] = [UIColor(.black), UIColor(.black), UIColor(red: 0, green: CGFloat(0.2156), blue: CGFloat(0.902), alpha:  CGFloat(1)), UIColor(.black), UIColor(.black), UIColor(.black), UIColor(.black)]
    private var lvlTitles:[String] = ["backstory", "hostile forest", "contempt", "red dawn",  "outskirts", "demonic dealings", ""]
    private var lvlObjectives:[String] = ["", "eliminate the mushrooms", "find the portal!", "defeat the samurai", "defeat the mage", "destroy the demon 'Malphas'", ""]
    
    private var portal_locked = SKLabelNode(fontNamed: "Chalkduster")
    private var portal_locked_faded = false
    
    private var curse_undone = false

    override func didMove(to view: SKView) {
        self.anchorPoint = .zero
        self.camera = cam
        //camera?.position = CGPoint(x: UIScreen.main.bounds.width/2, y: UIScreen.main.bounds.height/2)
        camera?.xScale = constants.game_width / UIScreen.main.bounds.width
        camera?.yScale = constants.game_height / UIScreen.main.bounds.height
        self.addChild(camera!)
        self.camera!.zPosition = 50
        
        hud.createHudNodes(screenSize: self.size)
        hud.startHud(lives: player.getLives(), lvl: level)
        self.camera!.addChild(hud)
        self.view?.isMultipleTouchEnabled = true
        
        //self.view?.showsPhysics = true
        self.physicsWorld.contactDelegate = self
        self.physicsWorld.gravity = CGVector(dx: 0, dy: -6)

//        self.addChild(player)
//        player.name = "player"
        
        self.addChild(lvlHeader)
        lvlHeader.zPosition = 10
        lvlHeader.fontColor = .white
        lvlHeader.fontSize = 40
        
        self.addChild(lvlObjective)
        lvlObjective.zPosition = 10
        lvlObjective.fontColor = .white
        lvlObjective.fontSize = 25
        
        portal.name = "portal"

        portal_locked.zPosition = 14
        portal_locked.fontColor = .red
        portal_locked.fontSize = 18
        portal_locked.name = "del"
        portal_locked.position = CGPoint(x: 0, y: 30)
        portal_locked.text = "*locked*"
        
        //print("level: \(level)")
        if level > 0 {
            self.addChild(player)
            player.name = "player"
            player.position = initialPos
            loadLevel()
        } else {
            startAnimation()
        }
        //player.god()
        

    }
    
    override func didSimulatePhysics() {
        var height = player.position.y
        if player.position.y < self.size.height/2 {
            height = self.size.height/2
        } else if player.position.y > self.size.height * (CGFloat(backgroundHeight[level])-CGFloat(0.5)) {
            height = self.size.height * (CGFloat(backgroundHeight[level])-CGFloat(0.5))
        }
        var x = player.position.x
        if backgroundWidth[level] != 0 {
            if player.position.x < 0 {
                x = 0
            } else if player.position.x > constants.game_width/CGFloat(2) * CGFloat(backgroundWidth[level]*2){
                x = constants.game_width/CGFloat(2) * CGFloat(backgroundWidth[level]*2)
            }
            self.camera!.position = CGPoint(x: x, y: height)
        } else {
            self.camera!.position = CGPoint(x: 0, y: height)
        }
    }
    
    override func update(_ currentTime: TimeInterval) {
        if curse_undone {
            player_0.update()
        } else {
            player.update()
        }
        switch(level){
        case 0:
            for i in levelManager.encounters[level].children {
                if i.name == "update_santa" {
                    var santa = Santa()
                    santa = i as! Santa
                    santa.update(pos: player.position, status: false, orientation: player.getOrientation(), damage: 0)
                } 
            }
            break
        case 1:
            for i in levelManager.encounters[level].children {
                if i.name == "update_eye" {
                    var eye = Eye()
                    eye = i as! Eye
                    let status = player.shouldGiveDamage(location: eye.position, type: constants.eye)
                    if !status && !eye.isVulnerable(){
                        eye.resetVulnerability()
                    }
                    eye.update(pos: player.position, status: status, orientation: player.getOrientation() , damage: player.getDamage())
                    if eye.shouldGiveDamage(location: player.position) && player.takeDamage(dmg: eye.getDamage()){
                        hud.updateLives(lives: player.getLives())
                    }
                } else if i.name == "update_mushroom" {
                    var mush = Mushroom()
                    mush = i as! Mushroom
                    let status = player.shouldGiveDamage(location: mush.position, type: constants.mushroom)
                    if !status && !mush.isVulnerable(){
                        mush.resetVulnerability()
                    }
                    mush.update(pos: player.position, status: status, orientation: player.getOrientation() , damage: player.getDamage())
                    if mush.shouldGiveDamage(location: player.position) && player.takeDamage(dmg: mush.getDamage()){
                        hud.updateLives(lives: player.getLives())
                    }
                } else if completion_requirement[level] == 0 && !level_complete {
                        level_complete = true
                } else if i.name == "portal" {
                    if level_complete && abs(player.position.x - i.position.x) <= 35 && abs(player.position.y - i.position.y) <= 75 {
                        switchLevel()
                    } else if level_complete && !portal_locked_faded{
                        portal_locked.run(SKAction.fadeOut(withDuration: 1))
                        portal_locked_faded = true
                    }
                }
            }
        case 2:
            for i in levelManager.encounters[level].children {
                if i.name == "update_wizard"{
                    var wiz = Wizard()
                    wiz = i as! Wizard
                    let status = player.shouldGiveDamage(location: wiz.position, type: constants.wizard)
                    if !status && !wiz.isVulnerable(){
                        wiz.resetVulnerability()
                    }
                    wiz.update(pos: player.position, status: status, orientation: player.getOrientation(), damage: player.getDamage())
                    if(wiz.shouldGiveDamage(location: player.position) && player.takeDamage(dmg: wiz.getDamage())){
                        hud.updateLives(lives: player.getLives())
                    }
                } else if i.name == "update_wizard2"{
                    var wiz2 = Wizard2()
                    wiz2 = i as! Wizard2
                    let status = player.shouldGiveDamage(location: wiz2.position, type: constants.wizard2)
                    if !status && !wiz2.isVulnerable(){
                        wiz2.resetVulnerability()
                    }
                    wiz2.update(pos: player.position, status: status, orientation: player.getOrientation() , damage: player.getDamage())
                    if wiz2.shouldGiveDamage(location: player.position) && player.takeDamage(dmg: wiz2.getDamage()){
                        hud.updateLives(lives: player.getLives())
                    }
                } else if i.name == "update_hp" {
                    var potion = HealthPotion()
                    potion = i as! HealthPotion
                    if abs(player.position.x - i.position.x) <= 35 && abs(player.position.y - i.position.y) <= 65 {
                        player.regen(health: potion.getRegen())
                        hud.updateLives(lives: player.getLives())
                        i.removeFromParent()
                    }
                }
                else if i.name == "portal" {
                    if abs(player.position.x - i.position.x) <= 35 && abs(player.position.y - i.position.y) <= 75 {
                        switchLevel()
                    }
                }
            }
            break
        case 3:
            if completion_requirement[level] == 0 && !receiving_contract{
                foxGrantPower()
            }
            for i in levelManager.encounters[level].children {
                if i.name == "update_samurai"{
                    var samurai = Samurai()
                    samurai = i as! Samurai
                    let status = player.shouldGiveDamage(location: samurai.position, type: constants.samurai)
                    if !status && !samurai.isVulnerable(){
                        samurai.resetVulnerability()
                    }
                    samurai.update(pos: player.position, status: status, orientation: player.getOrientation() , damage: player.getDamage())
                    if samurai.shouldGiveDamage(location: player.position) && player.takeDamage(dmg: samurai.getDamage()){
                        hud.updateLives(lives: player.getLives())
                    }
                } else if i.name == "update_hp" {
                    var potion = HealthPotion()
                    potion = i as! HealthPotion
                    if abs(player.position.x - i.position.x) <= 35 && abs(player.position.y - i.position.y) <= 65 {
                        player.regen(health: potion.getRegen())
                        hud.updateLives(lives: player.getLives())
                        i.removeFromParent()
                    }
                } else if i.name == "update_fox"{
                    var fox = Fox()
                    fox = i as! Fox
                    let status = player.shouldGiveDamage(location: fox.position, type: constants.fox)
                    fox.update(pos: player.position, status: status, orientation: player.getOrientation() , damage: player.getDamage())
                }
                else if i.name == "portal" {
                    if abs(player.position.x - i.position.x) <= 35 && abs(player.position.y - i.position.y) <= 75 {
                        portal.removeFromParent()
                        switchLevel()

                    }
                }
            }
            
        case 4:
            if completion_requirement[level] == 0 && !level_complete{
                level_complete = true
                portal.position = CGPoint(x: CGFloat(300), y: CGFloat(200))
                levelManager.encounters[level].addChild(portal)
                anotherPortalDialogue()
            }
            if !dialogue_done{
                if should_play_dialogue {
                    beforeTransformationDialogue()
                    should_play_dialogue = false
                }
            } else {
            for i in levelManager.encounters[level].children {
                if i.name == "update_santa"{
                    var santa = Santa()
                    santa = i as! Santa
                    let status = player.shouldGiveDamage(location: santa.position, type: constants.santa)
                    if !status && !santa.isVulnerable(){
                        santa.resetVulnerability()
                    }
                    santa.update(pos: player.position, status: status, orientation: player.getOrientation() , damage: player.getDamage())
                    if santa.shouldGiveDamage(location: player.position) && player.takeDamage(dmg: santa.getDamage()){
                        hud.updateLives(lives: player.getLives())
                    }
                } else if i.name == "portal" {
                    if abs(player.position.x - i.position.x) <= 35 && abs(player.position.y - i.position.y) <= 75 {
                        portal.removeFromParent()
                        switchLevel()
                    }
                }else if i.name == "update_hp" {
                    var potion = HealthPotion()
                    potion = i as! HealthPotion
                    if abs(player.position.x - i.position.x) <= 35 && abs(player.position.y - i.position.y) <= 65 {
                        player.regen(health: potion.getRegen())
                        hud.updateLives(lives: player.getLives())
                        i.removeFromParent()
                    }
                }
            }
            }
            
        case 5:
            if fox_transform_animation_index == 0{
                beforeTransformationEntry()
                fox_transform_animation_index += 1
            }  else {
                for i in levelManager.encounters[level].children {
                    if fox_transform_animation_index == 1 {
                        if i.name == "update_fox"{
                            var fox = Fox()
                            fox = i as! Fox
                            fox.update(pos: player.position, status: false, orientation: player.getOrientation() , damage: player.getDamage())
                            if fox.physicsBody?.velocity.dx == 0 && !fox.hasTransformed(){
                                fox.transform()
                                fox_transform_animation_index += 1
                            }
                        }
                    } else if fox_transform_animation_index == 3{
                        if i.name == "update_malphas"{
                            var malphas = Malphas()
                            malphas = i as! Malphas
                            let status = player.shouldGiveDamage(location: malphas.position, type: constants.malphas)
                            if !status && !malphas.isVulnerable(){
                                malphas.resetVulnerability()
                            }
                            malphas.update(pos: player.position, status: status, orientation: player.getOrientation() , damage: player.getDamage())
                            if malphas.shouldGiveDamage(location: player.position) && player.takeDamage(dmg: malphas.getDamage()){
                                hud.updateLives(lives: player.getLives())
                            }
                        } else if i.name == "update_wizard"{
                            var wiz = Wizard()
                            wiz = i as! Wizard
                            let status = player.shouldGiveDamage(location: wiz.position, type: constants.wizard)
                            if !status && !wiz.isVulnerable(){
                                wiz.resetVulnerability()
                            }
                            wiz.update(pos: player.position, status: status, orientation: player.getOrientation(), damage: player.getDamage())
                            if(wiz.shouldGiveDamage(location: player.position) && player.takeDamage(dmg: wiz.getDamage())){
                                hud.updateLives(lives: player.getLives())
                            }
                        } else if i.name == "update_wizard2"{
                            var wiz2 = Wizard2()
                            wiz2 = i as! Wizard2
                            let status = player.shouldGiveDamage(location: wiz2.position, type: constants.wizard2)
                            if !status && !wiz2.isVulnerable(){
                                wiz2.resetVulnerability()
                            }
                            wiz2.update(pos: player.position, status: status, orientation: player.getOrientation() , damage: player.getDamage())
                            if wiz2.shouldGiveDamage(location: player.position) && player.takeDamage(dmg: wiz2.getDamage()){
                                hud.updateLives(lives: player.getLives())
                            }
                        } else if i.name == "update_samurai"{
                                var samurai = Samurai()
                                samurai = i as! Samurai
                                let status = player.shouldGiveDamage(location: samurai.position, type: constants.samurai)
                                if !status && !samurai.isVulnerable(){
                                    samurai.resetVulnerability()
                                }
                                samurai.update(pos: player.position, status: status, orientation: player.getOrientation() , damage: player.getDamage())
                                if samurai.shouldGiveDamage(location: player.position) && player.takeDamage(dmg: samurai.getDamage()){
                                    hud.updateLives(lives: player.getLives())
                                }
                        }else if i.name == "update_hp" {
                            var potion = HealthPotion()
                            potion = i as! HealthPotion
                            if abs(player.position.x - i.position.x) <= 35 && abs(player.position.y - i.position.y) <= 65 {
                                player.regen(health: potion.getRegen())
                                hud.updateLives(lives: player.getLives())
                                i.removeFromParent()
                            }
                        }
//                        else if completion_requirement[level] == 0 && player.getLives() > 0 {
//                            undoCurse()
//                        }
                    } else if fox_transform_animation_index == 4{
                        if completion_requirement[level] == -1 {
                            spawnPortal()
                            let notifyLiftedCurse = SKAction.run { [weak self] in
                                self?.curseLiftedNotice()
                            }
                            self.run(SKAction.sequence([SKAction.wait(forDuration: 0.3), notifyLiftedCurse]))
                            completion_requirement[level] -= 1
                        } else if i.name == "portal" && abs(player_0.position.x - i.position.x) <= 35 && abs(player_0.position.y - i.position.y) <= 75{
                            portal.removeFromParent()
                            switchLevel()
                            gameFinish()
                        } else if curse_undone && i.name == "update_hp"{
                            var potion = HealthPotion()
                            potion = i as! HealthPotion
                            if abs(player_0.position.x - i.position.x) <= 35 && abs(player_0.position.y - i.position.y) <= 65 {
                                player_0.regen(health: potion.getRegen())
                                hud.updateLives(lives: player_0.getLives())
                                i.removeFromParent()
                            }
                        }
                    }
                }
            }
            break
        case 6:
            for i in levelManager.encounters[level].children {
                if i.name == "portal" && abs(player_0.position.x - i.position.x) <= 35 && abs(player_0.position.y - i.position.y) <= 75{
                    i.removeFromParent()
                    self.removeAllChildren()
                    let menu = MenuScene(size: self.size)
                    menu.dontPlayAnimation()
                    self.view?.presentScene(menu, transition: .crossFade(withDuration: 0.6))
                }
                
            }
            break
        default:
            print("shouldnt print")
        }
    }
    
    func switchLevel(){
        print("cleaning up...")
        cleanUpLevel()
        level+=1
        level_complete = false
        loadLevel()
    }
    
    
    // create ground & display lvl header + objective header animations
    // display enemies for corresponding level from sks files
    func loadLevel(){
        print("lvl \(level) loaded")
        addBackground(level: level)
        ground.position = CGPoint(x: -constants.game_width/2, y: 60)
        ground.size = CGSize(width: constants.game_width * (CGFloat(backgroundWidth[level])+CGFloat(1)), height: 0)
        ground.name = "ground"
        if groundTexture[level] != "" {
            ground.createChildren(texture: SKTextureAtlas(named: "Environment").textureNamed(groundTexture[level]))
        } else {
            ground.createBoundary(h: CGFloat(-20))
        }
        self.addChild(ground)
        
        if curse_undone {
            player_0.position = initialPos
        } else {
            player.position = initialPos
        }
        hud.updateLevel(lvl: level)
        levelManager.addEncountersToScene(gameScene: self, level: level)
        
        lvlHeader.text = lvlTitles[level]
        lvlHeader.alpha = 1
        lvlHeader.position = CGPoint(x: 0, y: self.size.height - CGFloat(115))
        let fade = SKAction.fadeOut(withDuration: 3)
        lvlHeader.run(fade)

        if lvlObjectives[level] != "" {
            lvlObjective.text = "objective:  " + lvlObjectives[level]
            lvlObjective.alpha = 1
            lvlObjective.position = CGPoint(x: 0, y: self.size.height - CGFloat(150))
            let fade2 = SKAction.fadeOut(withDuration: 4)
            lvlObjective.run(fade2)
        }
        
        if level == 1 {
            portal_locked.position = CGPoint(x: 1470, y: 200)
            self.addChild(portal_locked)
        }
        
    }
    
    func cleanUpLevel(){
        for i in self.children {
            if i.name == "bg" || i.name == "ground" || i.name == "particle_delete"
            || i.name == "flames" || i.name == "sparks" || i.name == "portal" || i.name == "skip" || i.name == "skip_text"
                || i.name == "level_root_node" || i.name == "del"{
                i.removeFromParent()
            }
        levelManager.encounters[level].removeAllChildren()
        ground.removeAllChildren()
        }
    }
    
    func addBackground(level: Int){
        for index in 0...backgroundWidth[level] {

            let bg = SKSpriteNode(imageNamed: background[level])
            bg.size = CGSize(width: constants.game_width, height: constants.game_height)//UIScreen.main.bounds.size
            bg.zPosition = -1
            bg.name = "bg"
            bg.position = CGPoint(x: CGFloat(2 * index) * constants.game_width/2, y: constants.game_height/2)
            //bg.blendMode = .replace
            self.addChild(bg)
                // testing this out
            if backgroundHeight[level] > 1 {
                let bg2 = SKSpriteNode(imageNamed: background[level])
                bg2.size = CGSize(width: constants.game_width, height: constants.game_height)
                bg2.zPosition = -1
                bg2.name = "bg"
                    let rotate = SKAction.rotate(toAngle: CGFloat(3.1415926535), duration: 0)
                bg2.position = CGPoint(x: CGFloat(2 * index) * constants.game_width/2, y: (backgroundHeight[level]-CGFloat(0.5))*constants.game_height)
                bg2.run(rotate)
                //bg2.blendMode = .replace
                self.addChild(bg2)
            }
        }
        leftBoundary = SKSpriteNode(color: .clear, size: CGSize(width: 100, height: 100))
        leftBoundary.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: CGFloat(100), height: CGFloat(constants.game_height * backgroundHeight[level])), center: CGPoint(x: -constants.game_width/2, y: 60+constants.game_height * backgroundHeight[level]/2))
        leftBoundary.name = "bg"
        leftBoundary.physicsBody?.categoryBitMask = physicsCategory.ground.rawValue
        leftBoundary.physicsBody?.isDynamic = false
        //rightBoundary.anchorPoint = CGPoint(x: 0, y: 0)
        rightBoundary = SKSpriteNode(color: .clear, size: CGSize(width: 100, height: 100))
        rightBoundary.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: CGFloat(100), height: CGFloat(constants.game_height * backgroundHeight[level])), center: CGPoint(x: constants.game_width/CGFloat(2) * CGFloat(backgroundWidth[level]*2+1), y: 60 + constants.game_height * backgroundHeight[level]/2))
        rightBoundary.name = "bg"
        rightBoundary.physicsBody?.categoryBitMask = physicsCategory.ground.rawValue
        rightBoundary.physicsBody?.isDynamic = false
        self.addChild(leftBoundary)
        self.addChild(rightBoundary)
        
        self.backgroundColor = backgroundColors[level]
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in (touches){
            let location = touch.location(in :self)
            let nodeTouched = atPoint(location)
            
            if curse_undone {
                if nodeTouched.name == "left" {
                        self.player_0.lastDirection(orientation: constants.orientation_left)
                        self.player_0.keep_moving = true
                    } else if nodeTouched.name == "right"{
                        self.player_0.lastDirection(orientation: constants.orientation_right)
                        self.player_0.keep_moving = true
                    } else if (nodeTouched.name == "jump") && player_0.physicsBody?.velocity.dy == 0{
                        self.player_0.physicsBody?.applyImpulse(CGVector(dx: 0, dy: 50))
                    } else if nodeTouched.name == "attack"{
                        self.player_0.setAttack()
                    }
                return
            }
            if nodeTouched.name == "left" {
                    self.player.lastDirection(orientation: constants.orientation_left)
                    self.player.keep_moving = true
                } else if nodeTouched.name == "right"{
                    self.player.lastDirection(orientation: constants.orientation_right)
                    self.player.keep_moving = true
                } else if (nodeTouched.name == "jump") && player.physicsBody?.velocity.dy == 0{
                    self.player.physicsBody?.applyImpulse(CGVector(dx: 0, dy: 50))
                } else if nodeTouched.name == "attack"{
                    self.player.setAttack()
                } else if nodeTouched.name == "menu_button" || nodeTouched.name == "menu_text"{
                    let menu = MenuScene(size: self.size)
                    menu.dontPlayAnimation()
                    self.view?.presentScene(menu, transition: .crossFade(withDuration: 0.6))
                } else if nodeTouched.name == "restart_button" || nodeTouched.name == "restart_text"{
                self.view?.presentScene(GameScene(size: self.size), transition: .crossFade(withDuration: 0.6))
                } else if nodeTouched.name == "skip_text" {
                    for i in self.camera?.children ?? []{
                        if i.name == "skip_text" || i.name == "skip" {
                            i.removeFromParent()
                        }
                    }
                    backstory.removeFromParent()
                    backstory_main.removeFromParent()
                    gameTransition()
                }
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in (touches){
            let location = touch.location(in :self)
            let nodeTouched = atPoint(location)
            if curse_undone {
                if nodeTouched.name == "left" || nodeTouched.name == "right"{
                    self.player_0.keep_moving = false
                } else
                if nodeTouched.name == "jump" {
                }
                return
            }
                if nodeTouched.name == "left" || nodeTouched.name == "right"{
                    self.player.keep_moving = false
                } else
                if nodeTouched.name == "jump" {
                }
        }
    }
    
    func setLevel(set: Int){
        level = set
    }
    
    // funnctions helping regulate level mechanics
    
    func startAnimation(){
        hud.removeFromParent()
        //hud.removeAllChildren()
        addBackground(level: level)
        ground.position = CGPoint(x: -constants.game_width/2, y: 60)
        ground.size = CGSize(width: constants.game_width * (CGFloat(backgroundWidth[level])+CGFloat(1)), height: 0)
        ground.name = "ground"
        ground.createBoundary(h: CGFloat(-20))
        self.addChild(ground)
        
        lvlHeader.text = lvlTitles[level]
        lvlHeader.alpha = 1
        lvlHeader.position = CGPoint(x: 0, y: self.size.height - CGFloat(115))
        let fade = SKAction.fadeOut(withDuration: 3)
        lvlHeader.run(fade)
        
        let cameraOrigin = CGPoint(x: self.size.width / 2, y: self.size.height / 2)
        let skip = SKSpriteNode(imageNamed: "start")
        skip.position = CGPoint(x: cameraOrigin.x - 91, y: -cameraOrigin.y + 50)
        skip.zPosition = 11
        skip.size = CGSize(width: 100, height: 55)
        skip.name = "skip"
        
        let skipText = SKLabelNode(fontNamed: "Chalkduster")
        skipText.text = "skip"
        skipText.name = "skip_text"
        skipText.verticalAlignmentMode = .center
        skipText.position = CGPoint(x: 2, y: 0)
        skipText.fontSize = 28
        skipText.zPosition = 12
        skip.addChild(skipText)
        self.camera?.addChild(skip)
        

        player_0.position = CGPoint(x: CGFloat(-200), y: CGFloat(100))
        
        levelManager.encounters[level].addChild(player_0)
        levelManager.addEncountersToScene(gameScene: self, level: 0)
        //self.addChild(levelManager.encounters[level])
        player_0.addChild(backstory)
        self.addChild(backstory_main)
        
        backstory.fontSize = 19
        backstory.fontColor = .white
        backstory.alpha = 0
        backstory.text = ""
        backstory.name = "del"
        backstory.zPosition = 10
        backstory.horizontalAlignmentMode = .center
        backstory.position = CGPoint(x: 0, y: CGFloat(25))

        backstory_main.fontSize = 26
        backstory_main.fontColor = .white
        backstory_main.alpha = 0
        backstory_main.text = ""
        backstory_main.name = "del"
        backstory_main.zPosition = 10
        backstory_main.position = CGPoint(x: CGFloat(0), y: CGFloat(200))

        let change =  SKAction.run{ [weak self] in
            self?.backstory.text = "I just patrolled for three days ..."
        }
        let change2 =  SKAction.run{ [weak self] in
            self?.backstory.text = "Im so tired ... "
        }
        
        let change3 =  SKAction.run{ [weak self] in
            self?.backstory.text = "gonna pass out for a while "
        }

        let go_to_sleep = SKAction.run{ [weak self] in
            self?.player_0.deathAnimation()
        }
        let change4 =  SKAction.run{ [weak self] in
            self?.backstory_main.text = "Meanwhile, an evil mage appeared"
        }
        let change5 =  SKAction.run{ [weak self] in
            self?.backstory_main.text = "and cast a form-changing curse"
        } // I get to take one of your possesions

        let change6 =  SKAction.run{ [weak self] in
            self?.backstory.text = "!!!!"
        }

        let change7 =  SKAction.run{ [weak self] in
            self?.backstory.text = "I've been cursed ..."
        }

        let change8 =  SKAction.run{ [weak self] in
            self?.backstory.text = "I'll find the mage that did this!"
        }
        let change9 =  SKAction.run{ [weak self] in
            self?.backstory_main.text = "But the mage is now far away ..."
        }
        
        let change10 =  SKAction.run{ [weak self] in
            self?.backstory_main.text = "chase him through the portals"
        }
        
        let change11 =  SKAction.run{ [weak self] in
            self?.backstory_main.text = "and undo this curse"
        }
        
        let transition = SKAction.run{ [weak self] in
            for i in self?.camera?.children ?? []{
                if i.name == "skip_text" || i.name == "skip" {
                    i.removeFromParent()
                }
            }
            self?.backstory.removeFromParent()
            self?.backstory_main.removeFromParent()
            self?.gameTransition()
        }
        
        let finale = SKAction.run { [weak self] in
            self?.backstory_main.run(SKAction.sequence([change9, SKAction.fadeIn(withDuration: 1.5), SKAction.fadeOut(withDuration: 1.5), change10, SKAction.fadeIn(withDuration: 1.5), SKAction.fadeOut(withDuration: 1.5), change11, SKAction.fadeIn(withDuration: 1.5), SKAction.fadeOut(withDuration: 1.5), transition]))
        }

        
        let poofIn = SKAction.run { [weak self] in
            let santa = Santa()
            santa.position = CGPoint(x: 200, y: 170)
            santa.disable()
            santa.name = "update_santa"
            self?.spawnPortal()
            self!.levelManager.encounters[self!.level].addChild(santa)
            santa.physicsBody?.applyImpulse(CGVector(dx: -10, dy: 0))
            
        }
        
        let castCurse = SKAction.run { [weak self] in
            if let curse = SKEmitterNode(fileNamed: "curse"){
                curse.name = "curse"
                curse.particleZPosition = 100
                curse.position = CGPoint(x: -25, y:  -80)
                self?.player_0.addChild(curse)
                curse.targetNode = self?.player_0
            }
        }
        
        let removeCurseFlames = SKAction.run { [weak self] in
            for i in self!.player_0.children{
                if i.name == "curse" {
                    self!.player.position = CGPoint(x: self!.player_0.position.x, y: 88) //self!.player_0.position
                    self!.player_0.removeAllChildren()
                    self!.player_0.removeFromParent()
                    self!.addChild(self!.player)
                    self!.player.idleAnimation()
                    i.removeFromParent()
                    self!.backstory.position = CGPoint(x: 0, y: self!.player.position.y - 20)
                    self!.player.addChild(self!.backstory)
                }
            }
        }
        
        let flee = SKAction.run { [weak self] in
            for i in self!.levelManager.encounters[self!.level].children {
                if i.name == "update_santa" {
                    var santa = Santa()
                    santa = i as! Santa
                    santa.flee()
                }
            }
        }
        
        let pursue = SKAction.run{ [weak self] in
            self!.player.setCursedAnimation()
            for i in self!.player.children {
                if i.name == "del" {
                    i.removeFromParent()
                }
            }
        }
        
        let afterwards = SKAction.run{ [weak self] in
            self?.backstory.run(SKAction.sequence([flee, SKAction.wait(forDuration: 4), removeCurseFlames, SKAction.wait(forDuration: 1), change6, SKAction.fadeIn(withDuration: 1), SKAction.fadeOut(withDuration: 1), change7, SKAction.fadeIn(withDuration: 1), SKAction.fadeOut(withDuration: 1), change8, SKAction.fadeIn(withDuration: 1), SKAction.fadeOut(withDuration: 1), pursue]))
        }
        
        let meanwhile = SKAction.run { [weak self] in
            self?.backstory_main.run(SKAction.sequence([change3, SKAction.fadeIn(withDuration: 1), SKAction.fadeOut(withDuration: 1), change4, poofIn, SKAction.fadeIn(withDuration: 1.5), SKAction.fadeOut(withDuration: 1.5), change5, SKAction.fadeIn(withDuration: 1.5), SKAction.fadeOut(withDuration: 1.5), castCurse, afterwards, SKAction.wait(forDuration: 15), finale]))
        }

        let next = SKAction.sequence([SKAction.fadeOut(withDuration: 1), change, SKAction.fadeIn(withDuration: 1), SKAction.fadeOut(withDuration: 1), change2, SKAction.fadeIn(withDuration: 1), SKAction.fadeOut(withDuration: 1), change3, go_to_sleep, SKAction.fadeIn(withDuration: 1), SKAction.fadeOut(withDuration: 1), meanwhile])
        backstory.run(next)
    }
    
    func gameTransition(){
        player.removeCurseAnimation()
        player.position = initialPos
        player.physicsBody?.velocity = CGVector(dx: 0, dy: 0)
        player.name = "player"
        player_0.removeFromParent()
        self.addChild(player) // crash here? 
        self.camera?.addChild(hud)
        cleanUpLevel()
        level = 1
        loadLevel()
        
    }
    
    func spawnPortal(){
        portal.position = CGPoint(x: CGFloat(200), y: CGFloat(200))
        if level == malphas_level {
            portal.position.y += 60
        } else if level == score_level {
            portal.position.y -= 60
        }
        portal.name = "portal"
        levelManager.encounters[level].addChild(portal)
    }
    
    func onEnemyDeath(){
        if level != malphas_level {
        completion_requirement[level] -= 1
        }
    }
    
    func onMalphasDeath(){
        completion_requirement[level] -= 1
        if player.getLives() > 0 {
            undoCurse()
        }
    }
    
    // Functions particular to levels 
    
    // LEVEL 3
    
    func setOP(){
        player.god()
        hud.updateLives(lives: player.getLives())
        spawnPortal()
        for i in levelManager.encounters[level].children{
            if i.name == "update_fox"{
                var fox = Fox()
                fox = i as! Fox
                fox.bidFarewell()
            }
        }
        //fox.bidFarewell()
    }
    
    func foxGrantPower(){
        let fox = Fox()
        fox.name = "update_fox"
        fox.position = CGPoint(x: CGFloat(300), y: CGFloat(100))
        levelManager.encounters[level].addChild(fox)
        receiving_contract = true
    }
    
    // LEVEL 4
    func removeSparks(){
        //print("removing sparks")
        for i in self.children {
            if i.name == "sparks" {
                i.removeFromParent()
            }
        }
    }
    
    func removeFlames(){
       // print("removing flames")
        for i in self.children {
            if i.name == "flames" {
                i.removeFromParent()

            }
        }
    }
    
    func anotherPortalDialogue(){
        let another = SKLabelNode(fontNamed: "Chalkduster")
        another.fontSize = 28
        another.text = "Soon the curse will lift! Another portal?"
        another.alpha = 0
        another.zPosition = 500
        another.name = "del"
        //another.run(SKAction.scaleX(to: -1, duration: 0))
        another.position = CGPoint(x: 0, y: UIScreen.main.bounds.height/2 + 50)
        self.addChild(another)
        another.run(SKAction.sequence([SKAction.fadeIn(withDuration: 2), SKAction.fadeOut(withDuration: 2)]))
        
        for i in self.levelManager.encounters[level].children {
            if i.name == "portal" {
                i.run(SKAction.colorize(with: .red, colorBlendFactor: 0.5, duration: 1))
            }
        }
    }

    
    // LEVEL 5
    
    func beforeTransformationEntry(){
        let dummy1 = Fox()
        dummy1.name = "update_fox"
        dummy1.avoidGrantingPower()
        dummy1.position = CGPoint(x: CGFloat(300), y: CGFloat(100))
        levelManager.encounters[level].addChild(dummy1)
    }
    
    func spawnMalphas(){
        let m = Malphas()
        m.name = "update_malphas"
        m.position = CGPoint(x: CGFloat(150), y: CGFloat(150))
        levelManager.encounters[level].addChild(m)
        let increment = SKAction.run{ [weak self] in
            self?.fox_transform_animation_index += 1
        }
        m.run(SKAction.sequence([increment]))
        //have_played_transform_animation += 1
    }
    
    func beforeTransformationDialogue(){
        let found = SKLabelNode(fontNamed: "Chalkduster")
        found.text = "you finally caught up to me eh?"
        found.alpha = 0
        found.zPosition = 5
        found.fontSize = 18
        found.run(SKAction.scaleX(to: -1, duration: 0))
        found.position = CGPoint(x: 0, y: 40)
        
        let change = SKAction.run {
            found.text = "but you won't defeat me"
        }
        
        let finale = SKAction.run { [weak self] in
            self?.dialogue_done = true
        }
        for i in self.levelManager.encounters[level].children {
            if i.name == "update_santa" {
                i.addChild(found)
                found.run(SKAction.sequence([SKAction.fadeIn(withDuration: 1), SKAction.fadeOut(withDuration: 1), change, SKAction.fadeIn(withDuration: 1), SKAction.fadeOut(withDuration: 1), finale]))
            }
        }
    }
    
    func killSpawnedEnemies(){
        for i in levelManager.encounters[level].children {
            if i.name == "update_wizard" || i.name == "update_wizard2" || i.name == "update_samurai" {
                i.removeFromParent()
            }
        }
    }
    
    func undoCurse(){
        for i in levelManager.encounters[level].children {
            if i.name == "update_wizard" || i.name == "update_wizard2" || i.name == "update_samurai" {
                i.removeFromParent()
                let makeSureDeleted = SKAction.run{ [weak self] in
                    self?.killSpawnedEnemies()
                }
                self.run(SKAction.sequence([SKAction.wait(forDuration: 0.1), makeSureDeleted]))
            }
        }
        
        self.fox_transform_animation_index += 1
        self.completion_requirement[level] -= 1
        let change_player = SKAction.run { [weak self] in
            self?.player.removeFromParent()
            self?.player_0.name = "player"
            self?.player_0.setLives(health: self?.player.getLives() ?? 0)
            self?.player_0.position = CGPoint(x: self!.player.position.x, y: self!.player.position.y + 50)
            self?.addChild(self!.player_0)
            self?.curse_undone = true
            
        }
        let immobile = SKAction.run { [weak self] in
            self?.player.physicsBody?.isDynamic = false
        }
        let blink = SKAction.repeat(SKAction.sequence([SKAction.fadeOut(withDuration: 1), SKAction.fadeIn(withDuration: 1)]), count: 3)
        player.run(SKAction.sequence([immobile, blink, change_player]))
    }
    
    func curseLiftedNotice(){
        let another = SKLabelNode(fontNamed: "Chalkduster")
        another.fontSize = 28
        another.text = "* Curse has been lifted *"
        another.alpha = 0
        another.zPosition = 500
        another.name = "del"
        another.position = CGPoint(x: 0, y: UIScreen.main.bounds.height/2 + 50)
        self.addChild(another)
        another.run(SKAction.sequence([SKAction.fadeIn(withDuration: 1), SKAction.fadeOut(withDuration: 1)]))
    }
    
    func spawnWizard(pos: CGPoint){
        //completion_requirement[level] += 1
        let wiz = Wizard()
        wiz.position = pos
        wiz.name = "update_wizard"
        levelManager.encounters[level].addChild(wiz)

    }
    
    func spawnWizard2(pos: CGPoint){
        //completion_requirement[level] += 1
        let wiz2 = Wizard2()
        wiz2.position = pos
        wiz2.name = "update_wizard2"
        levelManager.encounters[level].addChild(wiz2)
    }
    
    func spawnSamurai(pos: CGPoint){
        //completion_requirement[level] += 1
        let sam = Samurai()
        sam.position = pos
        sam.name = "update_samurai"
        levelManager.encounters[level].addChild(sam)
    }
    
    
    // END OF GAME
    
    func gameOver(){
        hud.showButtons()
        hud.removeButtons()
        _ = hud.getTime()
        hud.showScore(level: level)
        updateLeaderBoard(score: (100*(level-1)))
    }
    
    func gameFinish(){
//        hud.removeAllChildren()
//        hud.removeFromParent()
        spawnPortal()
        let mainMenu = SKLabelNode(fontNamed: "Chalkduster")
        mainMenu.fontColor = .white
        mainMenu.fontSize = 15
        mainMenu.position = CGPoint(x: portal.position.x, y: portal.position.y + 45)
        mainMenu.text = "main menu portal"
        self.addChild(mainMenu)
        player.position = CGPoint(x: initialPos.x, y: CGFloat(60 + constants.player_height/2))
        player.physicsBody?.velocity = CGVector(dx: 0, dy: 0)
        //player.physicsBody?.isDynamic = false
        player.removeAllActions()
        player.idleAnimation()
        let origin = CGPoint(x: self.size.width/2, y: self.size.height/2)
        let time = hud.getTime()
        let lives = player_0.getLives()
        let points = time < 300 ? (lives * 12 + (300 - time)*2) + (level-1) * 100: (lives * 12) + (level-1) * 100
        //cleanUpLevel()
        let score = SKLabelNode(fontNamed: "Copperplate-Light")
        score.position = CGPoint(x: -origin.x + 225, y: 2 * origin.y - 135)
        score.fontColor = .white
        score.horizontalAlignmentMode = .left
        score.text = "Score:                 \(points)"
        score.fontSize = 35
        
        let hp_bonus = SKLabelNode(fontNamed: "Copperplate-Light")
        hp_bonus.position = CGPoint(x: -origin.x + 225, y: 2 * origin.y - 60)
            hp_bonus.fontColor = .green
            hp_bonus.text = "(health bonus)   \(12 * lives)"
            hp_bonus.fontSize = 35
        hp_bonus.horizontalAlignmentMode = .left
        
        let time_bonus = SKLabelNode(fontNamed: "Copperplate-Light")
        time_bonus.position = CGPoint(x: -origin.x + 225, y: 2 * origin.y - 85)
            time_bonus.fontColor = .white
            time_bonus.text = time < 300 ? "(time bonus)       +\((300 - time)*2) " : "(time bonus)  +000)"
            time_bonus.fontSize = 35
        time_bonus.horizontalAlignmentMode = .left
        
        let level_bonus = SKLabelNode(fontNamed: "Copperplate-Light")
        level_bonus.position = CGPoint(x: -origin.x + 225, y: 2 * origin.y - 110)
        level_bonus.fontColor = .white
        level_bonus.text = "(level bonus)      +\(100*(level-1)) "
        level_bonus.fontSize = 35
        level_bonus.horizontalAlignmentMode = .left
        self.addChild(level_bonus)
        
        self.addChild(score)
        self.addChild(hp_bonus)
        self.addChild(time_bonus)
        updateLeaderBoard(score: points)
    }

    func updateLeaderBoard(score: Int) {
        if GKLocalPlayer.local.isAuthenticated {
            GKLeaderboard.submitScore(score, context: 0, player: GKLocalPlayer.local, leaderboardIDs: ["leaderboard1"]){
                error in
                if error != nil {
                    print("error")
                }
            }
        }
    }
    
    func outOfLives(){
        hud.updateLives(lives: 0)
    }
    
    
    


    override var isUserInteractionEnabled: Bool{
        get {
            return true
        } set{
            
        }
    }
    
//struct GameScene_Previews: PreviewProvider {
//    static var previews: some View {
//        /*@START_MENU_TOKEN@*/Text("Hello, World!")/*@END_MENU_TOKEN@*/
//    }
//}
    
}
