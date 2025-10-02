//
//  EnemyNode.swift
//  RockMagic
//
//  Created by Tucker Hoppe on 5/1/25.
//

import Foundation
import SpriteKit


enum AttackType {
    case direct // A standard hit from a launched boulder/piece
    case splash // Damage from a splash attack
}
enum EnemyState {
    case idle
    case attacking
    case walking
    case tossed
    case dying
}

enum EnemyType {
    case normal
    case littleRat
    case bigBoy
    case blocker
}

class EnemyNode: SKSpriteNode {
    
    var isFacingRight: Bool = true
    var walkAction: SKAction!
    var isWalking = false
    
    var currentState: EnemyState = .idle
    var idleAction: SKAction!
    var tossedAction: SKAction!
    var attackAction: SKAction!
    
    let walkFrames = (1...5).map { SKTexture(imageNamed: "goblinWalk\($0)") }
    var moveSpeed: CGFloat = GameManager.shared.enemyMoveSpeed
    var myMoveSpeed: CGFloat = 0.0
    var stoppingDistance: CGFloat = 35 // NEW: How close to get before stopping
    var positionalOffset: CGFloat = 0.0
    
    var originalFriction: CGFloat = 0.5 // A default value
    
    private var lastAttackTime: TimeInterval = 0
    var lastContactDamageTime: TimeInterval = 0
    
    // --- HEALTH  & DAMAGE PROPERTIES ---
    var maxHealth: Int = 100
    var currentHealth: Int = 100
    var isInvulnerable = false // Prevents damage spam
    var justTossed = false
    var damage: Int = 1
    
    var isOnPillar: Bool = false
    
    var shield: Bool = false
    private var shieldSprite: SKSpriteNode!

    
    // --- 2. HEALTH BAR NODES ---
    private var healthBarBackground: SKShapeNode!
    private var healthBar: SKShapeNode!
    private let healthBarWidth: CGFloat = 50
    private let healthBarHeight: CGFloat = 6
    
    var enemyType: EnemyType = .normal
    
    var primaryObjective: Damageable?
    
//    init() {
//        
//        let texture = SKTexture(imageNamed: "badGuyR1")
//        super.init(texture: texture, color: .clear, size: texture.size())
//        
//        self.positionalOffset = CGFloat.random(in: -15.0...15.0)
//        self.name = "enemy"
//        self.zPosition = ZPositions.enemy
//        
//        // Get the current enemy health from the shared manager
//        self.maxHealth = GameManager.shared.enemyHealth
//        self.damage = GameManager.shared.enemyDamage
//        self.currentHealth = self.maxHealth
//        
//        
//        
//        // 1. Get the base speed from the GameManager.
//        self.moveSpeed = GameManager.shared.enemyMoveSpeed
//        
//        let enemyTypeRoll = Int.random(in: 1...13)
//
//        if enemyTypeRoll <= 4 { // 30% chance t(rolls 1, 2, or 3)
//            // --- LITTLE RAT ---
//            self.enemyType = .littleRat
//            self.moveSpeed *= 1.5
//            self.currentHealth /= 2 // Easy to kill
//            self.maxHealth /= 2 // Easy to kill
//            self.setScale(0.65)
//            self.color = .red
//            self.colorBlendFactor = 0.3
//            print("Little Rat spawned!")
//            
//        } else if enemyTypeRoll <= 5 { // 10% chance to be a "Big Boy" (rolls 4)
//            // --- BIG BOY ---
//            self.enemyType = .bigBoy
//            self.moveSpeed *= 0.5
//            self.damage *= 2
//            self.currentHealth *= 2
//            self.maxHealth *= 2
//            self.setScale(1.75)
//            self.color = .blue
//            self.colorBlendFactor = 0.3
//            print("Big Boy spawned!")
//            
//        } else if enemyTypeRoll <= 7 { // 20% chance
//            // --- ADD THIS NEW BLOCKER TYPE ---
//            self.enemyType = .blocker
//            self.moveSpeed *= 0.75
//            //self.currentHealth *= 2 // Tough to break
//            //self.maxHealth *= 2
//            self.shield = true
//            self.setScale(0.9)
//            self.color = .yellow
//            self.colorBlendFactor = 0.4
//            print("Blocker spawned!")
//        }
//
//        
//        self.myMoveSpeed = moveSpeed
//        
//        // Setup
//        setupPhysicsBody()
//        setupHealthBar() // Call the new setup function
//    }
    
