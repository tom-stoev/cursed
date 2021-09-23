//
//  Boss.swift
//  hi
//
//  Created by Tom Stoev on 8/31/21.
//

import SpriteKit

class Santa: SKSpriteNode, Entity {
    private var initialSize: CGSize = CGSize(width: 215, height: 180)
    private var textureAtlas: SKTextureAtlas = SKTextureAtlas(named: "Santa")
    private var sprite_orientation = constants.orientation_left
    private var movement_status = constants.initial
    private let max_velocity = CGFloat(100)
    private var chase_player = true
    private var fleeing = false

    // hit box shifts
    private var attack_fieldx_shift = CGFloat(19)
    private var attack_fieldy_shift = CGFloat(3)
    private var attack2_fieldx_shift = CGFloat(19)
    private var attack2_fieldy_shift = CGFloat(-3)
    private var attack3_fieldx_shift = CGFloat(5)
    private var attack3_fieldy_shift = CGFloat(7)
    private var attack4_fieldx_shift = CGFloat(58)
    private var attack4_fieldy_shift = CGFloat(9)
    
    // health related
    private let hpBar = SKSpriteNode(color: .green, size: CGSize(width: CGFloat(30), height: CGFloat(5)))
    private let dmgTicker = SKLabelNode(fontNamed: "AppleSDGothicNeo-Bold")
    private let hpRestored = SKLabelNode(fontNamed: "AppleSDGothicNeo-Bold")
    private var hp = CGFloat(200)
    private var hp_max = CGFloat(200)
    private var is_alive = true
    
    // attack hit logic
    private let dmg_list = [15, 30, 39, 6]
    private var giving_damage = false
    private var can_attack = true
    private var fire_sequence_started = false
    private var point_log = CGPoint()
    private var can_take_damage = true
    private var fire_mode = false
    private var flames_summoned = false
    private var can_lightning = [0]
    private var shooting_lightning = false
    private var pre_coords = [CGFloat(0), CGFloat(0), CGFloat(0), CGFloat(0)]
    private var attack_num = 0
    private let lightning = SKSpriteNode(color: .clear, size: CGSize(width: 150, height: 150))
    private let lightning3 = SKSpriteNode(color: .clear, size: CGSize(width: 150, height: 150))

