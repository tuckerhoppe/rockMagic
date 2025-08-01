//
//  Constants.swift
//  RockMagic
//
//  Created by Tucker Hoppe on 4/28/25.
//

import Foundation
import CoreGraphics // For CGFloat

struct Constants {
    struct ZPositions {
        static let background: CGFloat = -100
        static let ground: CGFloat = -50
        static let player: CGFloat = 0
        static let boulder: CGFloat = 10
        static let enemy: CGFloat = 5 // Example: slightly behind player
        static let hud: CGFloat = 100
    }

    // Add structs for Enemy, Boulder constants later
}

struct ZPositions {
    static let background: CGFloat = -100
    static let ground: CGFloat = -50
    static let player: CGFloat = 0
    static let boulder: CGFloat = 10
    static let enemy: CGFloat = 5 // Example: slightly behind player
    static let hud: CGFloat = 100
}
