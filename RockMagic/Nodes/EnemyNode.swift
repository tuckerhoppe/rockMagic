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
    case attacking
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
    var attackAction: SKAction!
    
    let walkFrames = (1...5).map { SKTexture(imageNamed: "badGuyR\($0)") }
    var moveSpeed: CGFloat = GameManager.shared.enemyMoveSpeed
    var myMoveSpeed: CGFloat = 0.0
    var stoppingDistance: CGFloat = 25.0 // NEW: How close to get before stopping
    var positionalOffset: CGFloat = 0.0
    
    private var lastAttackTime: TimeInterval = 0
    
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
        self.zPosition = ZPositions.enemy
        
        // Get the current enemy health from the shared manager
        self.maxHealth = GameManager.shared.enemyHealth
        self.damage = GameManager.shared.enemyDamage
        self.currentHealth = self.maxHealth
        
        
        
        // 1. Get the base speed from the GameManager.
        self.moveSpeed = GameManager.shared.enemyMoveSpeed
        
        let enemyTypeRoll = Int.random(in: 1...13)

        if enemyTypeRoll <= 4 { // 30% chance t(rolls 1, 2, or 3)
            // --- LITTLE RAT ---
            self.moveSpeed *= 1.5
            self.currentHealth = 60 // Easy to kill
            self.setScale(0.65)
            self.color = .red
            self.colorBlendFactor = 0.3
            print("Little Rat spawned!")
            
        } else if enemyTypeRoll <= 5 { // 10% chance to be a "Big Boy" (rolls 4)
            // --- BIG BOY ---
            self.moveSpeed *= 0.5
            self.damage *= 2
            self.currentHealth *= 2
            self.maxHealth *= 2
            self.setScale(1.75)
            self.color = .blue
            self.colorBlendFactor = 0.3
            print("Big Boy spawned!")
            
        }
