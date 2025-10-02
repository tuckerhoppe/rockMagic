//
//  MainMenuScene.swift
//  RockMagic
//
//  Created by Tucker Hoppe on 7/22/25.
//

// --- ADD THIS PROTOCOL at the top of the file ---
protocol MainMenuSceneDelegate: AnyObject {
    //func mainMenuDidTapStart(_ scene: MainMenuScene)
    //func mainMenu(_ scene: MainMenuScene, didSelectMode mode: gameMode)
    func mainMenu(_ scene: MainMenuScene, didSelectLevelID id: Int)
    func mainMenuDidTapHighScores(_ scene: MainMenuScene)
}

import Foundation
import SpriteKit

class MainMenuScene: SKScene {
    
    // --- ADD THIS NEW PROPERTY ---
    weak var menuDelegate: MainMenuSceneDelegate?

    // --- Properties ---
    private var instructionsOverlay: SKNode!
    private var levelSelectOverlay: SKNode!
    private var mainMenuButtons: [SKNode] = []
    
    // --- 1. Use a simpler initializer ---
    override init(size: CGSize) {
        super.init(size: size)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func didMove(to view: SKView) {
        backgroundColor = .darkGray
        
        // --- Main Menu Buttons ---
        let titleLabel = SKLabelNode(fontNamed: GameManager.shared.fontName)
        titleLabel.text = "RockMagic"
        titleLabel.fontSize = 60
        titleLabel.fontColor = .white
        titleLabel.position = CGPoint(x: self.size.width / 2, y: self.size.height * 0.75)
        addChild(titleLabel)
        
//        let startButton = SKLabelNode(fontNamed: GameManager.shared.fontName)
//        startButton.text = "Start Game"
//        startButton.fontSize = 40
//        startButton.fontColor = .cyan
//        startButton.position = CGPoint(x: self.size.width / 2, y: self.size.height * 0.5)
//        startButton.name = "startButton"
//        addChild(startButton)
        
        let StoryButton = SKLabelNode(fontNamed: GameManager.shared.fontName)
        StoryButton.text = "Story"
        StoryButton.fontSize = 40
        StoryButton.fontColor = .cyan
        StoryButton.position = CGPoint(x: self.size.width / 2, y: self.size.height * 0.55)
        StoryButton.name = "storyButton"
        addChild(StoryButton)
        
        let survivalButton = SKLabelNode(fontNamed: GameManager.shared.fontName)
        survivalButton.text = "Survival"
        survivalButton.fontSize = 40
        survivalButton.fontColor = .cyan
        survivalButton.position = CGPoint(x: self.size.width / 2, y: StoryButton.position.y - 60)
        survivalButton.name = "survivalButton"
        addChild(survivalButton)
        
        let defenseButton = SKLabelNode(fontNamed: GameManager.shared.fontName)
        defenseButton.text = "Defense"
        defenseButton.fontSize = 40
        defenseButton.fontColor = .cyan
        defenseButton.position = CGPoint(x: (self.size.width / 3) * 2, y: StoryButton.position.y - 60)
        defenseButton.name = "defenseButton"
        addChild(defenseButton)
        
        let attackButton = SKLabelNode(fontNamed: GameManager.shared.fontName)
        attackButton.text = "Attack"
        attackButton.fontSize = 40
        attackButton.fontColor = .cyan
        attackButton.position = CGPoint(x: self.size.width / 3, y: StoryButton.position.y - 60)
        attackButton.name = "attackButton"
        addChild(attackButton)
        
        let instructionsButton = SKLabelNode(fontNamed: GameManager.shared.fontName)
        instructionsButton.text = "Instructions"
        instructionsButton.fontSize = 40
        instructionsButton.fontColor = .cyan
        instructionsButton.position = CGPoint(x: self.size.width / 2, y: defenseButton.position.y - 60)
        instructionsButton.name = "instructionsButton"
        addChild(instructionsButton)
        
        // --- ADD THE NEW HIGH SCORES BUTTON ---
        let highScoresButton = SKLabelNode(fontNamed: GameManager.shared.fontName)
        highScoresButton.text = "High Scores"
        highScoresButton.fontSize = 40
        highScoresButton.fontColor = .cyan
        highScoresButton.position = CGPoint(x: self.size.width / 2, y: instructionsButton.position.y - 60)
        highScoresButton.name = "highScoresButton"
        addChild(highScoresButton)
        
        // Keep a reference to the main buttons to easily hide/show them
        mainMenuButtons = [titleLabel, survivalButton, defenseButton, instructionsButton, highScoresButton, attackButton, StoryButton]
        // --- Setup the hidden instructions overlay ---
        setupInstructionsOverlay()
        setupLevelSelectOverlay() // Call the new setup function
    }
    
    // --- ADD THIS ENTIRE NEW FUNCTION ---
    private func setupLevelSelectOverlay() {
        levelSelectOverlay = SKNode()
        
        let panel = SKSpriteNode(color: .black.withAlphaComponent(0.8), size: self.size)
        panel.position = CGPoint(x: self.size.width / 2, y: self.size.height / 2)
        levelSelectOverlay.addChild(panel)
        
        let title = SKLabelNode(fontNamed: GameManager.shared.fontName)
        title.text = "Select Level"
        title.fontSize = 48
        title.fontColor = .white
        title.position = CGPoint(x: self.size.width / 2, y: self.size.height * 0.80)
        levelSelectOverlay.addChild(title)

        // --- Create Level Buttons ---
        let level1Button = SKLabelNode(fontNamed: GameManager.shared.fontName)
        level1Button.text = "Level 1"
        level1Button.fontSize = 40
        level1Button.fontColor = .cyan
        level1Button.position = CGPoint(x: self.size.width / 2, y: self.size.height * 0.70)
        level1Button.name = "level_1" // Name corresponds to level ID
        levelSelectOverlay.addChild(level1Button)
        
        let level2Button = SKLabelNode(fontNamed: GameManager.shared.fontName)
        level2Button.text = "Level 2"
        level2Button.fontSize = 40
        level2Button.fontColor = .cyan
        level2Button.position = CGPoint(x: self.size.width / 2, y: level1Button.position.y - 50)
        level2Button.name = "level_2"
        levelSelectOverlay.addChild(level2Button)
        
        let level3Button = SKLabelNode(fontNamed: GameManager.shared.fontName)
        level3Button.text = "Level 3"
        level3Button.fontSize = 40
        level3Button.fontColor = .cyan
        level3Button.position = CGPoint(x: self.size.width / 2, y: level2Button.position.y - 50)
        level3Button.name = "level_3"
        levelSelectOverlay.addChild(level3Button)
        
        // --- Create a back button for this overlay ---
        let backButton = SKLabelNode(fontNamed: "Menlo-Bold")
        backButton.text = "Back to Menu"
        backButton.fontSize = 30
        backButton.fontColor = .white
        backButton.position = CGPoint(x: self.size.width / 2, y: self.size.height * 0.15)
        backButton.name = "backToMenuButton"
        levelSelectOverlay.addChild(backButton)
        
        levelSelectOverlay.isHidden = true
        addChild(levelSelectOverlay)
    }
    
    // In MainMenuScene.swift

    private func setupInstructionsOverlay() {
        instructionsOverlay = SKNode()
        
        let panel = SKSpriteNode(color: .black.withAlphaComponent(0.8), size: self.size)
        panel.position = CGPoint(x: self.size.width / 2, y: self.size.height / 2)
        instructionsOverlay.addChild(panel)
        
        let title = SKLabelNode(fontNamed: "Menlo-Bold")
        title.text = "How to Play"
        title.fontSize = 48
        title.fontColor = .white
        title.position = CGPoint(x: self.size.width / 2, y: self.size.height * 0.85)
        instructionsOverlay.addChild(title)
        print(title.position)
        
        // --- THE FIX: Create and add the image gallery ---
        let instructionImages = GameManager.shared.instructionImages
        let gallerySize = CGSize(width: self.size.width * 0.8, height: self.size.height * 0.75)
        let gallery = ImageGalleryNode(size: gallerySize, imageNames: instructionImages)
        gallery.position = CGPoint(x: self.size.width / 2, y: self.size.height / 2)
        instructionsOverlay.addChild(gallery)
        
        let backButton = SKLabelNode(fontNamed: "Menlo-Bold")
        backButton.text = "Back"
        backButton.fontSize = 30
        backButton.fontColor = .cyan
        backButton.position = CGPoint(x: self.size.width / 2, y: self.size.height * 0.15)
        backButton.name = "backButton"
        instructionsOverlay.addChild(backButton)
        
        instructionsOverlay.isHidden = true
        addChild(instructionsOverlay)
    }
        
    // --- Touch Handling ---
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        let tappedNode = nodes(at: location).first
        
        // --- THE FIX: Handle the new buttons ---
        
        // --- THE FIX: Check for the new level buttons ---
        if let name = tappedNode?.name, name.starts(with: "level_") {
            // Extract the number from the name (e.g., "level_1" -> 1)
            let levelIDString = name.replacingOccurrences(of: "level_", with: "")
            if let levelID = Int(levelIDString) {
                // Tell the delegate which level to start.
                menuDelegate?.mainMenu(self, didSelectLevelID: levelID)
            }
        } else if tappedNode?.name == "storyButton" {
            // Tell the delegate to start a survival game.
            showLevelSelect()
        } else if tappedNode?.name == "survivalButton" {
            // Tell the delegate to start a survival game.
            menuDelegate?.mainMenu(self, didSelectLevelID: -1)
        } else if tappedNode?.name == "defenseButton" {
            // Tell the delegate to start a defense game.
            menuDelegate?.mainMenu(self, didSelectLevelID: -2)
        } else if tappedNode?.name == "attackButton" {
            // Tell the delegate to start a defense game.
            menuDelegate?.mainMenu(self, didSelectLevelID: -3)
            
        }else if tappedNode?.name == "instructionsButton" {
            showInstructions()
        } else if tappedNode?.name == "backButton" {
            hideInstructions()
        } else if tappedNode?.name == "backToMenuButton" {
            hideLevelSelect()
        } else if tappedNode?.name == "highScoresButton" {
            // Transition to the HighScoreScene
//            let highScoreScene = HighScoreScene(size: self.size)
//            
//            highScoreScene.scaleMode = .aspectFill
//            self.view?.presentScene(highScoreScene, transition: .fade(withDuration: 0.5))
            
            showHighScores()
        }
    }
    
