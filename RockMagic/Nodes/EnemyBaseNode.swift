//
//  EnemyBaseNode.swift
//  RockMagic
//
//  Created by Tucker Hoppe on 9/3/25.
//


import SpriteKit

class EnemyBaseNode: SKSpriteNode, Damageable {
    
    
    // --- Damageable Protocol Requirements ---
    var currentHealth: Int = 800
    let maxHealth: Int = 800
    
    // --- ADD these new properties for the health bar ---
    private var healthBarBackground: SKShapeNode!
    private var healthBar: SKShapeNode!
    private let healthBarWidth: CGFloat = 150
    private let healthBarHeight: CGFloat = 15
    var isInvulnerable: Bool = false
    
    var rebuildMe: Bool
    var destroyed: Bool = false
    
    var normal: Int
    var littleRat: Int
    var bigBoy: Int
    var blocker: Int
    

    init(normal: Int, littleRat: Int, bigBoy: Int, blocker: Int, rebuildMe: Bool = true, position: CGPoint) {
        // Replace "Boulder_Hut_Texture" with your asset name
        let texture = SKTexture(imageNamed: "woodenTower")
        
        self.normal = normal
        self.littleRat = littleRat
        self.bigBoy = bigBoy
        self.blocker = blocker
        
        self.rebuildMe = rebuildMe

        super.init(texture: texture, color: .clear, size: texture.size())
        
        self.isInvulnerable = false
        
        self.size = CGSize(width: 80, height: 80)
        self.zPosition = ZPositions.building
        
        self.position = position
        
                
        
        setupPhysicsBody()
        setupHealthBar()
    }
    
    private func setupPhysicsBody() {
        self.physicsBody = SKPhysicsBody(rectangleOf: self.size)
        self.physicsBody?.isDynamic = false
        self.physicsBody?.categoryBitMask = PhysicsCategory.destroyableObject
        self.physicsBody?.collisionBitMask = PhysicsCategory.player
        self.physicsBody?.contactTestBitMask = PhysicsCategory.boulder | PhysicsCategory.rockPiece
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
        if isInvulnerable { return }
        
        currentHealth -= amount
        if currentHealth < 0 {
            currentHealth = 0
        }
        
        isInvulnerable = true
        let wait = SKAction.wait(forDuration: 0.025)
        let makeVulnerable = SKAction.run { [weak self] in
            self?.isInvulnerable = false
        }
        run(SKAction.sequence([wait, makeVulnerable]))
        
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
        destroyed = true
        
        if rebuildMe {
            print("rebuild me!")
            rebuild()
        } else{
            // Remove the base from the game
            self.removeFromParent()
        }
        
        
    }
    
    // --- This is the new rebuild function ---
    private func rebuild() {
        // 1. Define the animation frames.
        //    NOTE: Replace these with your actual asset names.
        let rebuildFrames = [SKTexture(imageNamed: "health"),
                             SKTexture(imageNamed: "coin"),
                             SKTexture(imageNamed: "gate")]
        
        // 2. Create the looping animation action.
        let animationAction = SKAction.animate(with: rebuildFrames, timePerFrame: 0.2)
        let loopingAnimation = SKAction.repeatForever(animationAction)
        
        // 3. Create the sequence that will run after 10 seconds.
        let wait = SKAction.wait(forDuration: 10.0)
        
        let finishRebuild = SKAction.run { [weak self] in
            // Stop the animation and set the flag back to false.
            self?.removeAction(forKey: "rebuildingAnimation")
            self?.destroyed = false
            self?.currentHealth = self!.maxHealth
            self?.texture = SKTexture(imageNamed: "woodenTower")
            self?.updateHealthBar()
            print("Enemy Base has finished rebuilding!")
        }
        
        // 4. Run the two actions.
        //    The looping animation runs with a key so we can stop it later.
        self.run(loopingAnimation, withKey: "rebuildingAnimation")
        //    The sequence runs to stop the process after 10 seconds.
        self.run(SKAction.sequence([wait, finishRebuild]))
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
