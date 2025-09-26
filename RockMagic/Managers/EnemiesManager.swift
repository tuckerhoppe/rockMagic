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
    
    // This array will hold all the active enemy bases in the level.
    var spawnerNodes: [EnemyBaseNode] = []
    
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
    
    /// Randomly selects an enemy type based on a defined set of weights.
    /// - Returns: The chosen EnemyType.
    private func getRandomEnemyType(normal: Int = 50, littleRat: Int = 20, bigBoy: Int = 20, blocker: Int = 10) -> EnemyType {
        // 1. Define the spawn chance for each enemy.
        //    These numbers don't have to add up to 100, they are just "weights".
        
        
//        print(normal)
//        print(littleRat)
//        print(bigBoy)
//        print(blocker)
        
        let enemyWeights: [(type: EnemyType, weight: Int)] = [
            (.littleRat, littleRat), // 30% chance
            (.bigBoy,    bigBoy), // 20% chance
            (.blocker,   blocker), // 20% chance
            (.normal,    normal)  // 30% chance
        ]

        // 2. Calculate the total weight.
        let totalWeight = enemyWeights.reduce(0) { $0 + $1.weight }
        
        // 3. Roll the dice.
        var randomRoll = Int.random(in: 1...totalWeight)
        
        // 4. Find the winner.
        for enemy in enemyWeights {
            randomRoll -= enemy.weight
            if randomRoll <= 0 {
                return enemy.type
            }
        }
        
        // As a fallback, return a normal enemy.
        return .normal
    }
    
    // In EnemiesManager.swift

    /// The single, unified function for spawning enemies.
    /// It correctly handles the logic for different game modes.
    func spawnEnemyAtEdges(for gameMode: gameMode) {
        // 1. Check the max enemy count (this is the same for all modes).
        guard enemies.count < GameManager.shared.maxEnemyCount else { return }
        
//        // 2. Determine the enemy type randomly (also the same for all modes).
//        let enemyTypeRoll = Int.random(in: 1...13)
//        var chosenType: EnemyType = .normal
//        if enemyTypeRoll <= 4 { chosenType = .littleRat }
//        else if enemyTypeRoll <= 5 { chosenType = .bigBoy }
//        else if enemyTypeRoll <= 7 { chosenType = .blocker }
        
        let chosenType: EnemyType = getRandomEnemyType()
        let enemy = EnemyNode(type: chosenType)
        
        enemy.primaryObjective = determineObjective(for: gameMode)
        
        // for spawning at a random spot on the map
//        let randomX = CGFloat.random(in: enemy.size.width/2...(scene.size.width - enemy.size.width/2))
//        enemy.position = CGPoint(x: randomX, y: scene.frame.midY + 100)
//        enemy.physicsBody?.affectedByGravity = true

        
        
             
        // Calculate the width of the entire world.
        let worldWidth = scene.size.width * 3
        let spawnX: CGFloat
        
        // Randomly choose to spawn on the left or right side.
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
    
    func spawnEnemyFromBases(for gameMode: gameMode) {
        
        // Spawn an enemy at each Spawner Node
        for spawner in spawnerNodes {
            // 1. Check the max enemy count (this is the same for all modes).
            guard enemies.count < GameManager.shared.maxEnemyCount else { return }
            guard spawner.destroyed == false else { continue }
            
//            // 2. Determine the enemy type randomly (also the same for all modes).
//            let enemyTypeRoll = Int.random(in: 1...13)
//            var chosenType: EnemyType = .normal
//            if enemyTypeRoll <= 4 { chosenType = .littleRat }
//            else if enemyTypeRoll <= 5 { chosenType = .bigBoy }
//            else if enemyTypeRoll <= 7 { chosenType = .blocker }
            
            // Choose type based on weights from each individual spawner
            let chosenType: EnemyType = getRandomEnemyType(normal: spawner.normal, littleRat: spawner.littleRat, bigBoy: spawner.bigBoy, blocker: spawner.blocker)
            let enemy = EnemyNode(type: chosenType)
            
            // Determine objective based on game mode
            enemy.primaryObjective = determineObjective(for: gameMode)
            
            // Place enemy at spawner
            enemy.position = spawner.position
            
            // Actually spawn enemy
            enemy.physicsBody?.affectedByGravity = true
            scene.worldNode.addChild(enemy)
            enemies.append(enemy)
        }
        
        
    }
    
    func determineObjective(for gameMode: gameMode) -> Damageable? {
        switch gameMode {
        case .survival, .attack:
            // In survival mode, the enemy's objective is always the player.
            return scene.player
            
        case .defense:
            // In defense mode, we use the 70/30 split.
            if let objective = self.objective, Int.random(in: 1...10) <= 3 {
                return scene.player // 30% chance to target the hut
                //print("spawned enemy with objective: player")
            } else {
                return objective // 70% chance to target the player
                //print("spawned enemy with objective: boulderHut")
            }
        }
    }
    
    func beginSpawning(every interval: TimeInterval = 2.0, gameMode: gameMode) {
        
        switch gameMode {
        case .survival:
            let spawnAction = SKAction.run { [weak self] in
                self?.spawnEnemyAtEdges(for: gameMode)
            }

            let wait = SKAction.wait(forDuration: interval)
            let sequence = SKAction.sequence([spawnAction, wait])
            let repeating = SKAction.repeatForever(sequence)
            scene.run(repeating, withKey: "spawnEnemies")
            
        case .defense, .attack:
            let spawnAction = SKAction.run { [weak self] in
                self?.spawnEnemyFromBases(for: gameMode)
            }

            let wait = SKAction.wait(forDuration: interval)
            let sequence = SKAction.sequence([spawnAction, wait])
            let repeating = SKAction.repeatForever(sequence)
            scene.run(repeating, withKey: "spawnEnemies")
        }
        
    }
    
    func beginSpawningFromBases(every interval: TimeInterval = 2.0, gameMode: gameMode) {
        let spawnAction = SKAction.run { [weak self] in
            self?.spawnEnemyFromBases(for: gameMode)
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
        
        spawnerNodes.removeAll { $0.parent == nil }
        
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