    // In EnemyNode.swift

    // The initializer now requires an EnemyType
    init(type: EnemyType) {
        let texture = SKTexture(imageNamed: "badGuyR1")
        super.init(texture: texture, color: .clear, size: texture.size())
        
        // --- Set default properties ---
        self.positionalOffset = CGFloat.random(in: -15.0...15.0)
        self.name = "enemy"
        self.zPosition = ZPositions.enemy
        self.maxHealth = GameManager.shared.enemyHealth
        self.damage = GameManager.shared.enemyDamage
        self.currentHealth = self.maxHealth
        self.moveSpeed = GameManager.shared.enemyMoveSpeed
        
        // --- ADD THIS BLOCK to create the shield ---
        // Replace "Shield_Icon" with your actual asset name
        shieldSprite = SKSpriteNode(imageNamed: "shield")
        // Set the shield to be exactly 50x50 points.
        shieldSprite.size = CGSize(width: 35, height: 35)
        shieldSprite.zPosition = 1 // Make sure it's in front of the enemy
        shieldSprite.isHidden = true // Start hidden
        addChild(shieldSprite)
        // ------------------------------------------
        //addDebugAttackRange()
        
        
        // --- Configure the enemy based on its type ---
        configure(for: type)
        
        updateShieldVisibility()
        
        // --- Final Setup ---
        self.myMoveSpeed = moveSpeed
        setupPhysicsBody()
        setupHealthBar()
    }

