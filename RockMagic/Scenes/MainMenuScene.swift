//
//  MainMenuScene.swift
//  RockMagic
//
//  Created by Tucker Hoppe on 7/22/25.
//

import Foundation
import SpriteKit

class MainMenuScene: SKScene {

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
        
        let startButton = SKLabelNode(fontNamed: "Menlo-Regular")
        startButton.text = "Start Game"
        startButton.fontSize = 40
        startButton.fontColor = .cyan
        startButton.position = CGPoint(x: self.size.width / 2, y: self.size.height * 0.5)
        startButton.name = "startButton"
        addChild(startButton)
        
        let instructionsButton = SKLabelNode(fontNamed: "Menlo-Regular")
        instructionsButton.text = "Instructions"
        instructionsButton.fontSize = 40
        instructionsButton.fontColor = .cyan
        instructionsButton.position = CGPoint(x: self.size.width / 2, y: startButton.position.y - 60)
        instructionsButton.name = "instructionsButton"
        addChild(instructionsButton)
        
        // Keep a reference to the main buttons to easily hide/show them
        mainMenuButtons = [titleLabel, startButton, instructionsButton]
        
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
        
        if tappedNode?.name == "startButton" {
            startGame()
        } else if tappedNode?.name == "instructionsButton" {
            showInstructions()
        } else if tappedNode?.name == "backButton" {
            hideInstructions()
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
    
    private func startGame() {
        guard let gameScene = GameScene(fileNamed: "GameScene") else { return }
        gameScene.scaleMode = .aspectFill
        let transition = SKTransition.fade(withDuration: 1.0)
        self.view?.presentScene(gameScene, transition: transition)
    }
}