    init() {
        super.init(texture: textureAtlas.textureNamed("santa_taunt009"), color: .clear, size:initialSize)
        self.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: 30, height: 60), center: CGPoint(x:self.position.x - 8, y: self.position.y - CGFloat(20)))
        self.name = "update_santa"
        self.physicsBody?.linearDamping = 0
        self.physicsBody?.restitution = 0
        self.physicsBody?.angularDamping = 0
        self.physicsBody?.angularVelocity = 0
        self.physicsBody?.friction = 0.3
        self.physicsBody?.allowsRotation = false
        self.zPosition = 8
        self.physicsBody?.affectedByGravity = true
        self.physicsBody?.categoryBitMask = physicsCategory.enemy.rawValue
        self.physicsBody?.collisionBitMask = physicsCategory.ground.rawValue
        self.physicsBody?.contactTestBitMask = 0
        
        self.run(SKAction.scaleX(to: -1, duration: 0))
        addIndicators()
        
        lightning.position = CGPoint(x: 2*constants.santa_width, y: -constants.santa_height)
        lightning.zPosition = 5
        self.addChild(lightning)
        lightning3.position = CGPoint(x: 2*constants.santa_width, y: constants.santa_height - 20)
        lightning3.zPosition = 5
        lightning3.run(SKAction.scaleY(to: CGFloat(-1), duration: 0))
        self.addChild(lightning3)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func addIndicators() {
        self.addChild(hpBar)
        hpBar.name = "hp_bar"
        hpBar.zPosition = 9
        hpBar.position = CGPoint(x: self.position.x, y: self.position.y + CGFloat(15))
        //idleAnimation()
        
        dmgTicker.text = ""
        dmgTicker.alpha = 1
        dmgTicker.zPosition = 9
        dmgTicker.position = CGPoint(x: self.position.x+35, y: self.position.y + CGFloat(35))
        dmgTicker.fontColor = .red
        dmgTicker.fontSize = 23
        self.addChild(dmgTicker)
        
        hpRestored.text = ""
        hpRestored.alpha = 1
        hpRestored.zPosition = 9
        hpRestored.position = CGPoint(x: self.position.x, y: self.position.y + CGFloat(55))
        hpRestored.fontColor = .green
        hpRestored.fontSize = 23
        self.addChild(hpRestored)
    }
    
    func resetVulnerability(){
        self.can_take_damage = true
        dmgTicker.text = " "
        let unfade = SKAction.fadeIn(withDuration: 1)
        dmgTicker.run(unfade)
    }
    
    func isVulnerable()->Bool{
        return can_take_damage
    }
    
    func disable(){
        can_attack = false
        can_take_damage = false
        chase_player = false
        hpBar.removeFromParent()
    }
    
    func flee(){
        fleeing = true
    }
    
    
    func getDamage()->Int{
        return dmg_list[attack_num]
    }
    
    func update(pos: CGPoint, status: Bool, orientation: Int, damage: Int){
        if !is_alive {
            return
        }
        
        if fleeing {
            if self.position.x < 180 {
                if self.sprite_orientation != constants.orientation_right {
                    self.run(SKAction.scaleX(to: 1, duration: 0))
                }
                self.physicsBody?.applyImpulse(CGVector(dx: 5, dy: 0))
            } else {
                self.physicsBody?.applyImpulse(CGVector(dx: 0, dy: 3))
                if self.position.y > 180 {
                    self.removeFromParent()
                }
            }
        } else if !chase_player && self.position.x > -120{
            self.physicsBody?.applyImpulse(CGVector(dx: -5, dy: 0))
        }
        
        point_log = pos
        
        // check if needs to take damage
        if status && can_take_damage{
            self.takeDamage(dmg: damage)
            self.can_take_damage = false
        }
        
        // orientation update
        if movement_status != constants.attacking && can_take_damage{ // investigate this can_take_damage
            if(sprite_orientation == constants.orientation_left && pos.x > self.position.x){
                sprite_orientation = constants.orientation_right
                self.run(SKAction.scaleX(to: 1, duration: 0))
            } else if(sprite_orientation == constants.orientation_right && pos.x < self.position.x){
                sprite_orientation = constants.orientation_left
                self.run(SKAction.scaleX(to: -1, duration: 0))
            }
        }
        
        // cap velocity
        if(self.physicsBody!.velocity.dx > max_velocity) {self.physicsBody!.velocity.dx = max_velocity}
        if(self.physicsBody!.velocity.dx < -max_velocity) {self.physicsBody!.velocity.dx = -max_velocity}
        
        if(self.physicsBody!.velocity.dy < 0){
            self.physicsBody!.applyImpulse(CGVector(dx: 0, dy: -0.5))
        }
        
        // select animation
        // unlock lightnings when in fire_mode
        // can lightning 1 in every 3 attacks
        if can_attack && fire_mode && can_lightning[0]==0 && abs(pos.x - self.position.x) <= 100{
            self.removeAction(forKey: "idle")
            self.removeAction(forKey: "run")
            taunt() // lightning attack
            movement_status = constants.attacking
            can_lightning[0]=2
            can_attack = false
        } else if can_attack && !shooting_lightning && abs(pos.x - self.position.x) <= 70 && abs(pos.y - self.position.y) <= 70{
            self.removeAction(forKey: "idle")
            self.removeAction(forKey: "run")
            if can_lightning[0] > 0 {
                can_lightning[0] -= 1
            }
            attackAnimation()
            can_attack = false
            movement_status = constants.attacking
        }
        if fire_mode && !fire_sequence_started{
            fire_sequence_started = true
            sparks()
            let summon = SKAction.run{ [weak self] in
                self?.summonFlames()
                
                if let gameScene = self?.parent?.parent as? GameScene {
                    gameScene.removeSparks()
                }
            }
            
            let remove = SKAction.run{ [weak self] in
                if let gameScene = self?.parent?.parent as? GameScene {
                    gameScene.removeFlames()
                    self?.fire_sequence_started = false
                }
                self?.flames_summoned = false
            }
            let stall = SKAction.wait(forDuration: 1)
            let stall2 = SKAction.wait(forDuration: 4)
            hpRestored.run(SKAction.sequence([stall, summon, stall2, remove]))
        }
        
        // after going below 50% hp, regain the HP + buffs
        if !fire_mode && hp < hp_max/2 {
            fireMode()
        }
        
        if movement_status != constants.attacking{ // prioritize attack animations
            // if can chase player, chase
            if abs(pos.x - self.position.x) > 60 && chase_player{
                self.physicsBody?.applyImpulse(CGVector(dx: sprite_orientation * 8, dy: 0))
            }

            if self.physicsBody?.velocity.dx != 0 {
                self.removeAction(forKey: "idle")
                //self.removeAction(forKey: "attack")
                if movement_status != constants.is_running {
                    runAnimation()
                    movement_status = constants.is_running
                }
            } else {
                self.removeAction(forKey: "run")
                //self.removeAction(forKey: "attack")
                if movement_status != constants.idle {
                    idleAnimation()
                    movement_status = constants.idle
                }
            }
        }
 
        
    }
    
    func idleAnimation(){
        let idleFrames:[SKTexture] =
            [
                textureAtlas.textureNamed("santa_idle005"),
                textureAtlas.textureNamed("santa_idle006"),
                textureAtlas.textureNamed("santa_idle007"),
                textureAtlas.textureNamed("santa_idle008"),
                textureAtlas.textureNamed("santa_idle009"),
                textureAtlas.textureNamed("santa_idle010"),
                textureAtlas.textureNamed("santa_idle011"),
                textureAtlas.textureNamed("santa_idle012"),
                textureAtlas.textureNamed("santa_idle013"),
                textureAtlas.textureNamed("santa_idle014"),
                textureAtlas.textureNamed("santa_idle015")]
        let idleAction = SKAction.animate(with: idleFrames,
                                         timePerFrame: 0.1)
        // run idle animation 1x for attack cooldown
        let idle = SKAction.repeat(idleAction, count: 1)
        let first = (SKAction.sequence([idle]))
        let second = SKAction.repeatForever(idleAction)
        self.run(SKAction.sequence([first, second]), withKey: "idle")
        //self.run(SKAction.repeatForever(idleAction), withKey: "idle")
    }
    
    func runAnimation() {
        let runFrames:[SKTexture] =
            [
                textureAtlas.textureNamed("santa_walk000"),
                textureAtlas.textureNamed("santa_walk001"),
                textureAtlas.textureNamed("santa_walk002"),
                textureAtlas.textureNamed("santa_walk003"),
                textureAtlas.textureNamed("santa_walk004"),
                textureAtlas.textureNamed("santa_walk005"),
                textureAtlas.textureNamed("santa_walk006"),
                textureAtlas.textureNamed("santa_walk007")]
        let runAction = SKAction.animate(with: runFrames, timePerFrame: 0.15)
        
        let reset = SKAction.run { [weak self] in
            self?.can_attack = true
        }
        let resetAction = SKAction.sequence([SKAction.wait(forDuration: 1.1), reset])
        
        let running = SKAction.group([SKAction.repeatForever(runAction), resetAction])
        
        //let run2Action = SKAction.animate(with: runFrames, timePerFrame: 0.15)
        
        //let running = SKAction.sequence([group, SKAction.repeatForever(run2Action)])
        self.run(running, withKey: "run")
    }
    
    
    
    func attackAnimation(){
        //self.physicsBody?.applyImpulse(CGVector(dx: 4 * sprite_orientation, dy: 0))
        let attackFrames:[SKTexture] =
           [textureAtlas.textureNamed("santa_attack000"),
            textureAtlas.textureNamed("santa_attack001"),
            textureAtlas.textureNamed("santa_attack002"),
            textureAtlas.textureNamed("santa_attack003"),
            textureAtlas.textureNamed("santa_attack004")]
    let attackFrames2:[SKTexture] = [
            textureAtlas.textureNamed("santa_attack005"),
            textureAtlas.textureNamed("santa_attack006"),
            textureAtlas.textureNamed("santa_attack007"),
            textureAtlas.textureNamed("santa_attack008")]
    let attackFrames3:[SKTexture] = [
            textureAtlas.textureNamed("santa_attack009"),
            textureAtlas.textureNamed("santa_attack010"),
            textureAtlas.textureNamed("santa_attack011"),
            textureAtlas.textureNamed("santa_attack012"),
            textureAtlas.textureNamed("santa_attack013")]
    let attackFrames4:[SKTexture] = [
            textureAtlas.textureNamed("santa_attack014"),
            textureAtlas.textureNamed("santa_attack015"),
            textureAtlas.textureNamed("santa_attack016"),
            textureAtlas.textureNamed("santa_attack017")]
    let attackFrames5:[SKTexture] = [
            textureAtlas.textureNamed("santa_attack018"),
            textureAtlas.textureNamed("santa_attack019"),
            textureAtlas.textureNamed("santa_attack020"),
            textureAtlas.textureNamed("santa_attack021"),
            textureAtlas.textureNamed("santa_attack022"),
            textureAtlas.textureNamed("santa_attack023"),
            textureAtlas.textureNamed("santa_attack024"),
            textureAtlas.textureNamed("santa_attack025"),
            textureAtlas.textureNamed("santa_attack026"),
            textureAtlas.textureNamed("santa_attack027"),
            textureAtlas.textureNamed("santa_attack028"),
            textureAtlas.textureNamed("santa_attack029")]
        let attackAction = SKAction.animate(with: attackFrames, timePerFrame: 0.1)
        let attack2Action = SKAction.animate(with: attackFrames2, timePerFrame: 0.1)
        let attack3Action = SKAction.animate(with: attackFrames3, timePerFrame: 0.1)
        let attack4Action = SKAction.animate(with: attackFrames4, timePerFrame: 0.1)
        let attack5Action = SKAction.animate(with: attackFrames5, timePerFrame: 0.1)
        let damageSet = SKAction.run { [weak self] in
            self?.giving_damage = true
            self?.attack_num = 0
        }
        
        let damageSet2 = SKAction.run { [weak self] in
            self?.giving_damage = true
            self?.attack_num = 1
        }
        
        let reset = SKAction.run { [weak self] in
            self?.giving_damage = false
            
        }
        
        let reset2 = SKAction.run { [weak self] in
            //self?.giving_damage = false
            self?.movement_status = constants.finished_attack
        }
        let move = SKAction.run { [weak self] in
            if(self?.sprite_orientation == constants.orientation_left && (self?.point_log.x ?? 0) > (self?.position.x ?? 0)){
                self?.sprite_orientation = constants.orientation_right
                self?.run(SKAction.scaleX(to: 1, duration: 0))
            } else if(self?.sprite_orientation == constants.orientation_right && (self?.point_log.x ?? 0) < (self?.position.x ?? 0)){
                self?.sprite_orientation = constants.orientation_left
                self?.run(SKAction.scaleX(to: -1, duration: 0))
            }
            self?.physicsBody?.applyImpulse(CGVector(dx: (self?.sprite_orientation ?? 0) * 10, dy: 0))
        }
        
        // after attack is finished, go to idle animation for a while
        self.run(SKAction.sequence([attackAction, damageSet, move, attack2Action, reset, attack3Action, damageSet2, move, attack4Action, reset, attack5Action, reset2]), withKey: "attack")
    }
    
    func deathAnimation(){
        self.giving_damage = false
        self.removeAllActions()
        let deathFrames:[SKTexture] =
            [textureAtlas.textureNamed("santa_death000"),
             textureAtlas.textureNamed("santa_death001"),
             textureAtlas.textureNamed("santa_death002"),
             textureAtlas.textureNamed("santa_death003"),
             textureAtlas.textureNamed("santa_death004"),
             textureAtlas.textureNamed("santa_death005"),
             textureAtlas.textureNamed("santa_death006"),
             textureAtlas.textureNamed("santa_death007"),
             textureAtlas.textureNamed("santa_death008"),
             textureAtlas.textureNamed("santa_death009"),
             textureAtlas.textureNamed("santa_death010"),
             textureAtlas.textureNamed("santa_death011"),
             textureAtlas.textureNamed("santa_death012"),
             textureAtlas.textureNamed("santa_death013"),
             textureAtlas.textureNamed("santa_death014"),
             textureAtlas.textureNamed("santa_death015"),
             textureAtlas.textureNamed("santa_death016"),
             textureAtlas.textureNamed("santa_death017"),
             textureAtlas.textureNamed("santa_death018"),
             textureAtlas.textureNamed("santa_death019"),
             textureAtlas.textureNamed("santa_death020"),
             textureAtlas.textureNamed("santa_death021"),
             textureAtlas.textureNamed("santa_death022"),
             textureAtlas.textureNamed("santa_death023"),
             textureAtlas.textureNamed("santa_death024"),
             textureAtlas.textureNamed("santa_death025"),
             textureAtlas.textureNamed("santa_death026"),
             textureAtlas.textureNamed("santa_death027"),
             textureAtlas.textureNamed("santa_death028"),
             textureAtlas.textureNamed("santa_death029"),
             textureAtlas.textureNamed("santa_death030"),
             textureAtlas.textureNamed("santa_death031"),
             textureAtlas.textureNamed("santa_death032"),
             textureAtlas.textureNamed("santa_death033")]
        let death = SKAction.animate(with: deathFrames, timePerFrame: 0.12)
        let remove = SKAction.run { [weak self] in
            self?.removeAllChildren()
            self?.removeFromParent()
        }
        self.run(SKAction.sequence([death, remove]), withKey: "death")
    }
    
    func taunt() {
        self.removeAction(forKey: "idle")
        self.removeAction(forKey: "attack")
        self.removeAction(forKey: "run")
        let tauntFrames:[SKTexture] =
            [ textureAtlas.textureNamed("santa_taunt000"),
              textureAtlas.textureNamed("santa_taunt001"),
              textureAtlas.textureNamed("santa_taunt002"),
              textureAtlas.textureNamed("santa_taunt003"),
              textureAtlas.textureNamed("santa_taunt004"),
              textureAtlas.textureNamed("santa_taunt005"),
              textureAtlas.textureNamed("santa_taunt006"),
              textureAtlas.textureNamed("santa_taunt007"),
              textureAtlas.textureNamed("santa_taunt008")]
        let taunt2Frames:[SKTexture] = [
              textureAtlas.textureNamed("santa_taunt009"),
              textureAtlas.textureNamed("santa_taunt010"),
              textureAtlas.textureNamed("santa_taunt011"),
              textureAtlas.textureNamed("santa_taunt012"),
              textureAtlas.textureNamed("santa_taunt013"),
              textureAtlas.textureNamed("santa_taunt014"),
              textureAtlas.textureNamed("santa_taunt015")]
        let tauntAction = SKAction.animate(with: tauntFrames,
                                         timePerFrame: 0.05)
        let taunt2Action = SKAction.animate(with: taunt2Frames,
                                         timePerFrame: 0.05)
        let do_chidori = SKAction.run { [weak self] in
            self?.chidori()
        }
        self.run(SKAction.sequence([tauntAction, do_chidori, taunt2Action]), withKey: "taunt")
        
        
    }
    
    func chidori(){
        shooting_lightning = true
        let lightningFrames:[SKTexture] =
            [
              textureAtlas.textureNamed("lightning_1"),
              textureAtlas.textureNamed("lightning_2"),
              textureAtlas.textureNamed("lightning_3"),
              textureAtlas.textureNamed("lightning_4"),
              textureAtlas.textureNamed("lightning_5"),
              textureAtlas.textureNamed("lightning_6")]
        let lightningAction = SKAction.animate(with: lightningFrames,
                                         timePerFrame: 0.1)
        let reset = SKAction.run { [weak self] in
            self?.giving_damage = false
            self?.movement_status = constants.finished_attack
            self?.shooting_lightning = false
            self?.removeAction(forKey: "lightning")
            self?.removeAction(forKey: "lightning3")
            self?.lightning.texture = nil
            self?.removeAction(forKey: "taunt")
        }
        
        let disappear3 = SKAction.run { [weak self] in
            self?.lightning3.texture = nil
        }

        
        let setDmg = SKAction.run { [weak self] in
            self?.giving_damage = true
            self?.attack_num = 2
        }
        
        lightning.run(SKAction.sequence([setDmg, SKAction.repeat(lightningAction, count: 3), reset]), withKey: "lightning")
        lightning3.run(SKAction.sequence([SKAction.repeat(lightningAction, count:3), disappear3]), withKey: "lightning3")
    }
    
    func fireMode(){
        hp_max = CGFloat(600)
        let hp_restored = (hp_max - hp)
        hp = hp_max
        hpRestored.text = "+\(Int(hp_restored))"
        
        if sprite_orientation == constants.orientation_left{
            hpRestored.run(SKAction.scaleX(to: -1, duration: 0))
        } else {
            dmgTicker.run(SKAction.scaleX(to: 1, duration: 0))
        }
        hpRestored.run(SKAction.fadeOut(withDuration: 0.5))
        hpBar.size = CGSize(width: CGFloat(hp/hp_max * 30), height: CGFloat(5))
        
        if let flames = SKEmitterNode(fileNamed: "Anger"){
            flames.name = "anger"
            flames.particleZPosition = 1
            flames.position = CGPoint(x: 0, y:  -constants.santa_height/2)
            self.addChild(flames)
            flames.targetNode = self
        }
        
        fire_mode = true
        
    }
    
    func sparks(){
        pre_coords[0] = 0
        pre_coords[1] = 0
        pre_coords[2] = 0
        pre_coords[3] = 0
        if let pre = SKEmitterNode(fileNamed: "PreAttack"){
            let point = CGFloat.random(in: -constants.game_width/2...constants.game_width/2)
            pre_coords[0] = point
            pre.name = "sparks"
            pre.particleZPosition = 1
            pre.position = CGPoint(x: point, y:  65)
            self.parent?.parent?.addChild(pre)
            pre.targetNode = nil
        }
        if let pre2 = SKEmitterNode(fileNamed: "PreAttack"){
            var point = CGFloat(0)
            while (true) {
                point = CGFloat.random(in: -constants.game_width/2...constants.game_width/2)
                if abs(point - pre_coords[0]) > 120 {
                    break
                }
            }
            pre_coords[1] = point
            pre2.name = "sparks"
            pre2.particleZPosition = 1
            pre2.position = CGPoint(x: point, y:  65)
            self.parent?.parent?.addChild(pre2)
            pre2.targetNode = nil
        }
        
        if let pre3 = SKEmitterNode(fileNamed: "PreAttack"){
            var point = CGFloat(0)
            while (true) {
                point = CGFloat.random(in: -constants.game_width/2...constants.game_width/2)
                if abs(point - pre_coords[0]) > 120 && abs(point - pre_coords[1]) > 120{
                    break
                }
            }
            pre_coords[2] = point
            pre3.name = "sparks"
            pre3.particleZPosition = 1
            pre3.position = CGPoint(x: point, y:  65)
            self.parent?.parent?.addChild(pre3)
            pre3.targetNode = nil
        }
        if let pre4 = SKEmitterNode(fileNamed: "PreAttack"){
            var point = CGFloat(0)
            while (true) {
                point = CGFloat.random(in: -constants.game_width/2...constants.game_width/2)
                if abs(point - pre_coords[0]) > 120 && abs(point - pre_coords[1]) > 120 && abs(point - pre_coords[2]) > 120{
                    break
                }
            }
            pre_coords[3] = point
            pre4.name = "sparks"
            pre4.particleZPosition = 1
            pre4.position = CGPoint(x: point, y:  65)
            self.parent?.parent?.addChild(pre4)
            pre4.targetNode = nil
        }
    }
    
    func summonFlames(){
        if let flame = SKEmitterNode(fileNamed: "Flame"){
            flame.name = "flames"
            flame.particleZPosition = 1
            flame.position = CGPoint(x: pre_coords[0], y:  65)
            self.parent?.parent?.addChild(flame)
            flame.targetNode = nil
        }
        if let flame2 = SKEmitterNode(fileNamed: "Flame"){
            flame2.name = "flames"
            flame2.particleZPosition = 1
            flame2.position = CGPoint(x: pre_coords[1], y:  65)
            self.parent?.parent?.addChild(flame2)
            flame2.targetNode = nil
        }
        if let flame3 = SKEmitterNode(fileNamed: "Flame"){
            flame3.name = "flames"
            flame3.particleZPosition = 1
            flame3.position = CGPoint(x: pre_coords[2], y:  65)
            self.parent?.parent?.addChild(flame3)
            flame3.targetNode = nil
        }
        if let flame4 = SKEmitterNode(fileNamed: "Flame"){
            flame4.name = "flames"
            flame4.particleZPosition = 1
            flame4.position = CGPoint(x: pre_coords[3], y:  65)
            self.parent?.parent?.addChild(flame4)
            flame4.targetNode = nil
        }
        flames_summoned = true
        
    }
    
    func takeDamage(dmg: Int) {
        hp -= CGFloat(dmg)
        if hp > 0 {
        hpBar.size = CGSize(width: CGFloat(hp/hp_max * 30), height: CGFloat(5))
        } else {
            hpBar.removeFromParent()
        }
        dmgTicker.text = "-\(dmg)"
        if sprite_orientation == constants.orientation_left{
            dmgTicker.run(SKAction.scaleX(to: -1, duration: 0))
            dmgTicker.alpha = 1
        } else {
            dmgTicker.alpha = 1
            dmgTicker.run(SKAction.scaleX(to: 1, duration: 0))
        }
       
        let fade = SKAction.fadeOut(withDuration: 1)
        dmgTicker.run(fade)
        if(hp <= 0){
            is_alive = false
            let hp_drop = HealthPotion()
            hp_drop.position = CGPoint(x: 0, y: self.position.y + 50)
            hp_drop.name = "update_hp"
            hp_drop.setExalted()
            self.parent?.addChild(hp_drop)
            if let gameScene = self.parent?.parent as? GameScene {
                gameScene.onEnemyDeath()
            }
            deathAnimation()
        }
    }
    
    
    // rectangle & circle collision detection
    func checkOverlap(R: CGFloat, Xc: CGFloat, Yc: CGFloat,
                      X1: CGFloat, Y1: CGFloat,
                      X2: CGFloat, Y2: CGFloat) -> Bool
    {
        let Xn = max(X1, min(Xc, X2));
        let Yn = max(Y1, min(Yc, Y2));
        let Dx = Xn - Xc;
        let Dy = Yn - Yc;
        return (Dx * Dx + Dy * Dy) <= R * R;
    }
    
    func rectRect(r1x: CGFloat, r1y: CGFloat, r1w: CGFloat, r1h: CGFloat, r2x: CGFloat, r2y: CGFloat, r2w: CGFloat, r2h: CGFloat)->Bool {
      // are the sides of one rectangle touching the other?
        
        
        
      if (r1x + r1w >= r2x &&    // r1 right edge past r2 left edge
          r1x <= r2x + r2w &&    // r1 left edge past r2 right edge
          r1y + r1h >= r2y &&    // r1 top edge past r2 bottom edge
          r1y <= r2y + r2h) {    // r1 bottom edge past r2 top
            return true;
      }
      return false;
    }
    
    func shouldGiveDamage(location: CGPoint) -> Bool {
        if !giving_damage && !flames_summoned{
            return false
        }
        
        let r1x = location.x - CGFloat(constants.player_width/2)
        let r1w = CGFloat(constants.player_width)
        let r1y = location.y - CGFloat(constants.player_height/2)
        let r1h = CGFloat(constants.player_height)
        
        var r2x = CGFloat(0)
        var r2w = CGFloat(0)
        var r2y = CGFloat(0)
        var r2h = CGFloat(0)
        
        var r2x2 = CGFloat(0)
        var r2w2 = CGFloat(0)
        var r2y2 = CGFloat(0)
        var r2h2 = CGFloat(0)
        var b = false
        if giving_damage {
            switch(attack_num){
            case 0: // sword attack
                r2x = self.position.x + CGFloat(sprite_orientation) * attack_fieldx_shift - CGFloat(56/2)
                r2w = CGFloat(56)
                r2y = self.position.y + attack_fieldy_shift - CGFloat(10/2)
                r2h = CGFloat(10)
                b = rectRect(r1x: r1x, r1y: r1y, r1w: r1w, r1h: r1h, r2x: r2x, r2y: r2y, r2w: r2w, r2h: r2h)
            case 1: // hammer attack
                r2x = self.position.x + CGFloat(sprite_orientation) * attack2_fieldx_shift - CGFloat(25/2)
                r2w = CGFloat(25)
                r2y = self.position.y + attack2_fieldy_shift - CGFloat(50/2)
                r2h = CGFloat(50)
                
                r2x2 = self.position.x + CGFloat(sprite_orientation) * attack3_fieldx_shift - CGFloat(25/2)
                r2w2 = CGFloat(25)
                r2y2 = self.position.y + attack3_fieldy_shift - CGFloat(70/2)
                r2h2 = CGFloat(70)
                b = rectRect(r1x: r1x, r1y: r1y, r1w: r1w, r1h: r1h, r2x: r2x, r2y: r2y, r2w: r2w, r2h: r2h) ||
                    rectRect(r1x: r1x, r1y: r1y, r1w: r1w, r1h: r1h, r2x: r2x2, r2y: r2y2, r2w: r2w2, r2h: r2h2)
            case 2: // lightning attack
                r2x = self.position.x + CGFloat(sprite_orientation) * attack4_fieldx_shift - CGFloat(120/2)
                r2w = CGFloat(120)
                r2y = self.position.y + attack4_fieldy_shift - CGFloat(25/2)
                r2h = CGFloat(25)
                b = rectRect(r1x: r1x, r1y: r1y, r1w: r1w, r1h: r1h, r2x: r2x, r2y: r2y, r2w: r2w, r2h: r2h)
                break
            default:
                break
            }
        }
        if flames_summoned {
            r2w = CGFloat(30)
            r2y = CGFloat(65)
            r2h = CGFloat(135)
            for i in 0...3 {
                r2x = pre_coords[i] - CGFloat(15)
                if rectRect(r1x: r1x, r1y: r1y, r1w: r1w, r1h: r1h, r2x: r2x, r2y: r2y, r2w: r2w, r2h: r2h) {
                    if !b { // prioritize higher damage attacks from santa
                        attack_num = 3
                    }
                    return true
                }
            }
        }
        return b
        //return rectRect(r1x: r1x, r1y: r1y, r1w: r1w, r1h: r1h, r2x: r2x, r2y: r2y, r2w: r2w, r2h: r2h)
    }
    
}
