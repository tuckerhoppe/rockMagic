//
//  ScrollingBackgroundNode.swift
//  RockMagic
//
//  Created by Tucker Hoppe on 4/28/25.
//

import Foundation
import SpriteKit

// Simple version: just displays one background image
class BackgroundNode: SKSpriteNode {

    init(textureName: String) {
        let texture = SKTexture(imageNamed: textureName)
        super.init(texture: texture, color: .clear, size: texture.size())
        self.zPosition = Constants.ZPositions.background
        self.anchorPoint = CGPoint(x: 0, y: 0) // Anchor bottom-left can be easier
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // More complex scrolling logic will be added later, likely managed by GameScene
}
