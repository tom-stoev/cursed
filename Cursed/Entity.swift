//
//  GameSprite.swift
//  hi
//
//  Created by Tom Stoev on 8/14/21.
//
import SpriteKit
protocol Entity {
    func idleAnimation()
    func attackAnimation()
    func update(pos: CGPoint, status: Bool, orientation: Int, damage: Int)
    func deathAnimation()
    func takeDamage(dmg: Int)
    func addIndicators()
}
