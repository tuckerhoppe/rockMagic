
//
//  LevelData.swift
//  RockMagic
//
//  Created by Tucker Hoppe on 9/24/25.
//

import Foundation
import SpriteKit

struct LevelData {
    let levelID: Int
    let levelName: String
    let levelMessage: String
    let gameMode: gameMode
    let levelWidth: CGFloat
    let timeLimit: TimeInterval
    let enemyBases: [EnemyBaseConfiguration]
    let enemyDifficulty: EnemyDifficulty
    let environmentObjects: [EnvironmentObjectConfiguration]
    let artAssets: ArtAssetSet
    let defendingObjective: DefendableConfiguration?
}

struct DefendableConfiguration {
    let imageName: String
    let maxHealth: Int
    let position: CGPoint
}

struct ArtAssetSet {
    let background: String
    let ground: String
}

struct EnemyDifficulty {
    let enemyHealth: Int
    let enemySpeed: Double
    let enemyDamage: Double
    let enemySpawnInterval: Double
}

struct EnemyBaseConfiguration {
    let position: CGPoint
    let spawnRatios: [EnemyType: Int]
    let canRebuild: Bool
}

class LevelDatabase {
    
    
    static let world1_GrassyPlains: [LevelData] = [
        
        LevelData(
            levelID: -1,
            levelName: "Survival",
            levelMessage: "Survive as long as you can!",
            gameMode: .survival,
            levelWidth: 2250.0,
            timeLimit: 0.0,
            enemyBases: [],
            enemyDifficulty: EnemyDifficulty(enemyHealth: 100, enemySpeed: 1.0, enemyDamage: 1.0, enemySpawnInterval: 3.0),
            environmentObjects: [
                    // A decorative tree in the background
                    EnvironmentObjectConfiguration(
                        type: .tree,
                        position: CGPoint(x: 300, y: GameManager.shared.groundLevel),
                        size: CGSize(width: 150, height: 300),
                        interactionType: .background
                    ),
                    // A destructible crate the player can jump on
                    EnvironmentObjectConfiguration(
                        type: .woodenCrate,
                        position: CGPoint(x: -200, y: GameManager.shared.groundLevel),
                        size: CGSize(width: 60, height: 60),
                        interactionType: .interactable
                    )
                ],
            artAssets: ArtAssetSet(background: "pixelNiceBackground", ground: "pixelatedGround"),
            defendingObjective: nil
        ),
        LevelData(
            levelID: -2,
            levelName: "Defense",
            levelMessage: "Defend the Rock Baby!",
            gameMode: .defense,
            levelWidth: 2250.0,
            timeLimit: 0.0,
            enemyBases: [
                EnemyBaseConfiguration(
                    position: CGPoint(x: -500, y: GameManager.shared.enemyBaseLevel),
                    spawnRatios: [.normal: 100, .littleRat: 00, .bigBoy: 0, .blocker: 0],
                    canRebuild: true
                ),
                EnemyBaseConfiguration(
                    position: CGPoint(x: 500, y: GameManager.shared.enemyBaseLevel),
                    spawnRatios: [.normal: 80, .littleRat: 20, .bigBoy: 0, .blocker: 0],
                    canRebuild: true
                )
                
            ],
            enemyDifficulty: EnemyDifficulty(enemyHealth: 100, enemySpeed: 1.0, enemyDamage: 1.0, enemySpawnInterval: 3.0),
            environmentObjects: [
                    // A decorative tree in the background
                    EnvironmentObjectConfiguration(
                        type: .tree,
                        position: CGPoint(x: 300, y: GameManager.shared.groundLevel),
                        size: CGSize(width: 150, height: 300),
                        interactionType: .background
                    ),
                    // A destructible crate the player can jump on
                    EnvironmentObjectConfiguration(
                        type: .woodenCrate,
                        position: CGPoint(x: -200, y: GameManager.shared.groundLevel),
                        size: CGSize(width: 60, height: 60),
                        interactionType: .interactable
                    )
                ],
            artAssets: ArtAssetSet(background: "pixelNiceBackground", ground: "pixelatedGround"),
            defendingObjective: DefendableConfiguration(imageName: "rockBaby", maxHealth: 300, position: CGPoint(x: 0, y: GameManager.shared.groundLevel))
        ),
        LevelData(
            levelID: -3,
            levelName: "Attack",
            levelMessage: "Destroy the Enemy Bases!",
            gameMode: .attack,
            levelWidth: 2250.0,
            timeLimit: 0.0,
            enemyBases: [
                EnemyBaseConfiguration(
                    position: CGPoint(x: -500, y: GameManager.shared.enemyBaseLevel),
                    spawnRatios: [.normal: 100, .littleRat: 00, .bigBoy: 0, .blocker: 0],
                    canRebuild: false
                ),
                EnemyBaseConfiguration(
                    position: CGPoint(x: 500, y: GameManager.shared.enemyBaseLevel),
                    spawnRatios: [.normal: 80, .littleRat: 20, .bigBoy: 0, .blocker: 0],
                    canRebuild: false
                ),
                EnemyBaseConfiguration(
                    position: CGPoint(x: -900, y: GameManager.shared.enemyBaseLevel),
                    spawnRatios: [.normal: 100, .littleRat: 00, .bigBoy: 0, .blocker: 0],
                    canRebuild: false
                ),
                EnemyBaseConfiguration(
                    position: CGPoint(x: 900, y: GameManager.shared.enemyBaseLevel),
                    spawnRatios: [.normal: 80, .littleRat: 20, .bigBoy: 0, .blocker: 0],
                    canRebuild: false
                )
            ],
            enemyDifficulty: EnemyDifficulty(enemyHealth: 100, enemySpeed: 1.0, enemyDamage: 1.0, enemySpawnInterval: 3.0),
            environmentObjects: [
                    // A decorative tree in the background
                    EnvironmentObjectConfiguration(
                        type: .tree,
                        position: CGPoint(x: 300, y: GameManager.shared.groundLevel),
                        size: CGSize(width: 150, height: 300),
                        interactionType: .background
                    ),
                    // A destructible crate the player can jump on
                    EnvironmentObjectConfiguration(
                        type: .woodenCrate,
                        position: CGPoint(x: -200, y: GameManager.shared.groundLevel),
                        size: CGSize(width: 60, height: 60),
                        interactionType: .interactable
                    )
                ],
            artAssets: ArtAssetSet(background: "pixelNiceBackground", ground: "pixelatedGround"),
            defendingObjective: nil
        ),
        
        // LEVEL 1
        LevelData(
            levelID: 1,
            levelName: "The First Stand",
            levelMessage: "Survive as long as you can!",
            gameMode: .survival,
            levelWidth: 250.0,
            timeLimit: 60.0,
            enemyBases: [
                EnemyBaseConfiguration(
                    position: CGPoint(x: -500, y: GameManager.shared.enemyBaseLevel),
                    spawnRatios: [.normal: 100, .littleRat: 00, .bigBoy: 0, .blocker: 0],
                    canRebuild: false
                ),
                EnemyBaseConfiguration(
                    position: CGPoint(x: 500, y: GameManager.shared.enemyBaseLevel),
                    spawnRatios: [.normal: 80, .littleRat: 20, .bigBoy: 0, .blocker: 0],
                    canRebuild: false
                )
            ],
            enemyDifficulty: EnemyDifficulty(enemyHealth: 100, enemySpeed: 1.0, enemyDamage: 1.0, enemySpawnInterval: 3.0),
            environmentObjects: [
                    // A decorative tree in the background
                    EnvironmentObjectConfiguration(
                        type: .tree,
                        position: CGPoint(x: 300, y: GameManager.shared.groundLevel),
                        size: CGSize(width: 150, height: 300),
                        interactionType: .background
                    ),
                    // A destructible crate the player can jump on
                    EnvironmentObjectConfiguration(
                        type: .woodenCrate,
                        position: CGPoint(x: -200, y: GameManager.shared.groundLevel),
                        size: CGSize(width: 60, height: 60),
                        interactionType: .interactable
                    )
                ],
            artAssets: ArtAssetSet(background: "pixelNiceBackground", ground: "pixelatedGround"),
            defendingObjective: nil
        ),

        // LEVEL 2
        LevelData(
            levelID: 2,
            levelName: "Defend Rock Baby",
            levelMessage: "Defend the Rock Baby!",
            gameMode: .defense,
            levelWidth: 2250.0,
            timeLimit: 90.0,
            enemyBases: [
                EnemyBaseConfiguration(
                    position: CGPoint(x: -500, y: GameManager.shared.enemyBaseLevel),
                    spawnRatios: [.normal: 80, .littleRat: 20, .bigBoy: 0, .blocker: 0],
                    canRebuild: false
                ),
                EnemyBaseConfiguration(
                    position: CGPoint(x: 500, y: GameManager.shared.enemyBaseLevel),
                    spawnRatios: [.normal: 80, .littleRat: 20, .bigBoy: 0, .blocker: 0],
                    canRebuild: false
                )
            ],
            enemyDifficulty: EnemyDifficulty(enemyHealth: 100, enemySpeed: 1.0, enemyDamage: 1.0, enemySpawnInterval: 3.0),
            environmentObjects: [
                    // A decorative tree in the background
                    EnvironmentObjectConfiguration(
                        type: .tree,
                        position: CGPoint(x: 300, y: GameManager.shared.groundLevel),
                        size: CGSize(width: 150, height: 300),
                        interactionType: .background
                    ),
                    // A destructible crate the player can jump on
                    EnvironmentObjectConfiguration(
                        type: .woodenCrate,
                        position: CGPoint(x: -200, y: GameManager.shared.groundLevel),
                        size: CGSize(width: 60, height: 60),
                        interactionType: .interactable
                    )
                ],
            artAssets: ArtAssetSet(background: "pixelNiceBackground", ground: "pixelatedGround"),
            defendingObjective: nil
        ),
        
        // LEVEL 3
        LevelData(
            levelID: 3,
            levelName: "Attack Goblin Camp",
            levelMessage: "Attack the Goblin Camp!",
            gameMode: .attack,
            levelWidth: 2250.0,
            timeLimit: 0.0,
            enemyBases: [
                EnemyBaseConfiguration(
                    position: CGPoint(x: -500, y: GameManager.shared.enemyBaseLevel),
                    spawnRatios: [.normal: 80, .littleRat: 20, .bigBoy: 0, .blocker: 0],
                    canRebuild: false
                ),
                EnemyBaseConfiguration(
                    position: CGPoint(x: 500, y: GameManager.shared.enemyBaseLevel),
                    spawnRatios: [.normal: 80, .littleRat: 20, .bigBoy: 0, .blocker: 0],
                    canRebuild: false
                )
            ],
            enemyDifficulty: EnemyDifficulty(enemyHealth: 100, enemySpeed: 1.0, enemyDamage: 1.0, enemySpawnInterval: 3.0),
            environmentObjects: [
                    // A decorative tree in the background
                    EnvironmentObjectConfiguration(
                        type: .tree,
                        position: CGPoint(x: 300, y: GameManager.shared.groundLevel),
                        size: CGSize(width: 150, height: 300),
                        interactionType: .background
                    ),
                    // A destructible crate the player can jump on
                    EnvironmentObjectConfiguration(
                        type: .woodenCrate,
                        position: CGPoint(x: -200, y: GameManager.shared.groundLevel),
                        size: CGSize(width: 60, height: 60),
                        interactionType: .interactable
                    )
                ],
            artAssets: ArtAssetSet(background: "pixelNiceBackground", ground: "pixelatedGround"),
            defendingObjective: nil
        ),
    ]
}
