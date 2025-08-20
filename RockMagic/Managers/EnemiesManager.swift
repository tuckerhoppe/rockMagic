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

    func spawnEnemy() {
        // Only spawn a new enemy if the current count is less than the max allowed.
        guard enemies.count < GameManager.shared.maxEnemyCount else { return }
        
        // --- THE FIX: The random logic now lives here ---
        // 1. Roll the dice to determine the enemy type.
        let enemyTypeRoll = Int.random(in: 1...13)
        var chosenType: EnemyType = .normal
        
        if enemyTypeRoll <= 4 {
            chosenType = .littleRat
        } else if enemyTypeRoll <= 5 {
            chosenType = .bigBoy
        } else if enemyTypeRoll <= 7 {
            chosenType = .blocker
        }
        
        // 2. Create an enemy of that specific type.
        let enemy = EnemyNode(type: chosenType)
        // ---------------------------------------------

        let randomX = CGFloat.random(in: enemy.size.width/2...(scene.size.width - enemy.size.width/2))
        enemy.position = CGPoint(x: randomX, y: scene.frame.midY + 100)
        enemy.physicsBody?.affectedByGravity = true

        scene.worldNode.addChild(enemy)
        enemies.append(enemy)
    }
    
    func beginSpawning(every interval: TimeInterval = 2.0) {
        let spawnAction = SKAction.run { [weak self] in
            self?.spawnEnemy()
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
    
    func updateEnemies(target: SKNode) {
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
            enemy.moveTowards(objective: target as! PlayerNode)
        }
    }

    func removeAllEnemies() {
        for enemy in enemies {
            enemy.removeFromParent()
        }
        enemies.removeAll()
    }
}