//        else if enemyTypeRoll <= 7 { // 20% chance to be a "Blocker" (rolls 6 or 7)
//            // --- ADD THIS NEW BLOCKER TYPE ---
//            self.stoppingDistance = 250.0 // Stops far away
//            self.damage = 0 // Deals no damage
//            self.currentHealth = 50 // Easy to kill
//            self.maxHealth = 50
//            self.moveSpeed *= 1.2 // Moves quickly
//            self.color = .yellow
//            self.colorBlendFactor = 0.4
//            print("Blocker spawned!")
//        }
        
        self.myMoveSpeed = moveSpeed
        
        // Setup
        setupPhysicsBody()
        setupHealthBar() // Call the new setup function
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
    // --- ADD THIS NEW ATTACK FUNCTION ---
    private func attackOLD(target: PlayerNode) {
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
    
    // --- UPDATE THE ATTACK FUNCTION ---
    private func attack(target: PlayerNode) {
        // 1. Check if the attack is off cooldown.
        let currentTime = CACurrentMediaTime()
        guard currentTime - lastAttackTime > GameManager.shared.enemyAttackCooldown else { return }
        
        // 2. Check if the player is still in range.
        let attackRange = GameManager.shared.enemyAttackRange
        let distance = abs(self.position.x - target.worldPosition.x)
        
        if distance <= attackRange {
            // 3. If both checks pass, update the timer and deal damage.
            lastAttackTime = currentTime
            
            print("Enemy attacks player!")
            target.takeDamage(amount: self.damage)
            
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
        
        guard let physicsBody = self.physicsBody else { return }
        
        // Stop any existing animation before starting a new one
        removeAction(forKey: "animation")
        
        switch newState {
        case .walking:
            // Lazily create the action the first time it's needed
            if walkAction == nil {
                walkAction = SKAction.repeatForever(SKAction.animate(with: walkFrames, timePerFrame: 0.1, resize: true, restore: false))
            }
            run(walkAction, withKey: "animation")
            print("walking")
        case .attacking:
            
            guard let attackTarget = target else { return }
            
            // if player is walking
            if attackTarget.isWalking {
                // Walking Attack
                print("attacking!")
//                
//                run(sequence, withKey: "animation")
                let frame1 = SKAction.setTexture(SKTexture(imageNamed: "badGuyR1"), resize: true)
                let frameAttack = SKAction.setTexture(SKTexture(imageNamed: "badGuyAttack"), resize: true)
                let wait = SKAction.wait(forDuration: 0.25)
                
                let runAttack = SKAction.run { [weak self] in
                    self?.attack(target: attackTarget)
                }
                let sequence = SKAction.sequence([frame1, wait, frameAttack, runAttack, wait])
                
                self.attackAction = SKAction.repeatForever(sequence)
                run(attackAction, withKey: "animation")
                
                let distance = abs(self.position.x - attackTarget.worldPosition.x)
                
                if distance < 30 && self.moveSpeed > 250.0 {
                    self.moveSpeed = 250.0
                    print("first one! player MOve speed: ", GameManager.shared.playerMoveSpeed)
                }
//                else {
//                    self.moveSpeed = myMoveSpeed
//                    print("second one! enemy MOve speed: ",GameManager.shared.enemyMoveSpeed)
//                }
                
                print("move speed: ", self.moveSpeed)
                walkToTarget(objective: attackTarget)
                
                
            } else {
                // --- Idle Attack (Stationary) ---
                //print("Enemy performs an idle attack!")
                
                physicsBody.velocity = CGVector(dx: 0, dy: physicsBody.velocity.dy)
                // This is your existing stationary attack loop.
                let frame1 = SKAction.setTexture(SKTexture(imageNamed: "badGuyR1"), resize: true)
                let frameAttack = SKAction.setTexture(SKTexture(imageNamed: "badGuyAttack"), resize: true)
                let wait = SKAction.wait(forDuration: 0.25)
                
                let runAttack = SKAction.run { [weak self] in
                    self?.attack(target: attackTarget)
                }
                let sequence = SKAction.sequence([frame1, wait, frameAttack, runAttack, wait])
                
                self.attackAction = SKAction.repeatForever(sequence)
                run(attackAction, withKey: "animation")
            }
            
        case .idle:
//            if let attackTarget = target {
//                // --- Attacking Idle ---
//                // A target was provided, so we play the full attack loop.
//                let frame1 = SKAction.setTexture(SKTexture(imageNamed: "badGuyR1"), resize: true)
//                //let frame2 = SKAction.setTexture(SKTexture(imageNamed: "badGuyLaunched"), resize: true)
//                let frameAttack = SKAction.setTexture(SKTexture(imageNamed: "badGuyAttack"), resize: true)
//                let wait = SKAction.wait(forDuration: 0.25)
//                
//                let runAttack = SKAction.run { [weak self] in
//                    self?.attack(target: attackTarget)
//                }
//                let sequence = SKAction.sequence([frame1, wait, frame1, wait, frameAttack, runAttack, wait])
//                
//                self.idleAction = SKAction.repeatForever(sequence)
//                run(idleAction, withKey: "animation")
//                
//            } else {
//                // --- Neutral Idle ---
//                // No target was provided. This happens after a toss.
//                // Just stand still on the first frame.
                self.texture = SKTexture(imageNamed: "badGuyR1")
                
           // }
            
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
    
    func calculateChasingSpeed(input: CGFloat) -> CGFloat {
        let growthRate: CGFloat = 100.0
        return 250 * (1 - 1 / (input / growthRate + 1))
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

    // The function now accepts the position of the boulder that is launching it.
    func launchFromBelow(boulderPosition: CGPoint) {
        // Only launch if not already in the air
        guard currentState != .tossed && currentState != .dying else { return }
        
        let launchActions = SKAction.run { [weak self] in
            guard let self = self else { return }
            
            self.setAnimationState(to: .tossed)
            self.takeDamage(amount: 5)

            // --- THE FIX: Calculate horizontal impulse ---
            // Determine if the enemy is to the left or right of the boulder's center.
            let horizontalDirection: CGFloat = (self.position.x < boulderPosition.x) ? -1.0 : 1.0
            
            // A small horizontal force to push them away from the center.
            let horizontalImpulse: CGFloat = GameManager.shared.launchEnemyFromBelowX * horizontalDirection
            
            // Apply both the horizontal and vertical impulse.
            let impulse = CGVector(dx: horizontalImpulse, dy: GameManager.shared.launchEnemyFromBelowY)
            self.physicsBody?.applyImpulse(impulse)
        }
        
        let waitAction = SKAction.wait(forDuration: 0.2)
        let sequence = SKAction.sequence([waitAction, launchActions])
        self.run(sequence)
    }
    
    
    // --- REPLACE this function ---
    func moveTowardsNEW(objective: PlayerNode) {
        // The "Brain" of the enemy.
        if currentState == .tossed || currentState == .dying { return }
        guard let physicsBody = self.physicsBody else { return }
        
        let distance = abs(self.position.x - objective.worldPosition.x)
        
        // If the player is in range, the enemy's only job is to attack.
        if distance <= GameManager.shared.enemyAttackRange {
            setAnimationState(to: .attacking, target: objective)
            // Stop moving to perform the attack.
            physicsBody.velocity = CGVector(dx: 0, dy: physicsBody.velocity.dy)
            
            
        } else {
            // If the player is out of range, the enemy's only job is to walk.
            setAnimationState(to: .walking)
            let direction: CGFloat = (objective.worldPosition.x < self.position.x) ? -1.0 : 1.0
            self.xScale = (direction < 0) ? -abs(self.xScale) : abs(self.xScale)
            physicsBody.velocity = CGVector(dx: moveSpeed * direction, dy: physicsBody.velocity.dy)
        }
    }

    func moveTowards(objective: PlayerNode) {
        
        guard currentState != .tossed && currentState != .dying else { return }
        
        guard let physicsBody = self.physicsBody else { return }
        
        let distance = abs(self.position.x - objective.worldPosition.x)
        // Each enemy now calculates its own unique stopping distance
        let uniqueStoppingDistance = stoppingDistance + positionalOffset // <-- MODIFY THIS LINE
    

        if distance <= uniqueStoppingDistance { // <-- And check against it here
            // If in Range change to the attacking state
            setAnimationState(to: .attacking, target: objective)
            //physicsBody.velocity = CGVector(dx: 0, dy: physicsBody.velocity.dy)
            //walkToTarget(objective: objective)
            
        } else { // When walking...
            self.moveSpeed = myMoveSpeed
            walkToTarget(objective: objective)
            // Switch to the walking animation
            setAnimationState(to: .walking)
        }
    }
    
    func walkToTarget(objective: PlayerNode) {
        guard let physicsBody = self.physicsBody else { return }
        let direction: CGFloat = (objective.worldPosition.x < self.position.x) ? -1.0 : 1.0
        
        self.xScale = (direction < 0) ? -abs(self.xScale) : abs(self.xScale)
        physicsBody.velocity = CGVector(dx: moveSpeed * direction, dy: physicsBody.velocity.dy)
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
