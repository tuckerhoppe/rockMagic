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
    // --- ADD THIS NEW STATE PROPERTY ---
    var isGrounded = true
    var isWalking = false
    var moveSpeed: CGFloat = GameManager.shared.playerMoveSpeed

    // MARK: - Health & Combat
    var maxHealth: Int = GameManager.shared.playerMaxHealth
    var currentHealth: Int = 100
    private var isInvulnerable = false
    
    // --- CHANGE these properties from Int to CGFloat ---
    var maxStamina: CGFloat = CGFloat(GameManager.shared.playerMaxStamina)
    var currentStamina: CGFloat =  0 //CGFloat(GameManager.shared.playerMaxStamina)

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
        self.zPosition = ZPositions.player
        
        // Create the animation manager
        self.animationManager = AnimationManager()
        
        // Setup physics body
        setupPhysicsBody()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // --- ADD this new function ---
    /// Attempts to use stamina. Returns true if successful, false otherwise.
    func useStamina(cost: Int) -> Bool {
        if currentStamina >= CGFloat(cost) {
            currentStamina -= CGFloat(cost)
            // Tell the scene to update the HUD
            (scene as? GameScene)?.playerUsedStamina()
            return true
        }
        // Not enough stamina
        return false
    }
    
    // In PlayerNode.swift

    /// Drains stamina over time while holding a boulder. Returns false if stamina runs out.
    func drainStamina(deltaTime: TimeInterval) -> Bool {
        currentStamina -= GameManager.shared.boulderHoldStaminaDrainRate * CGFloat(deltaTime)
        (scene as? GameScene)?.playerUsedStamina() // Update the HUD

        if currentStamina <= 0 {
            currentStamina = 0
            (scene as? GameScene)?.playerUsedStamina() // Final HUD update
            print("Stamina depleted!")
            return false // Out of stamina
        }
        return true // Still has stamina
    }
    
    // In PlayerNode.swift

    // --- ADD THIS NEW FUNCTION ---
    /// Restores stamina by a given amount, up to the maximum.
    func restoreStamina(amount: CGFloat) {
        currentStamina += amount
        if currentStamina > maxStamina {
            currentStamina = maxStamina
        }
        // Tell the scene to update the HUD
        (scene as? GameScene)?.playerUsedStamina()
    }

    // --- ADD this new function ---
    /// Regenerates stamina over time.
    func regenerateStamina(deltaTime: TimeInterval) {
        if currentStamina < maxStamina {
            // Add a fraction of the regen rate based on the time passed
            currentStamina += CGFloat(GameManager.shared.staminaRegenRate) * CGFloat(deltaTime)
            if currentStamina > maxStamina {
                currentStamina = maxStamina
            }
            (scene as? GameScene)?.playerUsedStamina()
        }
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
    
    // In PlayerNode.swift

    // --- ADD THESE NEW FUNCTIONS ---

    /// Applies a standard vertical jump impulse.
    func jump() {
        // A simple check to prevent air-jumping. If the player is already moving
        // vertically, don't allow another jump.
        //guard abs(physicsBody?.velocity.dy ?? 0) < 5 else { return }
        guard isGrounded else { return }
        isGrounded = false // Player is now in the air
        
        playAnimation(.jump)
        let jumpForce = GameManager.shared.playerJumpHeight
        physicsBody?.applyImpulse(CGVector(dx: 0, dy: jumpForce))
    }

    // In PlayerNode.swift

    // In PlayerNode.swift

    // In PlayerNode.swift

    func boulderJump() {
        // 1. Initial checks
        guard isGrounded, action(forKey: "action") == nil else { return }
        isGrounded = false
        
        // 2. Get the summon animation
        guard let summonAnimation = animationManager.getAction(for: .summonBoulder) else { return }
        
        // 3. Create an action that summons the boulder.
        // --- THE FIX: Tell the scene to use the main pullUpBoulder function ---
        let summonBoulderAction = SKAction.run { [weak self] in
            guard let self = self else { return }
            // We pass the player's world position to the scene.
            (self.scene as? GameScene)?.playerDidRequestBoulder(at: self.worldPosition)
        }
        
        // --- THE FIX: Add a wait action ---
        // The boulder's rise animation is 0.3s. We'll wait 0.2s so the jump
        // happens just as the boulder is locking into its final position.
        let waitAction = SKAction.wait(forDuration: 0.3)
        
        // 4. Create an action that performs the jump.
        let performJumpAction = SKAction.run { [weak self] in
            guard let self = self else { return }
            self.playAnimation(.jump)
            let boulderJumpForce = GameManager.shared.playerJumpHeight * 1.75
            let horizontalBoost: CGFloat = self.isFacingRight ? 300.0 : -300.0
            self.physicsBody?.applyImpulse(CGVector(dx: 0, dy: boulderJumpForce))
        }
        
        // 5. Create the final sequence: Animate -> Summon -> Wait -> Jump
        let sequence = SKAction.sequence([summonAnimation, summonBoulderAction, waitAction, performJumpAction])
        
        // 6. Run the sequence
        self.run(sequence, withKey: "action")
    }
    
    
    // --- REMOVE THE OLD LAUNCH FUNCTION ---
    // func launch(with impulse: CGVector) { ... }
    
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
        physicsBody?.contactTestBitMask = PhysicsCategory.enemy | PhysicsCategory.pickup | PhysicsCategory.ground
        
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
