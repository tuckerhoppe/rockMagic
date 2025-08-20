//
//  ViewUpgradesNode.swift
//  RockMagic
//
//  Created by Tucker Hoppe on 8/15/25.
//

// In ViewUpgradesNode.swift

import SpriteKit

class ViewUpgradesNode: SKNode {

    init(size: CGSize) {
        super.init()
        
        let background = SKSpriteNode(color: .black.withAlphaComponent(0.8), size: size)
        background.position = .zero
        addChild(background)
        
        let titleLabel = SKLabelNode(fontNamed: "Menlo-Bold")
        titleLabel.text = "Current Upgrades"
        titleLabel.fontSize = 48
        titleLabel.fontColor = .yellow
        titleLabel.position = CGPoint(x: 0, y: size.height / 2 - 80)
        addChild(titleLabel)
        
        let cardContainer = SKNode()
        addChild(cardContainer)
        
        // --- Create the 6 Upgrade Cards (this is the same UI code) ---
        let gm = GameManager.shared
        let cardSize = CGSize(width: 200, height: 120)
        
        // Create all 6 cards just like in UpgradeMenuNode...
        // Left Column
        let quickAttackCard = createUpgradeCard(size: cardSize, title: "Quick Attack", level: gm.quickAttackLevel,  imageName: "strike")
        quickAttackCard.position = CGPoint(x: -cardSize.width - 20, y: 90)
        cardContainer.addChild(quickAttackCard)
        
        let boulderSizeCard = createUpgradeCard(size: cardSize, title: "Boulder Size", level: gm.boulderSizeLevel, imageName: "rockTop")
        boulderSizeCard.position = CGPoint(x: -cardSize.width - 20, y: -50)
        cardContainer.addChild(boulderSizeCard)
        
        // Middle Column
        
        let strongAttackCard = createUpgradeCard(size: cardSize, title: "Strong Attack", level: gm.strongAttackLevel,  imageName: "Player_LargeStrike")
        strongAttackCard.position = CGPoint(x: 0, y: 90)
        cardContainer.addChild(strongAttackCard)
        
        
        let staminaCard = createUpgradeCard(size: cardSize, title: "Placeholder", level: gm.staminaLevel, imageName: "greenGem")
        staminaCard.position = CGPoint(x: 0, y: -50)
        cardContainer.addChild(staminaCard)
        
        
        // Right column
        
        let splashAttackCard = createUpgradeCard(size: cardSize, title: "Splash Attack", level: gm.splashAttackLevel,  imageName: "kick")
        splashAttackCard.position = CGPoint(x: cardSize.width + 20, y: 90)
        cardContainer.addChild(splashAttackCard)
        
        let healthCard = createUpgradeCard(size: cardSize, title: "Max Health", level: gm.healthLevel, imageName: "health")
        healthCard.position = CGPoint(x: cardSize.width + 20, y: -50)
        cardContainer.addChild(healthCard)
        // ... etc. for all other cards
        
        // --- Add a Back Button ---
        let backButton = SKLabelNode(fontNamed: "Menlo-Bold")
        backButton.text = "Back"
        backButton.fontSize = 32
        backButton.fontColor = .cyan
        backButton.position = CGPoint(x: 0, y: -size.height / 2 + 80)
        backButton.name = "backToPauseMenuButton" // A new, unique name
        addChild(backButton)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // This is the same helper function, but it doesn't need a 'name' parameter
    private func createUpgradeCard(size: CGSize, title: String, level: Int, imageName: String) -> SKNode {
        let card = SKNode()
        
        let background = SKShapeNode(rectOf: size, cornerRadius: 10)
        background.fillColor = .darkGray
        background.strokeColor = .lightGray
        background.lineWidth = 2
        card.addChild(background)
        
        let titleLabel = SKLabelNode(fontNamed: "Menlo-Regular")
        titleLabel.text = title
        titleLabel.fontSize = 18
        titleLabel.fontColor = .white
        titleLabel.position = CGPoint(x: 0, y: size.height/2 - 25)
        card.addChild(titleLabel)
        
        // --- ADD THIS BLOCK to create the image ---
        let imageSprite = SKSpriteNode(imageNamed: imageName)
        // Scale the image to fit nicely in the card's center
        let imageSize: CGFloat = 40.0
        imageSprite.size = CGSize(width: imageSize, height: imageSize)
        imageSprite.position = CGPoint(x: 0, y: 10) // Position it in the middle
        card.addChild(imageSprite)
        // ------------------------------------------
        
        // Create the 5 stars
        for i in 0..<5 {
            let star = SKLabelNode(fontNamed: "Menlo-Bold")
            star.text = "★"
            star.fontSize = 24
            star.fontColor = (i < level) ? .yellow : .gray
            
            let xPos = -50 + (25 * CGFloat(i))
            star.position = CGPoint(x: xPos, y: -size.height/2 + 25)
            card.addChild(star)
        }
        return card
    }
}
