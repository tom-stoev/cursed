//
//  LevelManager.swift
//  hi
//
//  Created by Tom Stoev on 8/16/21.
//

import SpriteKit
class LevelManager {
   let LevelNames:[String] = ["Level0", "Level1", "Level2", "Level3", "Level4", "Level5", "Level6"]
   var encounters: [SKNode] = []
 
    
   init() {
        for encounterFileName in LevelNames {
        let encounterNode = SKNode()
        encounterNode.name = "level_root_node"
            if let encounterScene = SKScene(fileNamed: encounterFileName) {
                for child in encounterScene.children {
                    let copyOfNode = type(of: child).init()
                    copyOfNode.position = child.position
                    copyOfNode.name = child.name
                    encounterNode.addChild(copyOfNode)
                }
            }
            encounters.append(encounterNode)
        }
   }

    func addEncountersToScene(gameScene:SKNode, level: Int) {
            gameScene.addChild(encounters[level])
    }

}
