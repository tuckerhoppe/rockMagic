//
//  EnemiesManager.swift
//  RockMagic
//
//  Created by Tucker Hoppe on 7/17/25.
//

import Foundation

import SpriteKit

class EnemiesManager {
    unowned let scene: GameScene
    var enemies: [EnemyNode] = []
    
    var objective: Damageable?
    
    init(scene: GameScene) {
        self.scene = scene
    }
    
//    func spawnEnemy() {
//        // Only spawn a new enemy if the current count is less than the max allowed.
//        guard enemies.count < GameManager.shared.maxEnemyCount else { return }
//        
//        let enemy = EnemyNode()
//
//        let randomX = CGFloat.random(in: enemy.size.width/2...(scene.size.width - enemy.size.width/2))
//        enemy.position = CGPoint(x: randomX, y: scene.frame.midY + 100)
//        enemy.physicsBody?.affectedByGravity = true
//
//        scene.worldNode.addChild(enemy)
//        enemies.append(enemy)
//        
//        //print("Enemy spawned at position: \(enemy.position)")
//    }
    
    // In EnemiesManager.swift

//    func spawnEnemy() {
//        // Only spawn a new enemy if the current count is less than the max allowed.
//        guard enemies.count < GameManager.shared.maxEnemyCount else { return }
//        
//        // --- THE FIX: The random logic now lives here ---
//        // 1. Roll the dice to determine the enemy type.
//        let enemyTypeRoll = Int.random(in: 1...13)
//        var chosenType: EnemyType = .normal
//        
//        if enemyTypeRoll <= 4 {
//            chosenType = .littleRat
//        } else if enemyTypeRoll <= 5 {
//            chosenType = .bigBoy
//        } else if enemyTypeRoll <= 7 {
//            chosenType = .blocker
//        }
//        
//        // 2. Create an enemy of that specific type.
//        let enemy = EnemyNode(type: chosenType)
//        // ---------------------------------------------
//
//        let randomX = CGFloat.random(in: enemy.size.width/2...(scene.size.width - enemy.size.width/2))
//        enemy.position = CGPoint(x: randomX, y: scene.frame.midY + 100)
//        enemy.physicsBody?.affectedByGravity = true
//
//        scene.worldNode.addChild(enemy)
//        enemies.append(enemy)
//    }
    
    // In EnemiesManager.swift

    /// The single, unified function for spawning enemies.
    /// It correctly handles the logic for different game modes.
    func spawnEnemy(for gameMode: gameMode) {
        // 1. Check the max enemy count (this is the same for all modes).
        guard enemies.count < GameManager.shared.maxEnemyCount else { return }
        
        // 2. Determine the enemy type randomly (also the same for all modes).
        let enemyTypeRoll = Int.random(in: 1...13)
        var chosenType: EnemyType = .normal
        if enemyTypeRoll <= 4 { chosenType = .littleRat }
        else if enemyTypeRoll <= 5 { chosenType = .bigBoy }
        else if enemyTypeRoll <= 7 { chosenType = .blocker }
        
        let enemy = EnemyNode(type: chosenType)
        
        // 3. --- THIS IS THE KEY ---
        //    Use a switch statement to handle the logic that is UNIQUE to each mode.
        switch gameMode {
        case .survival:
            // In survival mode, the enemy's objective is always the player.
            enemy.primaryObjective = scene.player
            
        case .defense:
            // In defense mode, we use the 70/30 split.
            if let objective = self.objective, Int.random(in: 1...10) <= 3 {
                enemy.primaryObjective = scene.player // 30% chance to target the hut
                //print("spawned enemy with objective: player")
            } else {
                enemy.primaryObjective = objective // 70% chance to target the player
                //print("spawned enemy with objective: boulderHut")
            }
        }
        
        
        
        // 4. The rest of the logic is the same for all modes.
//        let randomX = CGFloat.random(in: enemy.size.width/2...(scene.size.width - enemy.size.width/2))
//        enemy.position = CGPoint(x: randomX, y: scene.frame.midY + 100)
//        enemy.physicsBody?.affectedByGravity = true

        
        // --- THE FIX: Spawn at the far left or far right of the world ---
             
        // 4. Calculate the width of the entire world.
        let worldWidth = scene.size.width * 3
        let spawnX: CGFloat
        
        // 5. Randomly choose to spawn on the left or right side.
        if Bool.random() { // 50% chance for right side
            // Position the enemy just inside the right world boundary.
            spawnX = worldWidth / 2 - 100
        } else { // 50% chance for left side
            // Position the enemy just inside the left world boundary.
            spawnX = -worldWidth / 2 + 100
        }
        
        // 6. Set the enemy's position.
        //    We still spawn them high up so they fall into the world.
        enemy.position = CGPoint(x: spawnX, y: 300)
        enemy.physicsBody?.affectedByGravity = true
        scene.worldNode.addChild(enemy)
        enemies.append(enemy)
    }
    
    
    
    func beginSpawning(every interval: TimeInterval = 2.0, gameMode: gameMode) {
        let spawnAction = SKAction.run { [weak self] in
            self?.spawnEnemy(for: gameMode)
        }

        let wait = SKAction.wait(forDuration: interval)
        let sequence = SKAction.sequence([spawnAction, wait])
        let repeating = SKAction.repeatForever(sequence)
        scene.run(repeating, withKey: "spawnEnemies")
    }
    
    
    
    /// Spawns a single enemy of a specific type at a random location.
    /// This function bypasses the normal max enemy count limit.
    func spawnSingleEnemy(type: EnemyType) {
        // 1. Create an enemy of the specified type.
        let enemy = EnemyNode(type: type)

        // 2. Position it at a random spot at the top of the screen.
        let randomX = CGFloat.random(in: enemy.size.width/2...(scene.size.width - enemy.size.width/2))
        enemy.position = CGPoint(x: randomX, y: scene.frame.midY + 100)
        enemy.physicsBody?.affectedByGravity = true

        // 3. Add it to the game world.
        scene.worldNode.addChild(enemy)
        enemies.append(enemy)
    }
    
    func updateEnemies(defaultTarget: SKNode) {
        // Remove any dead enemies from our array so the count is correct.
        enemies.removeAll { $0.scene == nil }
        
        for enemy in enemies {
            
            
            if enemy.currentState == .tossed, let enemyBody = enemy.physicsBody, enemyBody.isResting {
                        enemy.setAnimationState(to: .idle)
                    }
            
            // This catches any "zombie" enemies that have died but haven't been removed.
            if enemy.currentState == .dying, let body = enemy.physicsBody, body.isResting {
                enemy.startDeathSequence()
                // Continue to the next enemy to avoid running moveTowards on a dying node
                continue
            }
            // Move towards your primary objective and if you don't have one use the target parameter
            enemy.moveTowards(objective: enemy.primaryObjective ?? defaultTarget as! any Damageable)
            
            enemy.applyPillarSlideForce()
        }
    }

    func removeAllEnemies() {
        for enemy in enemies {
            enemy.removeFromParent()
        }
        enemies.removeAll()
    }
}
