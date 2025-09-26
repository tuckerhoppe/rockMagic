//
//  PauseMenuNode.swift
//  RockMagic
//
//  Created by Tucker Hoppe on 7/22/25.
//

import Foundation
import SpriteKit

class PauseMenuNode: SKNode {

    // --- Properties ---
    private var instructionsOverlay: SKNode!
    private var viewUpgradesOverlay: ViewUpgradesNode!
    private var menuButtons: [SKNode] = []

    

    init(size: CGSize) {
        super.init()
        let titlePos:CGFloat = 100
        let resumePos:CGFloat = titlePos - 60
        let restartPos:CGFloat = resumePos - 60
        let instructionsPos:CGFloat = restartPos - 60
        let exitPos:CGFloat = instructionsPos - 60
    
        // Center the background panel on the node's origin
        let background = SKSpriteNode(color: .black.withAlphaComponent(0.7), size: size)
        background.position = .zero
        addChild(background)
        
        // --- Position all buttons relative to the screen's center (0,0) ---
        
        let titleLabel = SKLabelNode(fontNamed: GameManager.shared.fontName)
        titleLabel.text = "Paused"
        titleLabel.fontSize = 60
        titleLabel.fontColor = .white
        titleLabel.position = CGPoint(x: 0, y: titlePos) // High on the screen
        addChild(titleLabel)
        
        let resumeButton = SKLabelNode(fontNamed: GameManager.shared.fontName)
        resumeButton.text = "Resume"
        resumeButton.fontSize = 40
        resumeButton.fontColor = .cyan
        resumeButton.position = CGPoint(x: 0, y: resumePos) // Below the title
        resumeButton.name = "resumeButton"
        addChild(resumeButton)
        
        // --- ADD a "View Upgrades" button ---
        let viewUpgradesButton = SKLabelNode(fontNamed: GameManager.shared.fontName)
        viewUpgradesButton.text = "View Upgrades"
        viewUpgradesButton.position = CGPoint(x: 0, y: instructionsPos)
        viewUpgradesButton.name = "viewUpgradesButton"
        //addChild(viewUpgradesButton)
        
        let restartButton = SKLabelNode(fontNamed: GameManager.shared.fontName)
        restartButton.text = "Restart"
        restartButton.fontSize = 40
        restartButton.fontColor = .cyan
        restartButton.position = CGPoint(x: 0, y: restartPos) // Below resume
        restartButton.name = "restartButton"
        addChild(restartButton)
        
        let instructionsButton = SKLabelNode(fontNamed: GameManager.shared.fontName)
        instructionsButton.text = "Instructions"
        instructionsButton.fontSize = 40
        instructionsButton.fontColor = .cyan
        instructionsButton.position = CGPoint(x: 0, y: instructionsPos) // Below restart
        instructionsButton.name = "instructionsButton"
        addChild(instructionsButton)
        
        let exitButton = SKLabelNode(fontNamed: GameManager.shared.fontName)
        exitButton.text = "Exit to Menu"
        exitButton.fontSize = 40
        exitButton.fontColor = .cyan
        exitButton.position = CGPoint(x: 0, y: exitPos) // Below instructions
        exitButton.name = "exitButton"
        addChild(exitButton)
        
        menuButtons = [titleLabel, resumeButton, restartButton, instructionsButton,viewUpgradesButton, exitButton]
        
        setupInstructionsOverlay(size: size)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // In PauseMenuNode.swift

    // In PauseMenuNode.swifta

    private func setupInstructionsOverlay(size: CGSize) {
        instructionsOverlay = SKNode()
        
        let panel = SKSpriteNode(color: .black.withAlphaComponent(0.9), size: size)
        panel.position = .zero
        instructionsOverlay.addChild(panel)
        
        let title = SKLabelNode(fontNamed: GameManager.shared.fontName)
        title.text = "How to Play"
        title.fontSize = 48
        title.fontColor = .white
        title.position = CGPoint(x: 0, y: size.height * 0.1)
        instructionsOverlay.addChild(title)
        
        // --- THE FIX: Create and add the image gallery ---
        let instructionImages = GameManager.shared.instructionImages
        let gallerySize = CGSize(width: 500, height: 350)
        let gallery = ImageGalleryNode(size: gallerySize, imageNames: instructionImages)
        gallery.position = .zero // Centered
        instructionsOverlay.addChild(gallery)
        
        let backButton = SKLabelNode(fontNamed: GameManager.shared.fontName)
        backButton.text = "Back"
        backButton.fontSize = 30
        backButton.fontColor = .cyan
        backButton.position = CGPoint(x: 0, y: -size.height * 0.1)
        backButton.name = "backButton"
        instructionsOverlay.addChild(backButton)
        
        instructionsOverlay.isHidden = true
        self.viewUpgradesOverlay = ViewUpgradesNode(size: size)
        self.viewUpgradesOverlay.isHidden = true
        addChild(instructionsOverlay)
    }
    
    // In PauseMenuNode.swift

    private func setupInstructionsOverlayOG(size: CGSize) {
        instructionsOverlay = SKNode()
        
        // 1. Center the background panel on the overlay's origin.
        let panel = SKSpriteNode(color: .black.withAlphaComponent(0.9), size: size)
        panel.position = .zero
        instructionsOverlay.addChild(panel)
        
        // 2. Position all content relative to the screen's center (0,0).
        let title = SKLabelNode(fontNamed: GameManager.shared.fontName)
        title.text = "How to Play"
        title.fontSize = 48
        title.fontColor = .white
        title.position = CGPoint(x: 0, y: size.height * 0.35) // High on the screen
        instructionsOverlay.addChild(title)
        
        let instructionsText = """
        Swipe Up: Pull a boulder from the ground.
        Swipe Left/Right: Launch the whole boulder.
        Tap: Fire a single piece from the boulder.
        
        Summon a boulder under an enemy to launch them!
        Summon a boulder under yourself to jump!
        """
        
        let instructionsLabel = SKLabelNode(fontNamed: GameManager.shared.fontName)
        instructionsLabel.text = instructionsText
        instructionsLabel.fontSize = 20
        instructionsLabel.fontColor = .white
        instructionsLabel.numberOfLines = 0
        instructionsLabel.preferredMaxLayoutWidth = size.width * 0.8
        instructionsLabel.verticalAlignmentMode = .center
        instructionsLabel.position = CGPoint(x: 0, y: 0) // Centered
        instructionsOverlay.addChild(instructionsLabel)
        
        
        
        let backButton = SKLabelNode(fontNamed: GameManager.shared.fontName)
        backButton.text = "Back"
        backButton.fontSize = 30
        backButton.fontColor = .cyan
        backButton.position = CGPoint(x: 0, y: -size.height * 0.1) // Low on the screen
        backButton.name = "backButton"
        instructionsOverlay.addChild(backButton)
        
        // --- Setup the new overlay ---
        viewUpgradesOverlay = ViewUpgradesNode(size: size)
        viewUpgradesOverlay.isHidden = true
        addChild(viewUpgradesOverlay)
        
        // Add the overlay, but keep it hidden.
        instructionsOverlay.isHidden = true
        addChild(instructionsOverlay)
    }
    
    func showInstructions() {
        instructionsOverlay.isHidden = false
        menuButtons.forEach { $0.isHidden = true }
    }
    
    func hideInstructions() {
        instructionsOverlay.isHidden = true
        menuButtons.forEach { $0.isHidden = false }
    }
    
    // --- ADD these two new functions ---
    func showUpgrades() {
        viewUpgradesOverlay.isHidden = false
        menuButtons.forEach { $0.isHidden = true }
    }
    
    func hideUpgrades() {
        viewUpgradesOverlay.isHidden = true
        menuButtons.forEach { $0.isHidden = false }
    }
}
