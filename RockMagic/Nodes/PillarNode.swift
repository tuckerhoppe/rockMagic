//
//  PillarNode.swift
//  RockMagic
//
//  Created by Tucker Hoppe on 8/25/25.
//

import Foundation
import SpriteKit

class PillarNode: SKNode, Damageable {
    
    let startY: CGFloat = -150 // The initial Y position
    let maxHeight: CGFloat = -50
    let maxHealth: Int = 100
    let riseRate: CGFloat = 0.3
    let healthRise: Int = 1
    var currentHealth: Int = 0
    var pullingUp: Bool = true
    
    var rectangle: SKSpriteNode!
    
    // --- ADD these new properties for the health bar ---
    private var healthBarBackground: SKShapeNode!
    private var healthBar: SKShapeNode!
    private let healthBarWidth: CGFloat = 40
    private let healthBarHeight: CGFloat = 8
    
    override init(){
        super.init()
        
        
        //sets up actual shape
        let size: CGSize = CGSize(width: 40, height: 100)
        rectangle = SKSpriteNode(color: .brown, size: size )
        self.position.y = -150
        
        addChild(rectangle)
        
        
        // Sets up physics
        // --- Setup the physics body ---
        self.physicsBody = SKPhysicsBody(rectangleOf: size)
        
        // 1. Make it immovable
        self.physicsBody?.isDynamic = false
        self.physicsBody?.friction = 0.0 // Was 0.5
        self.physicsBody?.categoryBitMask = PhysicsCategory.pillar
        // Tell it to collide with the player and enemies, but NOT boulders.
        self.physicsBody?.collisionBitMask = PhysicsCategory.player | PhysicsCategory.enemy
        
        // --- ADD THIS LINE to turn on the "alarm system" ---
        self.physicsBody?.contactTestBitMask = PhysicsCategory.enemy
        
        //addDebugPositionMarker()
        setupHealthBar()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func moveUp(){
        
        if self.position.y < maxHeight{
            self.position.y += riseRate
        
            // 1. Calculate the total distance the pillar will rise.
            let totalRiseDistance = maxHeight - startY
            
            // 2. Calculate how far it has risen so far.
            let currentRiseDistance = self.position.y - startY
            
            // 3. Find the percentage of the rise that is complete.
            let progressPercentage = currentRiseDistance / totalRiseDistance
            
            // 4. Set the health to be that exact percentage of the max health.
            self.currentHealth = Int(CGFloat(maxHealth) * progressPercentage)
            
            // --- ADD THIS CALL to update the visual bar ---
                        updateHealthBar()
        } else{
            self.currentHealth = maxHealth
            // --- ADD THIS CALL to update the visual bar ---
                        updateHealthBar()
        }
    }
    
    /// This function is called every frame by the MagicManager.
    func update() {
        // If the pillar has somehow moved below the ground, destroy it.
        // This is a simple cleanup to prevent orphaned nodes.
        if !pullingUp {
            // If the pillar has somehow moved below the ground after being placed, destroy it.
            if self.position.y < GameManager.shared.groundY {
                destroy(discrete: true)
            }
        }
    }
    
    func takeDamage(amount: Int) {
        currentHealth -= amount
        if currentHealth < 0 {
            currentHealth = 0
        }
        
        // --- ADD THIS CALL to update the visual bar ---
        updateHealthBar()
        
        // --- THE FIX: Save the original color first ---
            let originalColor = rectangle.color
            
            // 1. Define the actions for the flash effect.
            let redFlash = SKAction.colorize(with: .red, colorBlendFactor: 1.0, duration: 0.1)
            
            // 2. Create an action that restores the original color.
            let restoreColor = SKAction.colorize(with: originalColor, colorBlendFactor: 1.0, duration: 0.1)
            
            // 3. Create a sequence to flash red and then go back to brown.
            let flashSequence = SKAction.sequence([redFlash, restoreColor])

            // 4. Run the sequence on the rectangle.
            rectangle.run(flashSequence)
        
        //print("Player health: \(currentHealth)/\(maxHealth)")
        
        // Tell the scene that damage was taken so it can update the HUD
        (scene as? GameScene)?.playerTookDamage()

        if currentHealth <= 0 {
            destroy()
        }
    }
    
    private func addDebugPositionMarker() {
        // Create a very tall line that will span the screen
        let line = SKShapeNode(rectOf: CGSize(width: 2, height: 2000))
        line.fillColor = .magenta
        line.strokeColor = .clear
        line.zPosition = ZPositions.hud // Ensure it's on top of everything
        addChild(line)
    }
    
    // --- ADD THIS NEW FUNCTION to create the health bar ---
        private func setupHealthBar() {
            healthBarBackground = SKShapeNode(rectOf: CGSize(width: healthBarWidth, height: healthBarHeight), cornerRadius: 2)
            healthBarBackground.fillColor = .darkGray
            healthBarBackground.strokeColor = .clear
            // Position it just above the main rectangle
            healthBarBackground.position = CGPoint(x: 0, y: (rectangle.size.height / 2) + 15)
            addChild(healthBarBackground)
            
            healthBar = SKShapeNode()
            healthBar.fillColor = .green
            healthBar.strokeColor = .clear
            healthBar.position = CGPoint(x: -healthBarWidth / 2, y: 0)
            healthBarBackground.addChild(healthBar)
        }
        
        // --- ADD THIS NEW FUNCTION to update the health bar's width ---
        private func updateHealthBar() {
            let healthPercentage = CGFloat(currentHealth) / CGFloat(maxHealth)
            
            // Redraw the bar with the new width.
            let newWidth = healthBarWidth * healthPercentage
            healthBar.path = CGPath(
                roundedRect: CGRect(x: 0, y: -healthBarHeight / 2, width: newWidth, height: healthBarHeight),
                cornerWidth: 2,
                cornerHeight: 2,
                transform: nil
            )
        }
    
    /// Plays an explosion affect, removes the phyiscs body, and removes it from parent
    func destroy(discrete: Bool = false) {
        if !discrete {
            EffectManager.shared.playPillarDestroyedEffect(at: self.position)
        }
        
        self.physicsBody = nil
        self.removeFromParent()
    }
}
