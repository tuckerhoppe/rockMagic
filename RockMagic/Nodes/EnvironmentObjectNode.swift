//
//  EnvironmentObjectNode.swift
//  RockMagic
//
//  Created by Tucker Hoppe on 10/1/25.
//

// In EnvironmentObjectData.swift

import CoreGraphics

// Defines the visual and statistical type of an object
enum EnvironmentObjectType {
    case woodenCrate
    case tree
    case cactus
    case house
}

// Defines how the object interacts with the world
enum EnvironmentObjectInteractionType {
    case background // Decorative, no physics interaction
    case interactable // Can be stood on and destroyed
}

// This is the "blueprint" that will be stored in your LevelData
struct EnvironmentObjectConfiguration {
    let type: EnvironmentObjectType
    let position: CGPoint
    let size: CGSize
    let interactionType: EnvironmentObjectInteractionType
}


// In EnvironmentObjectNode.swift

import SpriteKit

class EnvironmentObjectNode: SKSpriteNode, Damageable {

    // --- Damageable Protocol Requirements ---
    var currentHealth: Int = 100 // Default value
    var maxHealth: Int = 100

    let interactionType: EnvironmentObjectInteractionType

    init(config: EnvironmentObjectConfiguration) {
        self.interactionType = config.interactionType
        var texture: SKTexture?

        // 1. Configure the object based on its type
        switch config.type {
        case .woodenCrate:
            texture = SKTexture(imageNamed: "Crate_Texture")
            self.maxHealth = 50
        case .tree:
            texture = SKTexture(imageNamed: "Tree_Texture")
            self.maxHealth = 100
        case .cactus:
            texture = SKTexture(imageNamed: "Cactus_Texture")
            self.maxHealth = 30
        case .house:
            texture = SKTexture(imageNamed: "House_Texture")
            self.maxHealth = 500
        }
        self.currentHealth = self.maxHealth

        super.init(texture: texture, color: .clear, size: config.size)
        
        // 2. Set position and other properties
        self.position = config.position
        setupPhysicsBody()
    }

    private func setupPhysicsBody() {
        // 3. Setup physics based on the interaction type
        switch interactionType {
        case .background:
            // Background objects have no physics body and are drawn behind the player.
            self.zPosition = ZPositions.background + 1
            self.physicsBody = nil
            
        case .interactable:
            // Interactable objects are solid and can be damaged.
            self.zPosition = ZPositions.ground + 1
            self.physicsBody = SKPhysicsBody(rectangleOf: self.size)
            self.physicsBody?.isDynamic = false // It's a static object
            self.physicsBody?.categoryBitMask = PhysicsCategory.destroyableObject
            // It collides with the player so they can stand on it
            self.physicsBody?.collisionBitMask = PhysicsCategory.player
            // It tests for contact with attacks so it can take damage
            self.physicsBody?.contactTestBitMask = PhysicsCategory.rockPiece | PhysicsCategory.boulder
        }
    }
    
    func takeDamage(amount: Int) {
        guard interactionType == .interactable else { return }

        currentHealth -= amount
        // Add a flash effect or other feedback here
        
        if currentHealth <= 0 {
            destroy()
        }
    }
    
    private func destroy() {
        // Play an explosion effect (e.g., a wood splinter effect for a crate)
        EffectManager.shared.playPillarDestroyedEffect(at: self.position)
        self.removeFromParent()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
