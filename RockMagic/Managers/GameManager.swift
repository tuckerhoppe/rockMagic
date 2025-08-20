//
//  GameManager.swift
//  RockMagic
//
//  Created by Tucker Hoppe on 7/22/25.
//

import Foundation

// In GameManager.swift

import Foundation
import CoreGraphics

class GameManager {
    
    static let shared = GameManager()
    weak var scene: GameScene?
    
    // --- Player Progression ---
    var playerLevel: Int = 1
    var currentScore: Int = 0
    var scoreForNextLevel: Int = 15
    // Defines the additional score needed for each subsequent level
    let levelThresholdIncrements = [15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25]
    
    // =================================================================
    // MARK: - Static Game Variables (Core Game Feel)
    // =================================================================
    // These define the fundamental feel of the game and rarely change.
    
    // In GameManager.swift
    //SCORE VALUES
    let normalEnemyValue = 1
    let specialEnemyValue = 2
    let normalGemValue = 1
    let specialGemValue = 5
    

    // The range at which the enemy will continue walking while attacking.
    let enemyWalkAttackRange: CGFloat = 125.0
    // The closer range at which the enemy will stop to attack a stationary player.
    let enemyStopAttackRange: CGFloat = 75.0
    
    /// The player's Variables
    let playerMoveSpeed: CGFloat = 3.0
    let playerFriction: CGFloat = 0.5
    
    var playerStartX: CGFloat = 25
    // --- The Computed Properties ---
    var centerScreenAreaR: CGFloat {
        return playerStartX + playerMoveSpeed + 1// 30 points above the ground
    }
    
    var centerScreenAreaL: CGFloat {
        return playerStartX - playerMoveSpeed - 1// 30 points above the ground
    }
    /// The base vertical force of the player's boulder jump.
    let playerBoulderJumpForce: CGFloat = 100.0
    
    // In GameManager.swift

    // Add these under your other static variables
    let enemyAttackRange: CGFloat = 75.0
    let enemyAttackCooldown: TimeInterval = 1.5 // Attacks once every 1.5 seconds
    
    /// How far the player can summon a boulder from their position.
    let magicBoundaryDistance: CGFloat = 175.0
    let boulderBrakes:CGFloat = 10.0
    let boulderHighlightRadius:CGFloat = 25
    
    let launchBoulderForce:CGFloat = 3500.0 // was 3000.
    let quickStrikeForce:CGFloat = 200.0
    let grabRadius: CGFloat = 50.0
    
    /// Environment height
    // --- The Base Value ---
    let groundY: CGFloat = -125
    let groundHeight: CGFloat = 100 // was 120
    //let groundWidth
    
    
    // --- The Computed Properties ---
    var boulderFinalY: CGFloat {
        return groundY + 1 // 30 points above the ground
    }
    
    // --- The Computed Properties ---
    var groundLevel: CGFloat {
        return groundY + groundHeight / 2// 30 points above the ground
    }
    
    var playerStartY: CGFloat {
        return groundY + 1 // 30 points above the ground
    }
    
    
    /// How close an enemy gets before stopping to attack.
    let enemyStoppingDistance: CGFloat = 25.0
    
    let instructionImages = ["summonBoulderInstructions", "swipeLaunchInstructions", "tapInstructions","coinInstructions", "healthInstructions", "objectiveInstructions"]
    //GameManager.shared
    
    // =================================================================
    // MARK: - Difficulty Scaling
    // =================================================================
    // These values will be modified by your `increaseDifficulty()` function.
    
    private var difficultyLevel = 0
    
    /// The health of newly spawned enemies.
    var enemyHealth: Int = 100
    
    /// The damage dealt by an enemy's attack.
    var enemyDamage: Int = 2
    
    /// The maximum number of enemies allowed on screen at once.
    var maxEnemyCount: Int = 0
    
    /// The movement speed of newly spawned enemies.
    var enemyMoveSpeed: CGFloat = 100.0
    
    /// The time between enemy spawns. A lower number is harder.
    var enemySpawnInterval: TimeInterval = 3.0
    
