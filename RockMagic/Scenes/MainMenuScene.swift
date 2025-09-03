//
//  MainMenuScene.swift
//  RockMagic
//
//  Created by Tucker Hoppe on 7/22/25.
//

// --- ADD THIS PROTOCOL at the top of the file ---
protocol MainMenuSceneDelegate: AnyObject {
    //func mainMenuDidTapStart(_ scene: MainMenuScene)
    func mainMenu(_ scene: MainMenuScene, didSelectMode mode: gameMode)
    func mainMenuDidTapHighScores(_ scene: MainMenuScene)
}

import Foundation
import SpriteKit

class MainMenuScene: SKScene {
    
    // --- ADD THIS NEW PROPERTY ---
    weak var menuDelegate: MainMenuSceneDelegate?

    // --- Properties ---
    private var instructionsOverlay: SKNode!
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
        let titleLabel = SKLabelNode(fontNamed: "Menlo-Bold")
        titleLabel.text = "RockMagic"
        titleLabel.fontSize = 60
        titleLabel.fontColor = .white
        titleLabel.position = CGPoint(x: self.size.width / 2, y: self.size.height * 0.75)
        addChild(titleLabel)
        
//        let startButton = SKLabelNode(fontNamed: "Menlo-Regular")
//        startButton.text = "Start Game"
//        startButton.fontSize = 40
//        startButton.fontColor = .cyan
//        startButton.position = CGPoint(x: self.size.width / 2, y: self.size.height * 0.5)
//        startButton.name = "startButton"
//        addChild(startButton)
        let survivalButton = SKLabelNode(fontNamed: "Menlo-Regular")
        survivalButton.text = "Survival"
        survivalButton.fontSize = 40
        survivalButton.fontColor = .cyan
        survivalButton.position = CGPoint(x: self.size.width / 2, y: self.size.height * 0.55)
        survivalButton.name = "survivalButton"
        addChild(survivalButton)
        
        let defenseButton = SKLabelNode(fontNamed: "Menlo-Regular")
        defenseButton.text = "Defense"
        defenseButton.fontSize = 40
        defenseButton.fontColor = .cyan
        defenseButton.position = CGPoint(x: self.size.width / 2, y: survivalButton.position.y - 60)
        defenseButton.name = "defenseButton"
        addChild(defenseButton)
        
        let instructionsButton = SKLabelNode(fontNamed: "Menlo-Regular")
        instructionsButton.text = "Instructions"
        instructionsButton.fontSize = 40
        instructionsButton.fontColor = .cyan
        instructionsButton.position = CGPoint(x: self.size.width / 2, y: defenseButton.position.y - 60)
        instructionsButton.name = "instructionsButton"
        addChild(instructionsButton)
        
        // --- ADD THE NEW HIGH SCORES BUTTON ---
        let highScoresButton = SKLabelNode(fontNamed: "Menlo-Regular")
        highScoresButton.text = "High Scores"
        highScoresButton.fontSize = 40
        highScoresButton.fontColor = .cyan
        highScoresButton.position = CGPoint(x: self.size.width / 2, y: instructionsButton.position.y - 60)
        highScoresButton.name = "highScoresButton"
        addChild(highScoresButton)
        
        // Keep a reference to the main buttons to easily hide/show them
        mainMenuButtons = [titleLabel, survivalButton, defenseButton, instructionsButton, highScoresButton]
        // --- Setup the hidden instructions overlay ---
        setupInstructionsOverlay()
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
    
    // --- Instructions Overlay Setup ---
    private func setupInstructionsOverlayOG() {
        instructionsOverlay = SKNode()
        
        // Create a semi-transparent background panel
        let panel = SKSpriteNode(color: .black.withAlphaComponent(0.8), size: self.size)
        panel.position = CGPoint(x: self.size.width / 2, y: self.size.height / 2)
        instructionsOverlay.addChild(panel)
        
        // Create the content
        let title = SKLabelNode(fontNamed: "Menlo-Bold")
        title.text = "How to Play"
        title.fontSize = 48
        title.fontColor = .white
        title.position = CGPoint(x: self.size.width / 2, y: self.size.height * 0.8)
        instructionsOverlay.addChild(title)
        
        let instructionsText = """
        Swipe Up: Pull a boulder from the ground.
        Swipe Left/Right: Launch the whole boulder.
        Tap: Fire a single piece from the boulder.
        
        Summon a boulder under an enemy to launch them!
        Summon a boulder under yourself to jump!
        """
        
        let instructionsLabel = SKLabelNode(fontNamed: "Menlo-Regular")
        instructionsLabel.text = instructionsText
        instructionsLabel.fontSize = 20
        instructionsLabel.fontColor = .white
        instructionsLabel.numberOfLines = 0 // Allow multiple lines
        instructionsLabel.preferredMaxLayoutWidth = self.size.width * 0.8
        instructionsLabel.position = CGPoint(x: self.size.width / 2, y: self.size.height / 3)
        instructionsOverlay.addChild(instructionsLabel)
        
        let backButton = SKLabelNode(fontNamed: "Menlo-Bold")
        backButton.text = "Back"
        backButton.fontSize = 30
        backButton.fontColor = .cyan
        backButton.position = CGPoint(x: self.size.width / 2, y: self.size.height * 0.2)
        backButton.name = "backButton"
        instructionsOverlay.addChild(backButton)
        
        // Add the overlay to the scene, but keep it hidden
        instructionsOverlay.isHidden = true
        addChild(instructionsOverlay)
    }
    
    // --- Touch Handling ---
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        let tappedNode = nodes(at: location).first
        
        // --- THE FIX: Handle the new buttons ---
        if tappedNode?.name == "survivalButton" {
            // Tell the delegate to start a survival game.
            menuDelegate?.mainMenu(self, didSelectMode: .survival)
        } else if tappedNode?.name == "defenseButton" {
            // Tell the delegate to start a defense game.
            menuDelegate?.mainMenu(self, didSelectMode: .defense)
        } else if tappedNode?.name == "instructionsButton" {
            showInstructions()
        } else if tappedNode?.name == "backButton" {
            hideInstructions()
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
