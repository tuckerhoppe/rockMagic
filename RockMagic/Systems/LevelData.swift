
//
//  LevelData.swift
//  RockMagic
//
//  Created by Tucker Hoppe on 9/24/25.
//

struct LevelData {
    let levelID: Int
    let levelName: String
    let gameMode: gameMode
    let enemySpawnRatios: [EnemyType: Double] // e.g., [.normal: 0.7, .littleRat: 0.3]
    let enemyBases: [EnemyBaseNode]
    let initialEnemyHealth: Int
    // ... other difficulty settings
    let artAssets: ArtAssetSet
    let defendingObjective: Defendable
}

struct ArtAssetSet {
    let background: String
    let ground: String
}


//class LevelDatabase {
//    static let allLevels = [
//        LevelData(levelID: 1, levelName: "The Grassy Plains", gameMode: .survival, ...),
//        LevelData(levelID: 2, levelName: "Defend the Hut!", gameMode: .defense, ...)
//    ]
//}