    let healthIncreaseRate: Double = 1.10
    let enemyMoveSpeedIncreaseRate: Double = 1.05
    let enemyDamageIncreaseAmount: Int = 1

    
    // =================================================================
    // MARK: - Upgradable Game Variables (Player Progression)
    // =================================================================
    // These values could be changed by a future shop or upgrade system.
    
    
    // In GameManager.swift

    // MARK: - Upgrade Levels
    var healthLevel = 0
    var quickAttackLevel = 0
    var strongAttackLevel = 0
    var splashAttackLevel = 0
    var boulderSizeLevel = 0
    var staminaLevel = 0
    let maxUpgradeLevel = 5
    
    
    
    
    /// The player's maximum health.
    var playerMaxHealth: Int = 100
    let healthIncreaseAmount: Int = 55
    
    /// The base damage of a single, quick-strike rock piece.
    var quickStrikeDamage: Int = 60 //was 80
    //var largeStrikeDamage: Int = 60
    var splashAttackDamage: Int = 40
    
    // --- ADD this to your Upgradable Game Variables ---
    var splashAttackRadius: CGFloat = 100.0
    
    /// The base damage of a full boulder impact (can be scaled by size).
    var fullBoulderDamage: Int = 80
    var twoThirdBoulderDamage: Int = 70
    var oneThirdBoulderDamage: Int = 60
    
    var  boulderWidth: Int = 50
    var  boulderHeight: Int = 20
    var sizeMultiplier: CGFloat = 1.0
    
    
    var staminaRegenRate: Int = 2 // Points per second
    
    var rockPieceBaseKnockback: CGFloat = 30.0
    var boulderBaseKnockback: CGFloat = 30.0
    var boulderVertKnockback: CGFloat = 20.0
    
    
    
    var launchEnemyFromBelowX: CGFloat = 45.0
    var launchEnemyFromBelowY: CGFloat = 45.0
    var playerJumpHeight: CGFloat = 50.0

    // --- ADD these under your Upgradable Game Variables ---
    var playerMaxStamina: Int = 100
    let summonBoulderCost: Int = 20
    let launchBoulderCost: Int = 15
    let shootPieceCost: Int = 5
    
    /// The rate at which stamina drains per second while holding a boulder.
    let boulderHoldStaminaDrainRate: CGFloat = 30.0
    
    
    // --- Difficulty Progression ---
    private var gameTime: TimeInterval = 0
    private var timeSinceLastDifficultyIncrease: TimeInterval = 0
    private let timeToIncreaseDifficulty: TimeInterval = 15 // Increase difficulty every 15 seconds
    let healthPickupSpawnInterval: TimeInterval = 10.0 // Every 10 se
    
    // --- Health Pickup Spawning ---
    /// A flag to ensure only one health pickup exists at a time.
    var isHealthPickupActive = false
    /// The time between health pickup spawn attempts.
    private var timeSinceLastHealthSpawn: TimeInterval = 0
    
    
    // Private init to ensure no other instances can be made
    private init() {}
    
    // This function is called every frame from your GameScene.
    func update(deltaTime: TimeInterval) {
        
        // If the tutorial is active, do not increase game time or difficulty.
        guard let scene = self.scene, !scene.isTutorialActive else { return }
        gameTime += deltaTime
        timeSinceLastDifficultyIncrease += deltaTime
        
        if timeSinceLastDifficultyIncrease >= timeToIncreaseDifficulty {
            increaseDifficulty()
            timeSinceLastDifficultyIncrease = 0 // Reset the timer
        }
        
        timeSinceLastHealthSpawn += deltaTime
            
        // Check if it's time to spawn and if a health pack isn't already on the map.
        if timeSinceLastHealthSpawn >= healthPickupSpawnInterval && !isHealthPickupActive {
            spawnHealthPickup()
            timeSinceLastHealthSpawn = 0 // Reset the timer
        }
    }
    
    
    
