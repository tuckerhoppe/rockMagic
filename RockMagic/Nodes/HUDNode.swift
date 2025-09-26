//
//  HUDNode.swift
//  RockMagic
//
//  Created by Tucker Hoppe on 7/22/25.
//

import Foundation
import SpriteKit

class HUDNode: SKNode {
    // --- Add properties for the stamina bar ---
    private var staminaBarBackground: SKShapeNode!
    private var staminaBar: SKShapeNode!
    private let staminaBarWidth: CGFloat = 150
    private let staminaBarHeight: CGFloat = 15

    // --- Properties ---
    private var healthBarBackground: SKShapeNode!
    private var healthBar: SKShapeNode!
    private let healthBarWidth: CGFloat = 200
    private let healthBarHeight: CGFloat = 20
    
    private var scoreLabel: SKLabelNode!
    private var goldenBoulderButton: SKSpriteNode!
    
    // --- ADD these new properties ---
    private var levelLabel: SKLabelNode!
    private var levelProgressBar: SKShapeNode!
    private let levelBarWidth: CGFloat = 150
    
    private var topHudY: CGFloat = 0
    
    // --- Initializer ---
    init(sceneSize: CGSize) {
        super.init()
        topHudY = sceneSize.height / 2.7
        setupHealthBar(size: sceneSize)
        setupScoreLabel(size: sceneSize)
        setupPauseButton(size: sceneSize)
        setupStaminaBar(size: sceneSize)
        setupGoldenBoulderButton(size: sceneSize)
        setupLevelUI(size: sceneSize)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // Call this function AFTER the HUD has been added to the camera.
    func setup(size: CGSize) {
        
        setupHealthBar(size: size)
        setupScoreLabel(size: size)
        
        // --- ADD THIS CALL ---
        setupPauseButton(size: size)
    }
    
    private func setupLevelUI(size: CGSize) {
        levelLabel = SKLabelNode(fontNamed: GameManager.shared.fontName)
        levelLabel.text = "Level: 1"
        levelLabel.fontSize = 20
        levelLabel.fontColor = .white
        levelLabel.position = CGPoint(x: 0, y: topHudY)
        addChild(levelLabel)

        let progressBarBG = SKShapeNode(rectOf: CGSize(width: levelBarWidth, height: 15), cornerRadius: 4)
        progressBarBG.fillColor = .darkGray
        progressBarBG.position = CGPoint(x: 0, y: levelLabel.position.y - 10)
        addChild(progressBarBG)

        // Create the initial progress bar, but we will redraw it later.
        levelProgressBar = SKShapeNode()
        levelProgressBar.fillColor = .cyan
        levelProgressBar.strokeColor = .clear
        // Position it at the left edge of the background bar.
        levelProgressBar.position = CGPoint(x: -levelBarWidth / 2, y: 0)
        progressBarBG.addChild(levelProgressBar)
    }
    
    // --- ADD this new function ---
    private func setupStaminaBar(size: CGSize) {
        let container = SKNode()
        
        staminaBarBackground = SKShapeNode(rectOf: CGSize(width: staminaBarWidth, height: staminaBarHeight), cornerRadius: 4)
        staminaBarBackground.fillColor = .darkGray
        staminaBarBackground.strokeColor = .black
        staminaBarBackground.lineWidth = 2
        staminaBarBackground.position = .zero
        //container.addChild(staminaBarBackground)

        staminaBar = SKShapeNode(rectOf: CGSize(width: staminaBarWidth, height: staminaBarHeight), cornerRadius: 4)
        staminaBar.fillColor = .yellow // Stamina is often yellow
        staminaBar.strokeColor = .clear
        staminaBar.position = .zero
        staminaBar.zPosition = 1
        //staminaBarBackground.addChild(staminaBar)
        
        // Position it below the health bar
        let containerX = -size.width / 2.4 + 75 // Align with health bar
        let containerY = topHudY - 25   // 25 points below health bar
        container.position = CGPoint(x: containerX, y: containerY)
        //addChild(container)
    }

    // This function's signature changes from Int to CGFloat
    func updateStaminaBar(currentStamina: CGFloat, maxStamina: CGFloat) {
        let staminaPercentage = currentStamina / maxStamina
        
        let scaleAction = SKAction.scaleX(to: staminaPercentage, duration: 0.1)
        let newXPosition = -((staminaBarWidth * (1 - staminaPercentage)) / 2)
        let moveAction = SKAction.moveTo(x: newXPosition, duration: 0.1)
        
        staminaBar.run(SKAction.group([scaleAction, moveAction]))
    }
    
    // --- ADD THIS NEW FUNCTION ---
    private func setupGoldenBoulderButton(size: CGSize) {
        // Replace "Golden_Boulder_Icon" with your asset name
        goldenBoulderButton = SKSpriteNode(imageNamed: "greenGem")
        goldenBoulderButton.name = "goldenBoulderButton"
        goldenBoulderButton.setScale(0.03) // Adjust size as needed

        // Position it to the right of the stamina bar
        let xPos = -size.width / 2.4 + 250
        let yPos = topHudY - 25
        goldenBoulderButton.position = CGPoint(x: xPos, y: yPos)
        //addChild(goldenBoulderButton)

        // Start the button in a disabled state
        updateGoldenBoulderButton(currentStamina: 0, maxStamina: 100)
    }

    // --- ADD THIS NEW FUNCTION ---
    /// Updates the button's appearance based on stamina level.
    func updateGoldenBoulderButton(currentStamina: CGFloat, maxStamina: CGFloat) {
        if currentStamina >= maxStamina {
            // If stamina is full, make the button fully visible and tappable.
            goldenBoulderButton.alpha = 1.0
        } else {
            // If stamina is not full, make it grayed out.
            goldenBoulderButton.alpha = 0.3
        }
    }

    // --- Health Bar ---
    private func setupHealthBar(size: CGSize) {
        let container = SKNode()
        
        let label = SKLabelNode(fontNamed: GameManager.shared.fontName)
        label.text = "❤️"
        label.fontSize = 20
        label.fontColor = .white
        label.horizontalAlignmentMode = .left
        label.verticalAlignmentMode = .center
        label.position = .zero
        container.addChild(label)
        
        healthBarBackground = SKShapeNode(rectOf: CGSize(width: healthBarWidth, height: healthBarHeight), cornerRadius: 5)
        healthBarBackground.fillColor = .darkGray
        healthBarBackground.strokeColor = .black
        healthBarBackground.lineWidth = 2
        let labelWidth = label.calculateAccumulatedFrame().width
        healthBarBackground.position = CGPoint(x: labelWidth + 10 + healthBarWidth/2, y: 0)
        container.addChild(healthBarBackground)

        healthBar = SKShapeNode(rectOf: CGSize(width: healthBarWidth, height: healthBarHeight), cornerRadius: 5)
        healthBar.fillColor = .green
        healthBar.strokeColor = .clear
        healthBar.position = .zero
        healthBar.zPosition = 1
        healthBarBackground.addChild(healthBar)
        
        let containerX = -size.width / 2.4
        let containerY = topHudY
        container.position = CGPoint(x: containerX, y: containerY)
        addChild(container)
    }
    
    func updateHealthBar(currentHealth: CGFloat, maxHealth: CGFloat) {
        let healthPercentage = currentHealth / maxHealth
        
        let scaleAction = SKAction.scaleX(to: healthPercentage, duration: 0.2)
        let newXPosition = -((healthBarWidth * (1 - healthPercentage)) / 2)
        let moveAction = SKAction.moveTo(x: newXPosition, duration: 0.2)
        
        healthBar.run(SKAction.group([scaleAction, moveAction]))
    }
    
    // ------
    private func setupScoreLabel(size: CGSize) {
        scoreLabel = SKLabelNode(fontNamed: GameManager.shared.fontName)
        scoreLabel.text = "Score: 0"
        scoreLabel.fontSize = 20
        scoreLabel.fontColor = .white
        
        
        let xPos = size.width / 3.5  // 20 points padding from the right
        let yPos = topHudY// Aligned with the health bar
        
        print("x, y: ", xPos, yPos)
        scoreLabel.position = CGPoint(x: xPos, y: yPos)
        scoreLabel.horizontalAlignmentMode = .right
        addChild(scoreLabel)
    }
    
    func updateScore(newScore: Int) {
        scoreLabel.text = "Score: \(newScore)"
    }
    
    // --- REPLACE this function with the new redraw logic ---
    func updateLevelProgress(currentScore: Int, scoreForNextLevel: Int, previousLevelScore: Int) {
        let scoreInLevel = CGFloat(currentScore - previousLevelScore)
        let scoreNeeded = CGFloat(scoreForNextLevel - previousLevelScore)
        let percentage = scoreInLevel / scoreNeeded
        
        // Calculate the new width of the bar.
        let newWidth = levelBarWidth * percentage
        
        // Redraw the bar with the new width. This is more reliable than scaling.
        levelProgressBar.path = CGPath(
            roundedRect: CGRect(x: 0, y: -7.5, width: newWidth, height: 15),
            cornerWidth: 4,
            cornerHeight: 4,
            transform: nil
        )
    }

    
    // --- ADD this new update function ---
    func updateLevelLabel(level: Int) {
        levelLabel.text = "Level: \(level)"
    }

    // --- ADD this new function ---
    func showLevelUpMessage() {
        let levelUpLabel = SKLabelNode(fontNamed: GameManager.shared.fontName)
        levelUpLabel.text = "Level Up!"
        levelUpLabel.fontSize = 60
        levelUpLabel.fontColor = .yellow
        levelUpLabel.position = .zero
        levelUpLabel.zPosition = ZPositions.hud + 10
        
        let scaleUp = SKAction.scale(to: 1.2, duration: 0.2)
        let wait = SKAction.wait(forDuration: 1.0)
        let fadeOut = SKAction.fadeOut(withDuration: 0.5)
        let remove = SKAction.removeFromParent()
        
        levelUpLabel.run(SKAction.sequence([scaleUp, wait, fadeOut, remove]))
        addChild(levelUpLabel)
    }

    
    private func setupPauseButton(size: CGSize) {
        let pauseButton = SKLabelNode(fontNamed: GameManager.shared.fontName)
        pauseButton.text = "||" // Standard pause icon
        pauseButton.fontSize = 30
        pauseButton.fontColor = .black
        
        // Position in the center-top of the screen
        let xPos = size.width / 3
        let yPos = size.height / 3
        pauseButton.position = CGPoint(x: xPos, y: yPos)
        pauseButton.name = "pauseButton"
        addChild(pauseButton)
    }
}
