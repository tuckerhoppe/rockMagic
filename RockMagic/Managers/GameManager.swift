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
    
    // 1. The Singleton: A single, shared instance of the class
    static let shared = GameManager()
    // --- ADD THIS LINE ---
    // We need a weak reference to the scene so we can add nodes to it.
    weak var scene: GameScene?
    
    // =================================================================
    // MARK: - Static Game Variables (Core Game Feel)
    // =================================================================
    // These define the fundamental feel of the game and rarely change.
    
    // In GameManager.swift

    // The range at which the enemy will continue walking while attacking.
    let enemyWalkAttackRange: CGFloat = 125.0
    // The closer range at which the enemy will stop to attack a stationary player.
    let enemyStopAttackRange: CGFloat = 75.0
    
    /// The player's Variables
    let playerMoveSpeed: CGFloat = 3.0
    let playerFriction: CGFloat = 0.5
    // --- The Computed Properties ---
    var centerScreenArea: CGFloat {
        return playerMoveSpeed + 1// 30 points above the ground
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
    // MARK: - Dynamic Game Variables (Difficulty Scaling)
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

    
    // =================================================================
    // MARK: - Upgradable Game Variables (Player Progression)
    // =================================================================
    // These values could be changed by a future shop or upgrade system.
    
    /// The player's maximum health.
    var playerMaxHealth: Int = 100
    
    /// The base horizontal force of a full boulder launch.
    //var boulderLaunchForce: CGFloat = 3000.0
    
    /// The base damage of a single, quick-strike rock piece.
    var rockPieceDamage: Int = 80
    
    /// The base damage of a full boulder impact (can be scaled by size).
    var fullBoulderDamage: Int = 60
    var twoThirdBoulderDamage: Int = 30
    var oneThirdBoulderDamage: Int = 25
    
    var rockPieceBaseKnockback: CGFloat = 30.0
    var boulderBaseKnockback: CGFloat = 30.0
    var boulderVertKnockback: CGFloat = 20.0
    
    var launchEnemyFromBelowX: CGFloat = 45.0
    var launchEnemyFromBelowY: CGFloat = 45.0
    var playerJumpHeight: CGFloat = 50.0
    
    // --- Difficulty Progression ---
    private var gameTime: TimeInterval = 0
    private var timeSinceLastDifficultyIncrease: TimeInterval = 0
    private let timeToIncreaseDifficulty: TimeInterval = 15 // Increase difficulty every 15 seconds
    
    // --- Health Pickup Spawning ---
    /// A flag to ensure only one health pickup exists at a time.
    var isHealthPickupActive = false
    /// The time between health pickup spawn attempts.
    let healthPickupSpawnInterval: TimeInterval = 10.0 // Every 10 seconds
    private var timeSinceLastHealthSpawn: TimeInterval = 0
    
    
    // Private init to ensure no other instances can be made
    private init() {}
    
    // This function is called every frame from your GameScene.
    func update(deltaTime: TimeInterval) {
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

    
    private func increaseDifficulty() {
        print("--- Difficulty Increased! ---")
        
        // Increment the difficulty level counter each time this function runs
        difficultyLevel += 1
        
        // Increase enemy health by 10%
        let newHealth = Double(enemyHealth) * 1.10
        enemyHealth = Int(newHealth.rounded())
        
        enemyMoveSpeed *= 1.05
       
        
        // Increase enemy damage by 8%
        enemyDamage = Int(Double(enemyDamage) * 1.08)
        
        // Only add a new enemy every OTHER difficulty increase (every 30 seconds)
        if difficultyLevel % 2 == 0 {
            maxEnemyCount += 1
            print("Max enemy count increased to: \(maxEnemyCount)")
        }
        
        // As difficulty increases, reduce the time between enemy spawns by 5%.
        // A smaller interval means a higher spawn rate, increasing pressure on the player.
        // The 'if' statement prevents the interval from becoming too short.
        if enemySpawnInterval > 1.0 { // Don't let it get too fast
            enemySpawnInterval *= 0.95 // Make spawns 5% faster
        }
                
        print("New Enemy Health: \(enemyHealth)")
        print("Max Enemy Count: \(maxEnemyCount)")
        // You can add more changes here, like increasing enemy damage or spawn rate.
    }
    
    // A function to reset the game state if needed
    func reset() {
        gameTime = 0
        timeSinceLastDifficultyIncrease = 0
        timeSinceLastHealthSpawn = 0
        isHealthPickupActive = false
        enemyHealth = 100 // Reset to base value
        maxEnemyCount = 1 // 1 <-- ADD THIS LINE
        enemyDamage = 2
        enemySpawnInterval = 3.0
        enemyMoveSpeed = 100.0 // was 100
    }
}