    private func spawnHealthPickup() {
        guard let scene = self.scene else { return }
        
        print("Spawning health pickup...")
        isHealthPickupActive = true // Set the flag
        
        // Define the spawn area (the width of the world)
        let worldWidth = scene.size.width * 3
        let spawnX = CGFloat.random(in: -worldWidth/2 ... worldWidth/2)
        
        // Create the health pickup
        let healthPickup = PickupNode(type: .health)
        healthPickup.position = CGPoint(x: spawnX, y: 0) // Start at a default y
        
        // Position it on the ground
        healthPickup.position.y = groundY + (healthPickup.size.height / 2)
        
        scene.worldNode.addChild(healthPickup)
    }

    /// Increases the game's difficulty and sets the score for the next level.
    func levelUp() {
        playerLevel += 1
        
        // Update the score needed for the next level from our array
        let thresholdIndex = min(playerLevel - 2, levelThresholdIncrements.count - 1)
        scoreForNextLevel += levelThresholdIncrements[thresholdIndex]
        
        print("--- LEVEL UP! Player is now level \(playerLevel) ---")
        
        print("Next level at: \(scoreForNextLevel) points")
    }
    
    // In GameManager.swift

    

//    func applyUpgrade(_ type: UpgradeType) {
//        switch type {
//        case .health:
//            playerMaxHealth += 20
//            print("Player max health is now \(playerMaxHealth)")
//        case .quickAttack:
//            // 1. Convert the Int to a Double for the calculation.
//            let newDamage = Double(quickStrikeDamage) * 1.2
//            
//            // 2. Convert the result back to an Int, rounding to the nearest whole number.
//            quickStrikeDamage = Int(newDamage.rounded())
//            
//            print("Quick strike damage is now \(quickStrikeDamage)")
//        case .strongAttack:
//            // 1. Convert the Int to a Double for the calculation.
//            let newDamage = Double(largeStrikeDamage) * 1.2
//            
//            // 2. Convert the result back to an Int, rounding to the nearest whole number.
//            largeStrikeDamage = Int(newDamage.rounded())
//            
//            print("Quick strike damage is now \(quickStrikeDamage)")
//        }
//    }
    
    func applyUpgrade(_ type: UpgradeType) {
        switch type {
        case .health:
            if healthLevel < maxUpgradeLevel {
                healthLevel += 1
                playerMaxHealth += healthIncreaseAmount
            }
        case .quickAttack:
            if quickAttackLevel < maxUpgradeLevel {
                quickAttackLevel += 1
                // Add More damage
                let newDamage = Double(quickStrikeDamage) * 1.3
                quickStrikeDamage = Int(newDamage.rounded())
            }
        case .strongAttack:
            if strongAttackLevel < maxUpgradeLevel {
                strongAttackLevel += 1
                
                let newDamage = Double(fullBoulderDamage) * 1.3
                fullBoulderDamage = Int(newDamage.rounded())
                oneThirdBoulderDamage = Int(Double(oneThirdBoulderDamage) * 1.3)
                twoThirdBoulderDamage = Int(Double(twoThirdBoulderDamage) * 1.3)
            }
        case .splashAttack:
            if splashAttackLevel < maxUpgradeLevel {
                splashAttackLevel += 1
                splashAttackDamage = Int(Double(splashAttackDamage) * 1.4)
                splashAttackRadius *= 1.2
            }
        case .stamina:
            if staminaLevel < maxUpgradeLevel {
                staminaLevel += 1
                staminaRegenRate += 2
            }
        case .boulderSize:
            if boulderSizeLevel < maxUpgradeLevel {
                boulderSizeLevel += 1
                boulderWidth += 4
                boulderHeight += 2
                sizeMultiplier += 0.15
            }
        }
        
        // --- ADD THIS BLOCK at the end of the applyUpgrade function ---
        print("""
        --- Current Upgrade Levels ---
        Health:         \(healthLevel)/\(maxUpgradeLevel)
        Quick Attack:   \(quickAttackLevel)/\(maxUpgradeLevel)
        Strong Attack:  \(strongAttackLevel)/\(maxUpgradeLevel)
        Splash Attack:  \(splashAttackLevel)/\(maxUpgradeLevel)
        Boulder Size:   \(boulderSizeLevel)/\(maxUpgradeLevel)
        Stamina Regen:  \(staminaLevel)/\(maxUpgradeLevel)
        ------------------------------
        """)
        print("""
        --- Player Stats Updated ---
        Max Health: \(playerMaxHealth)
        Quick Strike Damage: \(quickStrikeDamage) x \(sizeMultiplier)
        Quick Strike with size bonus\(Float(quickStrikeDamage) * Float(sizeMultiplier))
        Full Boulder Damage: \(fullBoulderDamage)
        Full Boulder with size bonus\(Float(fullBoulderDamage) * Float(sizeMultiplier))
        Splash Attack Damage: \(splashAttackDamage)
        Splash Attack with size bonus\(Float(splashAttackDamage) * Float(sizeMultiplier))
        Boulder Size Damage multiplier(boulder Size): \(sizeMultiplier)
        --------------------------
        """)
        
    }
    
    
//    var fullBoulderDamage: Int = 60
//    var twoThirdBoulderDamage: Int = 30
//    var oneThirdBoulderDamage: Int = 25
    