    // --- Menu Logic ---
    private func showInstructions() {
        instructionsOverlay.isHidden = false
        mainMenuButtons.forEach { $0.isHidden = true }
    }
    
    private func hideInstructions() {
        instructionsOverlay.isHidden = true
        mainMenuButtons.forEach { $0.isHidden = false }
    }
    
    // --- ADD THESE NEW FUNCTIONS for level select ---
    private func showLevelSelect() {
        levelSelectOverlay.isHidden = false
        mainMenuButtons.forEach { $0.isHidden = true }
    }
    
    private func hideLevelSelect() {
        levelSelectOverlay.isHidden = true
        mainMenuButtons.forEach { $0.isHidden = false }
    }

    
//    private func startGame() {
//        guard let gameScene = GameScene(fileNamed: "GameScene") else { return }
//        gameScene.scaleMode = .aspectFill
//        let transition = SKTransition.fade(withDuration: 1.0)
//        self.view?.presentScene(gameScene, transition: transition)
//    }
    
//    private func startGame() {
//        print("Start button tapped. Notifying delegate...")
//        // Instead of creating the scene here, we tell our delegate to do it.
//        menuDelegate?.mainMenuDidTapStart(self)
//    }
    
    private func showHighScores() {
        menuDelegate?.mainMenuDidTapHighScores(self)
    }
}
