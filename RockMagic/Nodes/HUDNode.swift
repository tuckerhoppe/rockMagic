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
    
    // --- Initializer ---
    init(sceneSize: CGSize) {
        super.init()
        
        setupHealthBar(size: sceneSize)
        setupScoreLabel(size: sceneSize)
        setupPauseButton(size: sceneSize)
        setupStaminaBar(size: sceneSize)
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
    
    // --- ADD this new function ---
    private func setupStaminaBar(size: CGSize) {
        let container = SKNode()
        
        staminaBarBackground = SKShapeNode(rectOf: CGSize(width: staminaBarWidth, height: staminaBarHeight), cornerRadius: 4)
        staminaBarBackground.fillColor = .darkGray
        staminaBarBackground.strokeColor = .black
        staminaBarBackground.lineWidth = 2
        staminaBarBackground.position = .zero
        container.addChild(staminaBarBackground)

        staminaBar = SKShapeNode(rectOf: CGSize(width: staminaBarWidth, height: staminaBarHeight), cornerRadius: 4)
        staminaBar.fillColor = .yellow // Stamina is often yellow
        staminaBar.strokeColor = .clear
        staminaBar.position = .zero
        staminaBar.zPosition = 1
        staminaBarBackground.addChild(staminaBar)
        
        // Position it below the health bar
        let containerX = -size.width / 2.4 + 75 // Align with health bar
        let containerY = size.height / 3 - 25   // 25 points below health bar
        container.position = CGPoint(x: containerX, y: containerY)
        addChild(container)
    }

    // This function's signature changes from Int to CGFloat
    func updateStaminaBar(currentStamina: CGFloat, maxStamina: CGFloat) {
        let staminaPercentage = currentStamina / maxStamina
        
        let scaleAction = SKAction.scaleX(to: staminaPercentage, duration: 0.1)
        let newXPosition = -((staminaBarWidth * (1 - staminaPercentage)) / 2)
        let moveAction = SKAction.moveTo(x: newXPosition, duration: 0.1)
        
        staminaBar.run(SKAction.group([scaleAction, moveAction]))
    }

    // --- Health Bar ---
    private func setupHealthBar(size: CGSize) {
        let container = SKNode()
        
        let label = SKLabelNode(fontNamed: "Menlo-Bold")
        label.text = "Health"
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
        let containerY = size.height / 3
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
    
    // --- Score ---
    private func setupScoreLabel(size: CGSize) {
        scoreLabel = SKLabelNode(fontNamed: "Menlo-Bold")
        scoreLabel.text = "Score: 0"
        scoreLabel.fontSize = 20
        scoreLabel.fontColor = .white
        
        
        let xPos = size.width / 6  // 20 points padding from the right
        let yPos = size.height / 3// Aligned with the health bar
        
        print("x, y: ", xPos, yPos)
        scoreLabel.position = CGPoint(x: xPos, y: yPos)
        scoreLabel.horizontalAlignmentMode = .right
        addChild(scoreLabel)
    }
    
    func updateScore(newScore: Int) {
        scoreLabel.text = "Score: \(newScore)"
    }
    
    private func setupPauseButton(size: CGSize) {
        let pauseButton = SKLabelNode(fontNamed: "Menlo-Bold")
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