    private func increaseDifficulty() {
        print("--- Difficulty Increased! ---")
        
        // Increment the difficulty level counter each time this function runs
        difficultyLevel += 1
        
        // Increase enemy health by 10%
        let newHealth = Double(enemyHealth) * healthIncreaseRate
        enemyHealth = Int(newHealth.rounded())
        
        if enemyMoveSpeed < 400{
            enemyMoveSpeed *= enemyMoveSpeedIncreaseRate
        }
        
       
        
        
        
        // Only add a new enemy every OTHER difficulty increase (every 30 seconds)
        if difficultyLevel % 2 == 0 && maxEnemyCount < 20{
            maxEnemyCount += 2
            print("Max enemy count increased to: \(maxEnemyCount)")
            
            
        }
        
        if enemyDamage < 30 {
            enemyDamage += enemyDamageIncreaseAmount
        }
        
        // As difficulty increases, reduce the time between enemy spawns by 5%.
        // A smaller interval means a higher spawn rate, increasing pressure on the player.
        // The 'if' statement prevents the interval from becoming too short.
        if enemySpawnInterval > 0.5 { // Don't let it get too fast
            enemySpawnInterval *= 0.95 // Make spawns 5% faster
        }
                
        print("New Enemy Health: \(enemyHealth)")
        print("Max Enemy Count: \(maxEnemyCount)")
        print("New Enemy Damage: \(enemyDamage)")
        print("New Enemy Speed: \(enemyMoveSpeed)")
        // You can add more changes here, like increasing enemy damage or spawn rate.
    }
    
    /// Resets all player upgrades and their corresponding stats to their default values.
    func resetUpgrades() {
        // Reset upgrade levels
        healthLevel = 0
        quickAttackLevel = 0
        strongAttackLevel = 0
        splashAttackLevel = 0
        boulderSizeLevel = 0
        staminaLevel = 0

        // Reset player and combat stats
        playerMaxHealth = 100
        quickStrikeDamage = 60
        //largeStrikeDamage = 80
        splashAttackDamage = 40
        splashAttackRadius = 100.0
        fullBoulderDamage = 80
        twoThirdBoulderDamage = 70
        oneThirdBoulderDamage = 60
        boulderWidth = 50
        boulderHeight = 20
        staminaRegenRate = 2
        sizeMultiplier = 1.0
    }
    
    // A function to reset the game state if needed
    func reset() {
        gameTime = 0
        timeSinceLastDifficultyIncrease = 0
        timeSinceLastHealthSpawn = 0
        isHealthPickupActive = false
        
        playerLevel = 1
        currentScore = 0
        scoreForNextLevel = 15
        
        enemyHealth = 100 // Reset to base value
        maxEnemyCount = 1 // 1 <-- ADD THIS LINE
        enemyDamage = 2 // was 2
        enemySpawnInterval = 3.0
        enemyMoveSpeed = 100.0 // was 100
        
        // Reset upgrades
        resetUpgrades()
        
        
    }
}


enum UpgradeType {
    case health, quickAttack, strongAttack, splashAttack, stamina, boulderSize
}
