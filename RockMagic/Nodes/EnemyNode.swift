//
//  EnemyNode.swift
//  RockMagic
//
//  Created by Tucker Hoppe on 5/1/25.
//

import Foundation
import SpriteKit

enum EnemyState {
    case idle
    case walking
    case tossed
    case dying
}

class EnemyNode: SKSpriteNode {
    
    var isFacingRight: Bool = true
    var walkAction: SKAction!
    var isWalking = false
    
    var currentState: EnemyState = .idle
    var idleAction: SKAction!
    var tossedAction: SKAction!
    
    let walkFrames = (1...5).map { SKTexture(imageNamed: "badGuyR\($0)") }
    var moveSpeed: CGFloat = 100.0
    let stoppingDistance: CGFloat = 25.0 // NEW: How close to get before stopping
    var positionalOffset: CGFloat = 0.0
    
    // --- HEALTH  & DAMAGE PROPERTIES ---
    var maxHealth: Int = 100
    var currentHealth: Int = 100
    var isInvulnerable = false // Prevents damage spam
    var justTossed = false
    var damage: Int = 1
    
    // --- 2. HEALTH BAR NODES ---
    private var healthBarBackground: SKShapeNode!
    private var healthBar: SKShapeNode!
    private let healthBarWidth: CGFloat = 50
    private let healthBarHeight: CGFloat = 6
    
