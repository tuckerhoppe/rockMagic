//
//  GameOverNode.swift
//  RockMagic
//
//  Created by Tucker Hoppe on 7/23/25.
//

import Foundation
// In GameOverNode.swift

import SpriteKit

class GameOverNode: SKNode {

    // --- Initializer ---
    init(size: CGSize, score: Int) {
        super.init()
        
        // Create a semi-transparent background
        let background = SKSpriteNode(color: .black.withAlphaComponent(0.8), size: size)
        background.position = .zero
        addChild(background)
        
        // --- Menu Content ---
        let titleLabel = SKLabelNode(fontNamed: "Menlo-Bold")
        titleLabel.text = "Game Over"
        titleLabel.fontSize = 60
        titleLabel.fontColor = .red
        titleLabel.position = CGPoint(x: 0, y: 80)
        addChild(titleLabel)
        
        let scoreLabel = SKLabelNode(fontNamed: "Menlo-Regular")
        scoreLabel.text = "Final Score: \(score)"
        scoreLabel.fontSize = 40
        scoreLabel.fontColor = .white
        scoreLabel.position = CGPoint(x: 0, y: 30)
        addChild(scoreLabel)
        
        let restartButton = SKLabelNode(fontNamed: "Menlo-Bold")
        restartButton.text = "Restart"
        restartButton.fontSize = 40
        restartButton.fontColor = .cyan
        restartButton.position = CGPoint(x: 0, y: -50)
        restartButton.name = "restartButton" // Use the same name as in the pause menu
        addChild(restartButton)
        
        let exitButton = SKLabelNode(fontNamed: "Menlo-Bold")
        exitButton.text = "Main Menu"
        exitButton.fontSize = 40
        exitButton.fontColor = .cyan
        exitButton.position = CGPoint(x: 0, y: -110)
        exitButton.name = "exitButton" // Use the same name as in the pause menu
        addChild(exitButton)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
