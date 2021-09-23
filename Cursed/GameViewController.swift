//
//  GameViewController.swift
//  Cursed
//
//  Created by Tom Stoev on 9/12/21.
//

import UIKit
import SpriteKit
import GameKit

class GameViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        authenticatePlayer()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        if let view = self.view as! SKView? {
            // Load the SKScene from 'GameScene.sks'

            let scene = MenuScene(size: view.bounds.size)
            scene.scaleMode = .aspectFill
            view.presentScene(scene)
            view.ignoresSiblingOrder = true
            //view.showsFPS = true
            //view.showsNodeCount = true
        }
    }

    override var shouldAutorotate: Bool {
        return true
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .allButUpsideDown
        } else {
            return .all
        }
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    func authenticatePlayer(){
        let localPlayer = GKLocalPlayer.local
        localPlayer.authenticateHandler =
            {(viewController, error) -> Void in
            if viewController != nil {
            // They are not logged in, show the log in:
                self.present(viewController!, animated: true, completion: nil)
            } else if localPlayer.isAuthenticated {
                
            }
        }
    }

}
