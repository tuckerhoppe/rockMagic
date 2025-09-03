//
//  Protocols.swift
//  RockMagic
//
//  Created by Tucker Hoppe on 8/26/25.
//
import SpriteKit

/// A protocol for any object in the game that can take damage.
protocol Damageable: SKNode {
    var currentHealth: Int { get set }
    func takeDamage(amount: Int)
}

/// A protocol for any object in the game that can be defended by the player.
/// It must be a physical node in the scene and must be able to take damage.
protocol Defendable: SKNode, Damageable {
    // This protocol doesn't need any extra properties for now,
    // as it inherits everything it needs from SKNode and Damageable.
}
