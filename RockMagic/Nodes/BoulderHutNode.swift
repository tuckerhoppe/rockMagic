//
//  BoulderHutNode.swift
//  RockMagic
//
//  Created by Tucker Hoppe on 8/30/25.
//

import SpriteKit

class BoulderHutNode: SKSpriteNode, Defendable {
    
    // --- Damageable Protocol Requirements ---
    var currentHealth: Int = 300
    let maxHealth: Int = 300
    
    // --- ADD these new properties for the health bar ---
    private var healthBarBackground: SKShapeNode!
    private var healthBar: SKShapeNode!
    private let healthBarWidth: CGFloat = 150
    private let healthBarHeight: CGFloat = 15

    init() {
        // Replace "Boulder_Hut_Texture" with your asset name
        let texture = SKTexture(imageNamed: "greenGeode")
        super.init(texture: texture, color: .clear, size: texture.size())
        
        self.size = CGSize(width: 100, height: 100)
        self.zPosition = ZPositions.boulderHut
        
        setupPhysicsBody()
        setupHealthBar()
    }
    
    private func setupPhysicsBody() {
        self.physicsBody = SKPhysicsBody(rectangleOf: self.size)
        self.physicsBody?.isDynamic = false
        self.physicsBody?.categoryBitMask = PhysicsCategory.defendableObject
        self.physicsBody?.collisionBitMask = PhysicsCategory.none
        self.physicsBody?.contactTestBitMask = PhysicsCategory.enemy
    }
    
    // --- ADD THIS NEW FUNCTION to create the health bar ---
    private func setupHealthBar() {
        healthBarBackground = SKShapeNode(rectOf: CGSize(width: healthBarWidth, height: healthBarHeight), cornerRadius: 4)
        healthBarBackground.fillColor = .darkGray
        healthBarBackground.strokeColor = .clear
        // Position it above the hut
        healthBarBackground.position = CGPoint(x: 0, y: (self.size.height / 2) + 25)
        addChild(healthBarBackground)
        
        healthBar = SKShapeNode()
        healthBar.fillColor = .green
        healthBar.strokeColor = .clear
        healthBar.position = CGPoint(x: -healthBarWidth / 2, y: 0)
        healthBarBackground.addChild(healthBar)
        
        // Update the bar to its initial full state
        updateHealthBar()
    }
    
    // --- ADD THIS NEW FUNCTION to update the health bar's width ---
    private func updateHealthBar() {
        let healthPercentage = CGFloat(currentHealth) / CGFloat(maxHealth)
        
        let newWidth = healthBarWidth * healthPercentage
        healthBar.path = CGPath(
            roundedRect: CGRect(x: 0, y: -healthBarHeight / 2, width: newWidth, height: healthBarHeight),
            cornerWidth: 4,
            cornerHeight: 4,
            transform: nil
        )
    }
    
    func takeDamage(amount: Int) {
        currentHealth -= amount
        if currentHealth < 0 {
            currentHealth = 0
        }
        
        // Update the visual health bar
        updateHealthBar()
        
        // Add a red flash effect for visual feedback
        let originalColor = self.color
        let redFlash = SKAction.colorize(with: .red, colorBlendFactor: 0.8, duration: 0.1)
        let restoreColor = SKAction.colorize(with: originalColor, colorBlendFactor: 0.0, duration: 0.1)
        self.run(SKAction.sequence([redFlash, restoreColor]))
        
        
        if currentHealth <= 0 {
            // Tell the GameScene the game is over
            destroy()
        }
    }
    
    /// Handles the destruction of the hut.
    private func destroy() {
        print("The Boulder Hut has been destroyed! GAME OVER.")
        // Play an explosion effect
        EffectManager.shared.playPillarDestroyedEffect(at: self.position)
        
        // Tell the GameScene to show the game over menu
        if let gameScene = self.scene as? GameScene {
            gameScene.showGameOverMenu(message: "Boulder Hut DEAD!")
        }
        
        // Remove the hut from the game
        self.removeFromParent()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
