//
//  UpgradeMenuNode.swift
//  RockMagic
//
//  Created by Tucker Hoppe on 8/12/25.
//

// In UpgradeMenuNode.swift

import SpriteKit

class UpgradeMenuNode: SKNode {
    
    private var confirmButton: SKLabelNode!
    private var selectedCardName: String?
    private var cardContainer: SKNode!

    init(size: CGSize) {
        super.init()
        
        let background = SKSpriteNode(color: .black.withAlphaComponent(0.8), size: size)
        background.position = .zero
        addChild(background)
        
        let titleLabel = SKLabelNode(fontNamed: "Menlo-Bold")
        titleLabel.text = "Choose an Upgrade!"
        titleLabel.fontSize = 48
        titleLabel.fontColor = .yellow
        titleLabel.position = CGPoint(x: 0, y: size.height / 2 - 80)
        addChild(titleLabel)
        
        // Create a container for the cards to make positioning easier
        self.cardContainer = SKNode()
        addChild(cardContainer)
        
        // --- Create the 6 Upgrade Cards ---
        let gm = GameManager.shared
        let cardSize = CGSize(width: 200, height: 120)
        
        // Left Column
        let quickAttackCard = createUpgradeCard(size: cardSize, title: "Quick Attack", level: gm.quickAttackLevel, name: "upgradeQuickAttack", imageName: "strike")
        quickAttackCard.position = CGPoint(x: -cardSize.width - 20, y: 90)
        cardContainer.addChild(quickAttackCard)
        
        let boulderSizeCard = createUpgradeCard(size: cardSize, title: "Boulder Size", level: gm.boulderSizeLevel, name: "upgradeBoulderSize", imageName: "rockTop")
        boulderSizeCard.position = CGPoint(x: -cardSize.width - 20, y: -50)
        cardContainer.addChild(boulderSizeCard)
        
        // Middle Column
        
        let strongAttackCard = createUpgradeCard(size: cardSize, title: "Strong Attack", level: gm.strongAttackLevel, name: "upgradeStrongAttack", imageName: "Player_LargeStrike")
        strongAttackCard.position = CGPoint(x: 0, y: 90)
        cardContainer.addChild(strongAttackCard)
        
        
        let staminaCard = createUpgradeCard(size: cardSize, title: "Placeholder", level: gm.staminaLevel, name: "upgradeStamina", imageName: "greenGem")
        staminaCard.position = CGPoint(x: 0, y: -50)
        cardContainer.addChild(staminaCard)
        
        
        // Right column
        
        let splashAttackCard = createUpgradeCard(size: cardSize, title: "Splash Attack", level: gm.splashAttackLevel, name: "upgradeSplashAttack", imageName: "kick")
        splashAttackCard.position = CGPoint(x: cardSize.width + 20, y: 90)
        cardContainer.addChild(splashAttackCard)
        
        let healthCard = createUpgradeCard(size: cardSize, title: "Max Health", level: gm.healthLevel, name: "upgradeHealth", imageName: "health")
        healthCard.position = CGPoint(x: cardSize.width + 20, y: -50)
        cardContainer.addChild(healthCard)
        
        
        // --- Create the Confirm Button (initially hidden) ---
        confirmButton = SKLabelNode(fontNamed: "Menlo-Bold")
        confirmButton.text = "Confirm Upgrade"
        confirmButton.fontSize = 32
        confirmButton.fontColor = .gray // Start in a disabled state
        confirmButton.position = CGPoint(x: 0, y: -145)// -size.height / 2 + 80)
        confirmButton.name = "confirmButton"
        addChild(confirmButton)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    /// Called by GameScene when a card is tapped. This handles the visual highlighting.
    func selectCard(withName name: String) {
        // 1. Deselect all other cards.
        // Iterate through each card SKNode in the container.
        for card in cardContainer.children {
            // Find the background shape node within this card.
            if let background = card.childNode(withName: "cardBackground") as? SKShapeNode {
                background.strokeColor = .lightGray // Reset to default color.
            }
        }
        
        // 2. Select the new card.
        // Find the specific card SKNode that was tapped by its unique name.
        if let selectedCard = cardContainer.childNode(withName: name) {
            // Find the background shape node within the selected card.
            if let selectedBackground = selectedCard.childNode(withName: "cardBackground") as? SKShapeNode {
                selectedBackground.strokeColor = .yellow // Highlight with yellow.
            }
        }
        
        // 3. Store the name of the selected upgrade and enable the confirm button.
        selectedCardName = name
        confirmButton.fontColor = .cyan
    }

    
    /// Returns the name of the currently selected upgrade.
    func getSelectedUpgradeName() -> String? {
        return selectedCardName
    }
    
    // In UpgradeMenuNode.swift

    /// A helper function to create a single upgrade card UI.
    private func createUpgradeCard(size: CGSize, title: String, level: Int, name: String, imageName: String) -> SKNode {
        let card = SKNode()
        card.name = name
        //card.name = "upgradeCard"
        
        let background = SKShapeNode(rectOf: size, cornerRadius: 10)
        background.name = "cardBackground" // Give the background a generic name
        
        //background.userData = ["name": name] // Store the unique name in userData
        //background.name = name
        background.fillColor = .darkGray
        background.strokeColor = .lightGray
        background.lineWidth = 2
        //background.name = name
        card.addChild(background)
        
        let titleLabel = SKLabelNode(fontNamed: "Menlo-Regular")
        titleLabel.text = title
        titleLabel.fontSize = 18
        titleLabel.fontColor = .white
        titleLabel.position = CGPoint(x: 0, y: size.height/2 - 25)
        titleLabel.isUserInteractionEnabled = false // <-- ADD THIS LINE
        card.addChild(titleLabel)
        
        // --- ADD THIS BLOCK to create the image ---
        let imageSprite = SKSpriteNode(imageNamed: imageName)
        // Scale the image to fit nicely in the card's center
        let imageSize: CGFloat = 40.0
        imageSprite.size = CGSize(width: imageSize, height: imageSize)
        imageSprite.position = CGPoint(x: 0, y: 10) // Position it in the middle
        imageSprite.isUserInteractionEnabled = false // <-- ADD THIS LINE
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
            star.isUserInteractionEnabled = false
            card.addChild(star)
        }
        
        return card
    }
}
