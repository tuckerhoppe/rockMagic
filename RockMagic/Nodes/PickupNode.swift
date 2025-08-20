//
//  PickupNode.swift
//  RockMagic
//
//  Created by Tucker Hoppe on 7/27/25.
//

import Foundation
import SpriteKit

// An enum to define what the pickup does
enum PickupType {
    case coin
    case fiveCoin
    case health
    case stamina
    case geode
}

class PickupNode: SKSpriteNode {

    let type: PickupType

    init(type: PickupType) {
        self.type = type
        
        // Choose a texture based on the type
        let texture: SKTexture
        switch type {
        case .coin:
            // Replace "Coin_Texture" with your asset name
            texture = SKTexture(imageNamed: "yellowGem")
        case .health:
            // Replace "Health_Texture" with your asset name
            texture = SKTexture(imageNamed: "health")
            
        case .stamina:
            texture = SKTexture(imageNamed: "coin")
            
        case .fiveCoin:
            // Replace "Health_Texture" with your asset name
            texture = SKTexture(imageNamed: "greenGem")
            
        case .geode:
            texture = SKTexture(imageNamed: "greenGeode")
            
        }
        
        super.init(texture: texture, color: .clear, size: texture.size())
        
        self.zPosition = ZPositions.pickups
        self.setScale(0.05)
        setupPhysicsBody()
        
        if type == .coin || type == .fiveCoin {
            self.setScale(0.02)
            // Make the coin pickup disappear after 15 seconds
            let wait = SKAction.wait(forDuration: 15.0)
            let fadeOut = SKAction.fadeOut(withDuration: 0.5)
            let remove = SKAction.removeFromParent()
            run(SKAction.sequence([wait, fadeOut, remove]))
        }
        
        if type == .stamina {
            self.setScale(0.02)
        }
}
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupPhysicsBody() {
        let hitboxSize = CGSize(width: self.size.width * 1.2, height: self.size.height * 1.2)
            self.physicsBody = SKPhysicsBody(rectangleOf: hitboxSize)
        
        self.physicsBody = SKPhysicsBody(circleOfRadius: self.size.width / 2)
        self.physicsBody?.isDynamic = false // It doesn't move
        self.physicsBody?.categoryBitMask = PhysicsCategory.pickup
        
        // It's a "sensor" that doesn't collide with anything
        self.physicsBody?.collisionBitMask = PhysicsCategory.none
        
        // It only needs to detect contact with the player
        self.physicsBody?.contactTestBitMask = PhysicsCategory.player
    }
}