    init() {
        
        let texture = SKTexture(imageNamed: "badGuyR1")
        super.init(texture: texture, color: .clear, size: texture.size())
        
        self.positionalOffset = CGFloat.random(in: -15.0...15.0)
        self.name = "enemy"
        self.zPosition = Constants.ZPositions.enemy
        
        // Get the current enemy health from the shared manager
        self.maxHealth = GameManager.shared.enemyHealth
        self.damage = GameManager.shared.enemyDamage
        self.currentHealth = self.maxHealth

        // Setup
        setupPhysicsBody()
        setupHealthBar() // Call the new setup function
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
    // --- ADD THIS NEW ATTACK FUNCTION ---
    private func attack(target: PlayerNode) {
        // First, check if the player is still in range to be hit.
        let attackRange: CGFloat = 75.0 // The enemy's reach
        let distance = abs(self.position.x - target.worldPosition.x)
        
        if distance <= attackRange {
            print("Enemy attacks player!")
            target.takeDamage(amount: self.damage)
            
            // Tell the scene to update the health bar
            if let gameScene = self.scene as? GameScene {
                gameScene.playerTookDamage()
            }
        }
    }

    private func setupHealthBar() {
        // Create the background bar
        healthBarBackground = SKShapeNode(rectOf: CGSize(width: healthBarWidth, height: healthBarHeight), cornerRadius: 3)
        healthBarBackground.fillColor = .darkGray
        healthBarBackground.strokeColor = .clear
        healthBarBackground.position = CGPoint(x: 0, y: self.size.height / 2 + 15)
        healthBarBackground.zPosition = self.zPosition + 1
        addChild(healthBarBackground)
        
        // Create the foreground bar
        healthBar = SKShapeNode(rectOf: CGSize(width: healthBarWidth, height: healthBarHeight), cornerRadius: 3)
        healthBar.fillColor = .green
        healthBar.strokeColor = .clear
        
        // Position it directly in the center of the background. We will adjust it later.
        healthBar.position = .zero
        
        healthBar.zPosition = healthBarBackground.zPosition + 1
        healthBarBackground.addChild(healthBar)
    }
    
    private func updateHealthBar() {
        let healthPercentage = CGFloat(currentHealth) / CGFloat(maxHealth)
        
        // --- THE FIX ---
        // 1. Scale the bar's width
        let scaleAction = SKAction.scaleX(to: healthPercentage, duration: 0.2)
        
        // 2. Calculate the new X position to keep the bar left-aligned
        let newXPosition = -((healthBarWidth * (1 - healthPercentage)) / 2)
        let moveAction = SKAction.moveTo(x: newXPosition, duration: 0.2)
        
        // 3. Group the actions to run them simultaneously
        let updateGroup = SKAction.group([scaleAction, moveAction])
        healthBar.run(updateGroup)
    }
    
    // --- 4. TAKE DAMAGE FUNCTION ---
    func takeDamage(amount: Int) {
        // Can't take damage if invulnerable or already in the process of dying
        if isInvulnerable || currentState == .dying { return }
        
        currentHealth -= amount
        
        // Become invulnerable for a short period to prevent instant multi-hits
        isInvulnerable = true
        let wait = SKAction.wait(forDuration: 0.5)
        let makeVulnerable = SKAction.run { [weak self] in
            self?.isInvulnerable = false
        }
        run(SKAction.sequence([wait, makeVulnerable]))
        
        if currentHealth < 0 {
            currentHealth = 0
        }
        
        updateHealthBar()
        
        // If health is zero, enter the 'dying' state.
        // The node is NOT removed yet. The toss will still happen.
        if currentHealth <= 0 {
            currentState = .dying
            healthBarBackground.run(SKAction.fadeOut(withDuration: 0.01))
        }
    }
    
    // --- 5. DEATH FUNCTION ---
    func startDeathSequence() {
        self.removeAllActions()
        // Make it a non-physical "ragdoll" so it doesn't interact with anything else
        self.physicsBody?.isDynamic = false
        self.physicsBody?.categoryBitMask = PhysicsCategory.none
        
        // --- ADD THIS BLOCK TO DROP A COIN ---
        // 1. Create a coin pickup
        let coin = PickupNode(type: .coin)
        // 2. Position it where the enemy died
        coin.position = self.position
        coin.position.y = GameManager.shared.groundLevel + 15
        // 3. Add it to the world so it scrolls
        self.parent?.addChild(coin)
        
        
        let fadeOut = SKAction.fadeOut(withDuration: 0.5)
        let scaleDown = SKAction.scale(to: 0.1, duration: 0.5)
        let deathAnimation = SKAction.group([fadeOut, scaleDown])
        
        let sequence = SKAction.sequence([deathAnimation, SKAction.removeFromParent()])
        self.run(sequence)
        
        (scene as? GameScene)?.enemyDefeated()
    }

    func setAnimationState(to newState: EnemyState, target: PlayerNode? = nil) {
        // Don't do anything if we're already in this state
        if currentState == newState { return }
        
        // Stop any existing animation before starting a new one
        removeAction(forKey: "animation")
        
        switch newState {
        case .walking:
            // Lazily create the action the first time it's needed
            if walkAction == nil {
                walkAction = SKAction.repeatForever(SKAction.animate(with: walkFrames, timePerFrame: 0.1, resize: true, restore: false))
            }
            run(walkAction, withKey: "animation")
            
        case .idle:
            if let attackTarget = target {
                // --- Attacking Idle ---
                // A target was provided, so we play the full attack loop.
                let frame1 = SKAction.setTexture(SKTexture(imageNamed: "badGuyR1"), resize: true)
                let frame2 = SKAction.setTexture(SKTexture(imageNamed: "badGuyLaunched"), resize: true)
                let frameAttack = SKAction.setTexture(SKTexture(imageNamed: "badGuyAttack"), resize: true)
                let wait = SKAction.wait(forDuration: 0.25)
                
                let runAttack = SKAction.run { [weak self] in
                    self?.attack(target: attackTarget)
                }
                let sequence = SKAction.sequence([frame1, wait, frame1, wait, frameAttack, runAttack, wait])
                
                self.idleAction = SKAction.repeatForever(sequence)
                run(idleAction, withKey: "animation")
                
            } else {
                // --- Neutral Idle ---
                // No target was provided. This happens after a toss.
                // Just stand still on the first frame.
                self.texture = SKTexture(imageNamed: "badGuyR1")
                
            }
            
        case .tossed:
            // Lazily creates the action the first time its needed
            if tossedAction == nil {
                let tossedFrames = [SKTexture(imageNamed: "badGuyLaunched")]
                tossedAction = SKAction.repeatForever(SKAction.animate(with: tossedFrames, timePerFrame: 0.25, resize: true, restore: false))
            }
            run(tossedAction, withKey: "animation")
        
        case .dying:
            print("DYING!")
            
        }
        
        currentState = newState
    }
    


    // In EnemyNode.swift

    func getTossed(by rockPiece: RockPiece, bypassVelocityCheck: Bool = false, isQuickStrike: Bool = false) {
        if currentState == .dying { return }
        
        guard let enemyBody = self.physicsBody, let rockBody = rockPiece.physicsBody else { return }

//        let velocityThreshold: CGFloat = 25.0
//        guard rockBody.velocity.dx.magnitude > velocityThreshold || rockBody.velocity.dy.magnitude > velocityThreshold else {
//            return
//        }
        
        // If the bypass is false (for normal collisions), perform the velocity check.
        if !bypassVelocityCheck {
            let velocityThreshold: CGFloat = 25.0
            guard rockBody.velocity.dx.magnitude > velocityThreshold || rockBody.velocity.dy.magnitude > velocityThreshold else {
                return
            }
        }
        

        setAnimationState(to: .tossed)
        
        // The justTossed flag is still good to have for when the launch works.
        justTossed = true
        let wait = SKAction.wait(forDuration: 0.2)
        let resetFlag = SKAction.run { [weak self] in
            self?.justTossed = false
        }
        run(SKAction.sequence([wait, resetFlag]))

        let finalImpulse: CGVector
        var damageToDeal = 0

        if rockPiece.isAttached && !isQuickStrike, let boulder = rockPiece.parentBoulder, let boulderBody = boulder.physicsBody {
            let attachedCount = boulder.pieces.filter { $0.isAttached }.count
            
            let powerMultiplier: CGFloat
            switch attachedCount {
            case 3:
                powerMultiplier = 1.2
                damageToDeal = GameManager.shared.fullBoulderDamage
            case 2:
                powerMultiplier = 1.1
                damageToDeal = GameManager.shared.twoThirdBoulderDamage
            default:
                powerMultiplier = 1.0
                damageToDeal = GameManager.shared.oneThirdBoulderDamage
            }
            

            let hitDirection = boulderBody.velocity.normalized()
            
            // --- THE FIX: MUCH LARGER FORCES ---
            // We need hundreds of units of force, not tens.
            let baseBoulderKnockback: CGFloat = GameManager.shared.boulderBaseKnockback // Increased from 35
            
            let impulseMagnitude = baseBoulderKnockback * powerMultiplier
            let horizontalImpulse = hitDirection.dx * impulseMagnitude
            
            // The vertical impulse is CRITICAL for the "toss" effect.
            let verticalImpulse: CGFloat = GameManager.shared.boulderVertKnockback * powerMultiplier // Increased from 20

            finalImpulse = CGVector(dx: horizontalImpulse, dy: verticalImpulse)
            boulder.applyBrakes()

        } else {
            // SINGLE PIECE hit - also needs more force, but less than a full boulder.
            //print("Light attack!")
            damageToDeal = GameManager.shared.rockPieceDamage
            
            let basePieceKnockback: CGFloat = GameManager.shared.rockPieceBaseKnockback // Increased from 30
            let rockSizeMultiplier = (rockPiece.size.width * rockPiece.size.height) / 1000.0
            let hitDirection = rockBody.velocity.normalized()
            
            let impulseMagnitude = basePieceKnockback * rockSizeMultiplier
            let horizontalImpulse = hitDirection.dx * impulseMagnitude
            let verticalImpulse: CGFloat = 30.0 // Increased from 30
            
            finalImpulse = CGVector(dx: horizontalImpulse, dy: verticalImpulse)
            // --- ADD THIS LINE ---
            // If this is a single, detached piece, remove it on impact.
            if !bypassVelocityCheck {
                    rockPiece.removeFromParent()
                }
        }

        takeDamage(amount: damageToDeal)
        enemyBody.applyImpulse(finalImpulse)
        
    }
    

    // Add this new function to launch the enemy from below
    func launchFromBelow() {
        // Only launch if not already in the air
        guard currentState != .tossed && currentState != .dying else { return }
        
        //print("Enemy launched from below!")
        setAnimationState(to: .tossed)
        takeDamage(amount: 5) // Apply minimal damage

        // Apply a strong vertical impulse
        let impulse = CGVector(dx: 0, dy: GameManager.shared.launchEnemyFromBelow)
        physicsBody?.applyImpulse(impulse)
    }
    

    func moveTowards(objective: PlayerNode) {
        
        guard currentState != .tossed && currentState != .dying else { return }
        
        guard let physicsBody = self.physicsBody else { return }
        
        let distance = abs(self.position.x - objective.worldPosition.x)
        // Each enemy now calculates its own unique stopping distance
        let uniqueStoppingDistance = stoppingDistance + positionalOffset // <-- MODIFY THIS LINE

        if distance <= uniqueStoppingDistance { // <-- And check against it here
            // If too close, stop moving and switch to the idle/attack animation
            setAnimationState(to: .idle, target: objective)
            physicsBody.velocity = CGVector(dx: 0, dy: physicsBody.velocity.dy)
            
        } else {
            // If far enough away, move towards the player
            let direction: CGFloat = (objective.worldPosition.x < self.position.x) ? -1.0 : 1.0
            
            self.xScale = (direction < 0) ? -abs(self.xScale) : abs(self.xScale)
            
            // Switch to the walking animation
            setAnimationState(to: .walking)
            
            physicsBody.velocity = CGVector(dx: moveSpeed * direction, dy: physicsBody.velocity.dy)
        }
    }

    
    func setupPhysicsBody() {
        self.physicsBody = SKPhysicsBody(rectangleOf: self.size)
        self.physicsBody?.isDynamic = true
        self.physicsBody?.affectedByGravity = true
        self.physicsBody?.allowsRotation = false
        //self.physicsBody?.mass = 8.0 // Heavier to absorb force
        
        // Physics categories
        self.physicsBody?.categoryBitMask = PhysicsCategory.enemy
        
        physicsBody?.collisionBitMask = PhysicsCategory.ground | PhysicsCategory.wall | PhysicsCategory.edge //| PhysicsCategory.rockPiece
        physicsBody?.contactTestBitMask = PhysicsCategory.player | PhysicsCategory.bullet | PhysicsCategory.ground | PhysicsCategory.boulder
    }


    
    
}