    /// Applies stat modifications based on the enemy's type.
    private func configure(for type: EnemyType) {
        self.enemyType = type
        
        switch type {
        case .littleRat:
            self.moveSpeed *= 1.5
            self.currentHealth /= 2
            self.maxHealth /= 2
            self.setScale(0.65)
            self.color = .red
            self.colorBlendFactor = 0.3
            //print("Little Rat spawned!")
            
        case .bigBoy:
            self.moveSpeed *= 0.5
            self.damage *= 2
            self.currentHealth *= 2
            self.maxHealth *= 2
            self.setScale(1.75)
            self.color = .blue
            self.colorBlendFactor = 0.3
            //print("Big Boy spawned!")
            
        case .blocker:
            self.moveSpeed *= 0.75
            self.shield = true
            self.setScale(0.9)
            self.color = .yellow
            self.colorBlendFactor = 0.4
            //print("Blocker spawned!")
            
        case .normal:
            // No changes needed for a normal enemy
            break
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // The function now accepts the player as a parameter
    private func performDodge() {
        //print("Little Rat dodged!")
        // A small hop up and away from the player
        //let horizontalDirection: CGFloat = (self.position.x < player.worldPosition.x) ? -1.0 : 1.0
        let impulse = CGVector(dx: 0, dy: 8)
        physicsBody?.applyImpulse(impulse)
    }
    
    /// Shows or hides the shield sprite based on the shield property.
    func updateShieldVisibility() {
        shieldSprite.isHidden = !shield
    }
    
    /// If the enemy is on a pillar, this function applies a continuous force to slide it off.
    func applyPillarSlideForce() {
        // Only apply the force if the flag is true.
        guard isOnPillar else { return }

        // Determine which direction to slide based on the enemy's position relative to the scene's center.
        // This is a simple way to ensure they always slide outwards.
        let slideDirection: CGFloat = (self.position.x < 0) ? -1.0 : 1.0
        
        let slideForce: CGFloat = 115.0 // A small, continuous force
        let forceVector = CGVector(dx: slideForce * slideDirection, dy: 0)
        
        self.currentState = .tossed
        // Use applyForce, which is designed for continuous application in an update loop.
        self.physicsBody?.applyForce(forceVector)
    }

    

    
    // --- UPDATE THE ATTACK FUNCTION ---
    private func attack(target: Damageable) {
        // 1. Check if the attack is off cooldown.
//        let currentTime = CACurrentMediaTime()
//        guard currentTime - lastAttackTime > GameManager.shared.enemyAttackCooldown else { return }
        let targetX: CGFloat
        
        // 1. Check if the objective is a PlayerNode.
        if let player = target as? PlayerNode {
            // If yes, use its special worldPosition property.
            targetX = player.worldPosition.x
        } else {
            // 2. Otherwise (its an SKNode), use its normal position.
            targetX = target.position.x
        }
        // 2. Check if the player is still in range.
        let attackRange = GameManager.shared.enemyAttackRange
        //let distance = abs(self.position.x - targetX)
        let distance: CGFloat
        
        if let pillar = target as? PillarNode {
            let pillarWidth = pillar.frame.width
            let enemyWidth = self.frame.width
//            print("pillarWidth",pillarWidth)
//            print("enemyWIdth", enemyWidth)
            // 2. Calculate the distance between their centers.
            let centerToCenterDistance = abs(self.position.x - pillar.position.x)

            // 3. Subtract half of each object's width to get the distance between their edges.
            let distanceToPillarEdge = centerToCenterDistance - (pillarWidth / 2) - (enemyWidth / 2)
            
            distance = distanceToPillarEdge
        } else {
            distance = abs(self.position.x - targetX)
        }
        
        if distance <= attackRange {
            // 3. If both checks pass, update the timer and deal damage.
            //lastAttackTime = currentTime
            
            //print("Enemy attacks object!")
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
    func takeDamage(amount: Int, contactPoint: CGPoint, largeStrike: Bool = false) {
        // Can't take damage if invulnerable or already in the process of dying
        if isInvulnerable || currentState == .dying { return }
        
        if contactPoint != .zero {
            // --- THE FIX: Check the rock piece's state ---
            if largeStrike {
                // If the piece is part of a full boulder, play the big effect.
                EffectManager.shared.playBoulderImpactEffect(at: contactPoint, level: GameManager.shared.strongAttackLevel)
            } else {
                // If it's a single, loose piece, play the small effect.
                EffectManager.shared.playRockPieceImpactEffect(at: contactPoint, level: GameManager.shared.quickAttackLevel)
            }
        }
        
        
        currentHealth -= amount
        
        // Become invulnerable for a short period to prevent instant multi-hits
        isInvulnerable = true
        let wait = SKAction.wait(forDuration: 0.025)
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
            //currentState = .dying
            healthBarBackground.run(SKAction.fadeOut(withDuration: 0.01))
        }
    }
    
    // --- 5. DEATH FUNCTION ---
    func startDeathSequence() {
        
        // 1. Safely cast the scene to a GameScene.
        if let gameScene = self.scene as? GameScene {
            // 2. Check if the tutorial is on the "kill enemy" step.
            if gameScene.tutorialManager.currentTutorialStep == .littleRat && self.enemyType == .littleRat {
                // 3. If yes, complete the step.
                gameScene.tutorialManager.completeTutorialStep()
            } else if gameScene.tutorialManager.currentTutorialStep == .blocker && self.enemyType == .blocker {
                gameScene.tutorialManager.completeTutorialStep()
            }
        }
        
        self.removeAllActions()
        // Make it a non-physical "ragdoll" so it doesn't interact with anything else
        self.physicsBody?.isDynamic = false
        self.physicsBody?.categoryBitMask = PhysicsCategory.none
        
        if self.enemyType == .bigBoy {
            // If it's a Big Boy, drop a fiveCoin.
            let coin = PickupNode(type: .fiveCoin)
            coin.position = self.position
            coin.position.y = GameManager.shared.groundLevel + 15
            self.parent?.addChild(coin)
        } else {
            // Otherwise, drop a normal coin.
            let coin = PickupNode(type: .coin)
            coin.position = self.position
            coin.position.y = GameManager.shared.groundLevel + 15
            self.parent?.addChild(coin)
        }
        
        // --- ADD THIS BLOCK TO DROP A STAMINA PICKUP ---
//        let staminaPickup = PickupNode(type: .stamina)
//        staminaPickup.position = self.position
//        // Offset it slightly from the coin so they don't overlap
//        staminaPickup.position.x += 30
//        staminaPickup.position.y = GameManager.shared.groundLevel + 15
//        self.parent?.addChild(staminaPickup)
        
        let fadeOut = SKAction.fadeOut(withDuration: 0.5)
        let scaleDown = SKAction.scale(to: 0.1, duration: 0.5)
        let deathAnimation = SKAction.group([fadeOut, scaleDown])
        
        let sequence = SKAction.sequence([deathAnimation, SKAction.removeFromParent()])
        self.run(sequence)
        
        if self.enemyType == .normal {
            (scene as? GameScene)?.addScore(amount: 1, at: self.position)
        } else {
            (scene as? GameScene)?.addScore(amount: 2, at: self.position)
        }
        
    }

    func setAnimationState(to newState: EnemyState, target: Damageable? = nil) {
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
            //print("walking")
        case .attacking:
            
            guard let attackTarget = target else { return }
            
            
            
            if let player = attackTarget as? PlayerNode, player.isWalking {
                // if player is walking
                
                // Walking Attack
                //print("attacking!")
//
//                run(sequence, withKey: "animation")
                let frame1 = SKAction.setTexture(SKTexture(imageNamed: "goblinIdle"), resize: true)
                let frameAttack = SKAction.setTexture(SKTexture(imageNamed: "goblinAttack"), resize: true)
                let wait = SKAction.wait(forDuration: 0.5)
                
                let runAttack = SKAction.run { [weak self] in
                    self?.attack(target: attackTarget)
                }
                let sequence = SKAction.sequence([frame1, wait, frameAttack, runAttack, wait])
                
                self.attackAction = SKAction.repeatForever(sequence)
                run(attackAction, withKey: "animation")
                
                let distance = abs(self.position.x - player.worldPosition.x)
                
                if distance < 30 && self.moveSpeed > 250.0 {
                    self.moveSpeed = 250.0
                    //print("first one! player MOve speed: ", GameManager.shared.playerMoveSpeed)
                }

                walkToTarget(objective: attackTarget)
                    
                    
                
            } else {
                
                
                physicsBody.velocity = CGVector(dx: 0, dy: physicsBody.velocity.dy)
                // This is your existing stationary attack loop.
                let frame1 = SKAction.setTexture(SKTexture(imageNamed: "goblinIdle"), resize: true)
                let frameAttack = SKAction.setTexture(SKTexture(imageNamed: "goblinAttack"), resize: true)
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
                self.texture = SKTexture(imageNamed: "goblinIdle")
                
           // }
            
        case .tossed:
            // Lazily creates the action the first time its needed
            if tossedAction == nil {
                let tossedFrames = [SKTexture(imageNamed: "goblinLaunched")]
                tossedAction = SKAction.repeatForever(SKAction.animate(with: tossedFrames, timePerFrame: 0.25, resize: true, restore: false))
            }
            run(tossedAction, withKey: "animation")
        
        case .dying:
            print("")
            
        }
        
        currentState = newState
    }
    
    func calculateChasingSpeed(input: CGFloat) -> CGFloat {
        let growthRate: CGFloat = 100.0
        return 250 * (1 - 1 / (input / growthRate + 1))
    }


    // In EnemyNode.swift

    func getTossed(by rockPiece: RockPiece, bypassVelocityCheck: Bool = false, isQuickStrike: Bool = false, attackType: AttackType? = .direct) {
        if currentState == .dying { return }
        
        guard let enemyBody = self.physicsBody, let rockBody = rockPiece.physicsBody else { return }
        
        
        
        // --- Blocker Resistance Logic ---
        if self.enemyType == .blocker && attackType != .splash && self.shield == true{
            //print("Attack blocked!")
            // 1. Get the parent boulder from the rock piece that hit.
            if let boulder = rockPiece.parentBoulder, let boulderBody = boulder.physicsBody {
                
                // 1. Determine the direction based on which side the boulder hit from.
                        let bounceDirection: CGFloat = (boulder.position.x < self.position.x) ? -1.0 : 1.0
                        
                        // 2. Define a fixed bounce-back force.
                        let bounceForce: CGFloat = 2000.0 // You can tune this value
                        let bounceBackImpulse = CGVector(dx: bounceForce * bounceDirection, dy: 50)
                        
                        // 3. Stop the boulder and apply the bounce.
                        boulderBody.velocity = .zero
                        boulderBody.applyImpulse(bounceBackImpulse)
            }
            // Optionally, play a "clink" sound or particle effect here
            return // Exit the function, ignoring the attack
        }

//        let velocityThreshold: CGFloat = 25.0
//        guard rockBody.velocity.dx.magnitude > velocityThreshold || rockBody.velocity.dy.magnitude > velocityThreshold else {
//            return
//        }
        
        // If the bypass is false (for normal collisions), perform the velocity check.
        // bypass is true when an attack is made and the enemy is already touching the boulder
        if !bypassVelocityCheck {
            let velocityThreshold: CGFloat = 25.0
            guard rockBody.velocity.dx.magnitude > velocityThreshold || rockBody.velocity.dy.magnitude > velocityThreshold else {
                return
            }
        }
        

        
        
        // The justTossed flag is still good to have for when the launch works.
        justTossed = true
        let wait = SKAction.wait(forDuration: 0.2)
        let resetFlag = SKAction.run { [weak self] in
            self?.justTossed = false
        }
        run(SKAction.sequence([wait, resetFlag]))

        let finalImpulse: CGVector
        var damageToDeal = 0
        
        // STRONG ATTACK
        if rockPiece.isAttached && !isQuickStrike, let boulder = rockPiece.parentBoulder, let boulderBody = boulder.physicsBody {
            let attachedCount = boulder.pieces.filter { $0.isAttached }.count
            
            if self.enemyType == .littleRat && attackType == .direct && Int.random(in: 1...10) <= 9 {
                // Pass the player to the dodge function
                performDodge()
                return // Exit the function, ignoring the attack
            }
            setAnimationState(to: .tossed)
            let powerMultiplier: CGFloat
            switch attachedCount {
            case 4:
                powerMultiplier = 1.3
                damageToDeal = GameManager.shared.fullBoulderDamage
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

        } else { // QUICK ATTACK
            // SINGLE PIECE hit - also needs more force, but less than a full boulder.
            //print("Light attack!")
            damageToDeal = GameManager.shared.quickStrikeDamage
            setAnimationState(to: .tossed)
            
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
        
        //print("damage to deal before bonus: \(damageToDeal)")
        
        let damageWithSizeBonus = CGFloat(damageToDeal) * GameManager.shared.sizeMultiplier
        //print("size Multiplier: \(GameManager.shared.sizeMultiplier)")
        damageToDeal = Int(damageWithSizeBonus)
        //print("damage to deal after bonus: \(damageToDeal)")

        enemyBody.applyImpulse(finalImpulse)
        takeDamage(amount: damageToDeal, contactPoint: self.position, largeStrike: rockPiece.isAttached)
        
        
    }

    // The function now accepts the position of the boulder that is launching it.
    func launchFromBelow(boulderPosition: CGPoint) {
        // Only launch if not already in the air
        guard currentState != .tossed && currentState != .dying else { return }
        
        let launchActions = SKAction.run { [weak self] in
            guard let self = self else { return }
            
            self.setAnimationState(to: .tossed)
            self.takeDamage(amount: 5, contactPoint: self.position)

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
    
    
//    // --- REPLACE this function ---
//    func moveTowardsNEW(objective: PlayerNode) {
//        // The "Brain" of the enemy.
//        if currentState == .tossed || currentState == .dying { return }
//        guard let physicsBody = self.physicsBody else { return }
//        
//        let distance = abs(self.position.x - objective.worldPosition.x)
//        
//        // If the player is in range, the enemy's only job is to attack.
//        if distance <= GameManager.shared.enemyAttackRange {
//            setAnimationState(to: .attacking, target: objective)
//            // Stop moving to perform the attack.
//            physicsBody.velocity = CGVector(dx: 0, dy: physicsBody.velocity.dy)
//            
//            
//        } else {
//            // If the player is out of range, the enemy's only job is to walk.
//            setAnimationState(to: .walking)
//            let direction: CGFloat = (objective.worldPosition.x < self.position.x) ? -1.0 : 1.0
//            self.xScale = (direction < 0) ? -abs(self.xScale) : abs(self.xScale)
//            physicsBody.velocity = CGVector(dx: moveSpeed * direction, dy: physicsBody.velocity.dy)
//        }
//    }

    func moveTowardsOLD(objective: PlayerNode) {
        
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
    
    func moveTowards(objective: Damageable) {
        if currentState == .tossed || currentState == .dying { return }
        
        // --- THE FIX: The enemy now checks its path before moving ---
        var targetX: CGFloat
        if let player = objective as? PlayerNode {
            // If yes, use its special worldPosition property.
            targetX = player.worldPosition.x
        } else {
            // 2. Otherwise (its an SKNode), use its normal position.
            targetX = objective.position.x
        }
        
        // 1. Check if a pillar is blocking the path to the player.
        if let blockingPillar = isPathToTargetBlocked(byPillar: objective) {
            //print("path is blocked")
            // If the path is blocked, attack the pillar instead.
            // We can reuse the 'attacking' state, but we need a way to attack non-player nodes.
            // For now, we'll just stop the enemy in front of the pillar.
            
            // 1. Get the widths of the two objects.
            let pillarWidth = blockingPillar.rectangle.size.width
                let enemyWidth = self.size.width
//            print("pillarWidth",pillarWidth)
//            print("enemyWIdth", enemyWidth)
            // 2. Calculate the distance between their centers.
            let centerToCenterDistance = abs(self.position.x - blockingPillar.position.x)

            // 3. Subtract half of each object's width to get the distance between their edges.
            let distanceToPillarEdge = centerToCenterDistance - (pillarWidth / 2) - (enemyWidth / 2)
            
            let distanceToPillar = abs(self.position.x - blockingPillar.position.x)
//            print("distance to pillar: ", distanceToPillar)
//            print("stopping distance: ", stoppingDistance)
//            print("distance to pillarEDge: ", distanceToPillarEdge)
//            print("stopping distance: ", stoppingDistance)
//            print("distanceToPillarEdge <= stoppingDistance = ", distanceToPillarEdge <= stoppingDistance)
            if distanceToPillarEdge <= stoppingDistance {
                // Stop and attack the pillar (we can add a dedicated attack later)
                
                //print("within distance and set to attacking!")
                setAnimationState(to: .attacking, target: blockingPillar)
                physicsBody?.velocity = CGVector(dx: 0, dy: physicsBody?.velocity.dy ?? 0)
                
            } else {
                // Walk towards the pillar
                setAnimationState(to: .walking)
                walkToTarget(objective: blockingPillar)
            }
            
        } else {
            // 2. If the path is clear, use the normal logic to chase the player.
            
            let distance = abs(self.position.x - targetX)
            if distance <= stoppingDistance {
                setAnimationState(to: .attacking, target: objective)
            } else {
                setAnimationState(to: .walking)
                walkToTarget(objective: objective)
            }
        }
    }
    
//    func walkToTarget(objective: PlayerNode) {
//        guard let physicsBody = self.physicsBody else { return }
//        let direction: CGFloat = (objective.worldPosition.x < self.position.x) ? -1.0 : 1.0
//        
//        self.xScale = (direction < 0) ? -abs(self.xScale) : abs(self.xScale)
//        physicsBody.velocity = CGVector(dx: moveSpeed * direction, dy: physicsBody.velocity.dy)
//    }
    
    // In EnemyNode.swift

    func walkToTarget(objective: SKNode) {
        guard let physicsBody = self.physicsBody else { return }
        
        // --- THE FIX: Get the correct target position based on the node's type ---
        let targetX: CGFloat
        
        // 1. Check if the objective is a PlayerNode.
        if let player = objective as? PlayerNode {
            // If yes, use its special worldPosition property.
            targetX = player.worldPosition.x
        } else {
            // 2. Otherwise (its an SKNode), use its normal position.
            targetX = objective.position.x
        }
        
        // 3. Use the corrected targetX for the direction calculation.
        let direction: CGFloat = (targetX < self.position.x) ? -1.0 : 1.0
        
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
        
        self.originalFriction = self.physicsBody?.friction ?? 0.5
        
        physicsBody?.collisionBitMask = PhysicsCategory.ground | PhysicsCategory.wall | PhysicsCategory.edge | PhysicsCategory.pillar//| PhysicsCategory.rockPiece
        physicsBody?.contactTestBitMask = PhysicsCategory.player | PhysicsCategory.bullet | PhysicsCategory.ground | PhysicsCategory.boulder | PhysicsCategory.pillar
    }
    
    
    /// Checks if a pillar is blocking the path to a target.
    /// - Parameter target: The node the enemy is trying to see (the player).
    /// - Returns: The PillarNode that is blocking the path, or nil if the path is clear.
    func isPathToTargetBlocked(byPillar target: SKNode) -> PillarNode? {
        // 1. Safely get the scene so we can access its nodes.
        guard let gameScene = self.scene as? GameScene else { return nil }

        // 2. Get the x-position of the enemy and its target.
        let enemyX = self.position.x
        let targetX: CGFloat
        if let player = target as? PlayerNode {
            targetX = player.worldPosition.x
        } else {
            targetX = target.position.x
        }

        // 3. Find all pillars that are between the enemy and the target.
        var potentialBlockers: [PillarNode] = []
        for node in gameScene.worldNode.children {
            if let pillar = node as? PillarNode {
                let pillarX = pillar.position.x
                // Check if the pillar's x-position is between the enemy and the target.
                let isBetween = (pillarX > enemyX && pillarX < targetX) || (pillarX < enemyX && pillarX > targetX)
                
                if isBetween {
                    // We will also do a simple height check. If the enemy is significantly higher
                    // than the pillar, we can assume they have a clear line of sight over it.
                    // This prevents enemies from getting stuck on very short pillars.
                    let enemyBottom = self.position.y - (self.size.height / 2)
                    let pillarTop = pillar.position.y + (pillar.rectangle.size.height / 2)
                    
                    if enemyBottom < pillarTop {
                        potentialBlockers.append(pillar)
                    }
                }
            }
        }

        // 4. If there are no potential blockers, the path is clear.
        guard !potentialBlockers.isEmpty else { return nil }

        // 5. If there are multiple blocking pillars, find and return the one closest to the enemy.
        var closestPillar: PillarNode?
        var minDistance = CGFloat.greatestFiniteMagnitude

        for pillar in potentialBlockers {
            let distance = abs(self.position.x - pillar.position.x)
            if distance < minDistance {
                minDistance = distance
                closestPillar = pillar
            }
        }
        
        return closestPillar
    }
    
    private func addDebugAttackRange() {
        let attackRange = GameManager.shared.enemyAttackRange
        
        let circle = SKShapeNode(circleOfRadius: stoppingDistance)
        circle.strokeColor = .red
        circle.lineWidth = 2
        circle.fillColor = .red.withAlphaComponent(0.2)
        circle.zPosition = -1 // Draw it behind the enemy
        addChild(circle)
    }


    
    
}


// In EnemyNode.swift (or a new file for extensions)

// A helper extension to perform the line-circle intersection test.
extension CGPath {
    static func lineSegment(start: CGPoint, end: CGPoint, intersectsCircle circleCenter: CGPoint, radius: CGFloat) -> Bool {
        let dx = end.x - start.x
        let dy = end.y - start.y
        let a = dx*dx + dy*dy
        let b = 2 * (dx * (start.x - circleCenter.x) + dy * (start.y - circleCenter.y))
        let c = (start.x - circleCenter.x)*(start.x - circleCenter.x) + (start.y - circleCenter.y)*(start.y - circleCenter.y) - radius*radius
        
        var discriminant = b*b - 4*a*c
        if discriminant < 0 {
            return false
        }
        
        discriminant = sqrt(discriminant)
        let t1 = (-b - discriminant) / (2*a)
        let t2 = (-b + discriminant) / (2*a)
        
        return (t1 >= 0 && t1 <= 1) || (t2 >= 0 && t2 <= 1)
    }
}
