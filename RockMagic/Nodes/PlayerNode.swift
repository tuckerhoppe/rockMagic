//
//  PlayerNode.swift
//  RockMagic
//
//  Created by Tucker Hoppe on 4/28/25.
//

import Foundation
import SpriteKit


/// Represents the player-controlled character in the game.
///
/// This class encapsulates all logic and properties related to the player,
/// including movement state, health, animations, and physics. It responds to
/// user input (forwarded from `GameScene`) and interacts with the game world
/// through its physics body and combat functions.
class PlayerNode: SKSpriteNode {
    
    // MARK: - State & Movement
    var isFacingRight: Bool = true
    var isWalking = false
    let moveSpeed: CGFloat = GameManager.shared.playerMoveSpeed

    // MARK: - Health & Combat
    var maxHealth: Int = GameManager.shared.playerMaxHealth
    var currentHealth: Int = 100
    private var isInvulnerable = false

    // MARK: - Animation
    private var animationManager: AnimationManager!
    private var currentAnimation: AnimationType?
    var isBusy: Bool = false // Note: This might be obsolete depending on the animation fix we choose.

    // MARK: - Positioning
    /// The player's calculated position within the scrolling world.
    var worldPosition: CGPoint = .zero

    // Initializer
    init() {
        
        let texture = SKTexture(imageNamed: "R1") 
        
        // Call the designated initializer of SKSpriteNode
        super.init(texture: texture, color: .clear, size: texture.size())
        
        // Set initial properties
        self.name = "player" // Useful for identifying in collisions etc.
        self.zPosition = Constants.ZPositions.player
        
        // Create the animation manager
        self.animationManager = AnimationManager()
        
        // Setup physics body
        setupPhysicsBody()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func playAnimation(_ type: AnimationType) {
        // If the requested looping animation is already playing, do nothing.
        if type == .walk || type == .idle {
            if type == currentAnimation { return }
        }
        
        currentAnimation = type
        animationManager.play(animationType: type, on: self)
    }

    // --- Movement and State ---
    func updateFacingDirection(joystickVelocity: CGVector) {
        if joystickVelocity.dx > 0 {
            isFacingRight = true
            self.xScale = abs(self.xScale) * 1
        } else if joystickVelocity.dx < 0 {
            isFacingRight = false
            self.xScale = abs(self.xScale) * -1
        }
    }
    
    func launch(with impulse: CGVector) {
        self.playAnimation(.jump) // Play the jump animation
        physicsBody?.applyImpulse(impulse)
    }
    


    func setupPhysicsBody() {
        self.physicsBody = SKPhysicsBody(rectangleOf: self.size)
        self.physicsBody?.affectedByGravity = true
        self.physicsBody?.allowsRotation = false
        self.physicsBody?.restitution = 0.0
        self.physicsBody?.friction = GameManager.shared.playerFriction
        self.physicsBody?.categoryBitMask = PhysicsCategory.player

        // Player
        physicsBody?.collisionBitMask = PhysicsCategory.ground | PhysicsCategory.wall | PhysicsCategory.edge
        physicsBody?.contactTestBitMask = PhysicsCategory.enemy | PhysicsCategory.pickup
        
    }
    
    // --- ADD TAKE DAMAGE FUNCTION ---
    func takeDamage(amount: Int) {
        if isInvulnerable { return }

        currentHealth -= amount
        if currentHealth < 0 {
            currentHealth = 0
        }
        
        //print("Player health: \(currentHealth)/\(maxHealth)")
        
        // Tell the scene that damage was taken so it can update the HUD
        (scene as? GameScene)?.playerTookDamage()

        if currentHealth <= 0 {
            die()
        }
    }
    
    // --- ADD DEATH FUNCTION ---
    private func die() {
        print("GAME OVER")
        
        // Tell the GameScene to handle the game over sequence
        if let gameScene = self.scene as? GameScene {
            gameScene.showGameOverMenu()
        }
        
        // Hide the player node
        self.isHidden = true
        self.physicsBody?.isDynamic = false // Stop physics interactions
    }
}
