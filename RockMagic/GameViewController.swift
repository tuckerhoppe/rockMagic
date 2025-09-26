//
//  GameViewController.swift
//  RockMagic
//
//  Created by Tucker Hoppe on 4/28/25.
//

import UIKit
import SpriteKit
import GameplayKit

class GameViewController: UIViewController, GameSceneDelegate, MainMenuSceneDelegate, HighScoreSceneDelegate {
    
    private var isShowingHighScoreAlert = false

    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        // --- ADD THIS DEFINITIVE TEST BLOCK ---
            // This code attempts to manually find and load the font file.
            
            if let fontURL = Bundle.main.url(forResource: "VT323-Regular", withExtension: "ttf") {
                var error: Unmanaged<CFError>?
                if CTFontManagerRegisterFontsForURL(fontURL as CFURL, .process, &error) {
                    print("✅ SUCCESS: Font was found and successfully registered.")
                    // Now, run your font list printout again to confirm.
                    for family in UIFont.familyNames.sorted() {
                        if family.contains("Press Start") {
                            print("✅ FOUND IT! Family: \(family), Names: \(UIFont.fontNames(forFamilyName: family))")
                        }
                    }
                } else {
                    print("❌ ERROR: Font was found, but failed to register. Error: \(error!)")
                }
            } else {
                print("❌ CRITICAL ERROR: The font file 'PressStart2P-Regular.ttf' could not be found in the app bundle. This is why it's not loading.")
            }
        
        
        if let view = self.view as! SKView? {
            
            let scene = MainMenuScene(size: view.bounds.size)
            scene.scaleMode = .aspectFill
            // --- THE FIX: Set the delegate ---
            // 2. Tell the menu that this view controller is its delegate.
            scene.menuDelegate = self
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
    
    // --- 3. Implement the delegate function ---
    // This is the function that will be called by the scene.
    func gameScene(_ scene: GameScene, didRequestHighScoreInputWith score: Int) {
        guard !isShowingHighScoreAlert else { return }
                isShowingHighScoreAlert = true
        
        let alert = UIAlertController(title: "New High Score!", message: "You got a new high score of \(score). Please enter your Name.", preferredStyle: .alert)
        
        alert.addTextField { textField in
            textField.placeholder = "Player Name"
            textField.autocapitalizationType = .allCharacters
        }
        
        let submitAction = UIAlertAction(title: "Submit", style: .default) { _ in
            if let textField = alert.textFields?.first, let initials = textField.text {
                let finalInitials = String(initials.prefix(14)).uppercased()
                
                // After getting the initials, save the score.
                CloudKitManager.shared.saveHighScore(playerName: finalInitials.isEmpty ? "AAA" : finalInitials, score: score) { error in
                    // Finally, tell the scene to show the game over menu.
                    //scene.displayGameOverNode()
                }
            }
        }
        
        alert.addAction(submitAction)
        self.present(alert, animated: true)
    }
    
    func gameSceneDidRestart(_ scene: GameScene) {
        // Reset high score alert flag so alerts work again
        isShowingHighScoreAlert = false
    }

    // 2. Add the new required function
    func highScoreSceneDidRequestMainMenu(_ scene: HighScoreScene) {
        guard let view = self.view as? SKView else { return }
        
        // Create and present the main menu
        let mainMenu = MainMenuScene(size: view.bounds.size)
        mainMenu.scaleMode = .aspectFill
        mainMenu.menuDelegate = self // Don't forget to set the delegate for the menu!
        view.presentScene(mainMenu, transition: .fade(withDuration: 1.0))
    }
    
    
    // --- GameSceneDelegate ---
    // This is called when the "Exit to Menu" button is tapped in the game.
    func gameSceneDidRequestMainMenu(_ scene: GameScene) {
        guard let view = self.view as? SKView else { return }
        
        scene.gameDelegate = nil // prevent stale callbacks
        
        let mainMenu = MainMenuScene(size: view.bounds.size)
        mainMenu.scaleMode = .aspectFill
        mainMenu.menuDelegate = self // Correctly set the delegate for the new menu
        view.presentScene(mainMenu, transition: .fade(withDuration: 1.0))
    }
    
    // --- 3. IMPLEMENT THE NEW DELEGATE FUNCTION ---
    // This function will be called when the start button is tapped in the menu.
//    func mainMenuDidTapStart(_ scene: MainMenuScene) {
//        guard let view = self.view as? SKView else { return }
//        
//        // 1. Create the GameScene here.
//        if let gameScene = GameScene(fileNamed: "GameScene") {
//            
//            // 2. Correctly set its delegate.
//            gameScene.gameDelegate = self
//            isShowingHighScoreAlert = false
//            // 3. Present the fully configured scene.
//            gameScene.scaleMode = .aspectFill
//            let transition = SKTransition.fade(withDuration: 1.0)
//            view.presentScene(gameScene, transition: transition)
//        }
//    }
    
    // In GameViewController.swift

    // --- REPLACE mainMenuDidTapStart with this new function ---
    func mainMenu(_ scene: MainMenuScene, didSelectMode mode: gameMode) {
        // 1. Set the game mode in the GameManager.
        GameManager.shared.currentGameMode = mode
        
        // 2. The rest of the logic is the same as before.
        guard let view = self.view as? SKView else { return }
        
        if let gameScene = GameScene(fileNamed: "GameScene") {
            gameScene.gameDelegate = self
            isShowingHighScoreAlert = false
            gameScene.scaleMode = .aspectFill
            let transition = SKTransition.fade(withDuration: 1.0)
            view.presentScene(gameScene, transition: transition)
        }
    }
    
    // --- ADD THIS NEW FUNCTION ---
    func mainMenuDidTapHighScores(_ scene: MainMenuScene) {
        guard let view = self.view as? SKView else { return }

        // The controller is now responsible for creating the scene
        let highScoreScene = HighScoreScene(size: view.bounds.size)
        highScoreScene.scaleMode = .aspectFill
        
        // THIS IS THE KEY: Set the delegate so the "Back" button will work!
        highScoreScene.highScoreDelegate = self
        
        // Present the fully configured scene
        view.presentScene(highScoreScene, transition: .fade(withDuration: 0.5))
    }
    
    // In GameViewController.swift

    /// Presents a pop-up to the user to enter their initials for a high score.
//    func promptForPlayerInitials(score: Int, completion: @escaping (String) -> Void) {
//        let alert = UIAlertController(title: "New High Score!", message: "You got a new high score of \(score). Please enter your initials.", preferredStyle: .alert)
//        
//        alert.addTextField { textField in
//            textField.placeholder = "AAA"
//            textField.autocapitalizationType = .allCharacters
//        }
//        
//        let submitAction = UIAlertAction(title: "Submit", style: .default) { _ in
//            if let textField = alert.textFields?.first, let initials = textField.text {
//                // Limit to 3 characters
//                let finalInitials = String(initials.prefix(3)).uppercased()
//                completion(finalInitials.isEmpty ? "AAA" : finalInitials)
//            }
//        }
//        
//        alert.addAction(submitAction)
//        self.present(alert, animated: true)
//    }
}
