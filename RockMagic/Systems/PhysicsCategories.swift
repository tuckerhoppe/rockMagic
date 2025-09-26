//
//  PhysicsCategories.swift
//  RockMagic
//
//  Created by Tucker Hoppe on 4/28/25.
//

import Foundation

// Physics category structure (place this outside the function)
//USE THIS ONE vvv
// In PhysicsCategories.swift

struct PhysicsCategory {
    static let none: UInt32 = 0
    static let player: UInt32    = 0b1      // 1
    static let enemy: UInt32     = 0b10     // 2
    static let bullet: UInt32    = 0b100    // 4
    static let ground: UInt32    = 0b1000   // 8
    static let rockPiece: UInt32 = 0b10000  // 16 (Was conflicting with player)
    static let wall: UInt32      = 0b100000 // 32 (Was conflicting with enemy)
    static let edge: UInt32      = 0b1000000// 64 (Was conflicting with ground)
    static let boulder: UInt32   = 0b10000000   // 128
    static let pickup: UInt32    = 0b100000000  // 256
    static let anchor: UInt32    = 0b1000000000 // 512
    static let pillar: UInt32    = 0b10000000000 // 1024
    static let defendableObject: UInt32 = 0b100000000000 // 2048
    static let destroyableObject: UInt32 = 0b1000000000000 // 4096
    static let all: UInt32       = UInt32.max
}

