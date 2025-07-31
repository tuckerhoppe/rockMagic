//
//  GameViewController.swift
//  RockMagic
//
//  Created by Tucker Hoppe on 4/28/25.
//

import UIKit
import SpriteKit
import GameplayKit

class GameViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let view = self.view as! SKView? {
            // Load the SKScene from 'GameScene.sks'
//            if let scene = GameScene(fileNamed: "GameScene") {
//                scene.scaleMode = .aspectFill
//                view.presentScene(scene)
//                //scene.setupGestures(in: view) // now this works!
//            }

            // --- LOAD THE TEST SCENE INSTEAD ---
            //let scene = TestScene_EnemyToss(size: view.bounds.size)
            let scene = MainMenuScene(size: view.bounds.size)
            scene.scaleMode = .aspectFill
            
            // Present the new scene
            view.presentScene(scene)
            
            
            view.ignoresSiblingOrder = true
            
            view.showsFPS = true
            view.showsNodeCount = true
        }
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
}
