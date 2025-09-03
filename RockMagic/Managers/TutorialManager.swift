//
//  TutorialManager.swift
//  RockMagic
//
//  Created by Tucker Hoppe on 8/22/25.
//

import SpriteKit

// This enum defines every step of our tutorial.
enum TutorialStep: CaseIterable {
    case welcome
    case moveRight
    case jump
    case swipeUp
    case quickAttack
    case strongAttack
    case splashAttack
    case littleRat
    case blocker
    case collectGem
    case medPack
    case levelUp
    case finalMessage
    case complete
}

class TutorialManager {
    
    private weak var scene: GameScene?
    private var magicManager: MagicManager!
    private var player: PlayerNode!
    private var enemiesManager: EnemiesManager!
    private var hud: HUDNode!
    
    var currentTutorialStep: TutorialStep = .welcome
    //private var tutorialImageNode: SKSpriteNode!
    // --- ADD THESE NEW PROPERTIES ---
    var tutorialNode: SKNode!
    private var titleLabel: SKLabelNode!
    private var tutorialLabel: SKLabelNode!
    private var tutorialImage: SKSpriteNode!
    var tutorialNextButton: SKLabelNode!
    // --- ADD THIS NEW PROPERTY ---
    var isTutorialActive: Bool = true
    
    var skipButton: SKLabelNode!
    
    init(scene: GameScene) {
        self.scene = scene
        
        self.magicManager = scene.magicManager
        self.player = scene.player
        self.enemiesManager = scene.enemiesManager
        self.hud = scene.hud
    }
    
    // MARK: Tutorial Logic
    
    /// Sets up the initial state of the tutorial UI.
    func setupTutorial() {
        // Create a container for all tutorial UI
        tutorialNode = SKNode()
        tutorialNode.position = CGPoint(x: 0, y: 65) // Positioned above the player
        tutorialNode.zPosition = ZPositions.hud
        scene?.addChild(tutorialNode)
        
        // Create the semi-transparent background card
        let card = SKShapeNode(rectOf: CGSize(width: 300, height: 120), cornerRadius: 10)
        card.fillColor = .black.withAlphaComponent(0.7)
        card.strokeColor = .clear
        tutorialNode.addChild(card)
        
        // --- ADD THIS BLOCK to create the title ---
        titleLabel = SKLabelNode(fontNamed: "Menlo-Bold")
        titleLabel.text = "Tutorial"
        titleLabel.fontSize = 22
        titleLabel.fontColor = .green
        // Position it at the top of the card
        titleLabel.position = CGPoint(x: 0, y: 35)
        tutorialNode.addChild(titleLabel)
        // -----------------------------------------

        
        // Create the text label
        tutorialLabel = SKLabelNode(fontNamed: "Menlo-Regular")
        tutorialLabel.text = "Welcome to RockMagic! Let's learn the basics."
        tutorialLabel.fontSize = 16
        tutorialLabel.fontColor = .white
        tutorialLabel.numberOfLines = 0
        tutorialLabel.preferredMaxLayoutWidth = 280
        tutorialLabel.verticalAlignmentMode = .center
        tutorialNode.addChild(tutorialLabel)
        
        // Create the optional image node (initially hidden)
        tutorialImage = SKSpriteNode()
        tutorialImage.position = CGPoint(x: 200, y: -50) // Positioned above the text
        tutorialImage.isHidden = true
        tutorialNode.addChild(tutorialImage)
        
        // Create a "Skip" button (this part is the same)
        skipButton = SKLabelNode(fontNamed: "Menlo-Regular")
        skipButton.text = "Skip Tutorial"
        skipButton.fontSize = 20
        skipButton.fontColor = .cyan
        //skipButton.position = CGPoint(x: size.width / 3, y: size.height / 3)
        skipButton.position = CGPoint(x: 270, y: -150)
        skipButton.zPosition = ZPositions.hud
        skipButton.name = "skipButton"
        scene?.addChild(skipButton)
        
        // --- ADD THE NEW "NEXT" BUTTON ---
        // Create it once, but keep it hidden until a step is completed.
        tutorialNextButton = SKLabelNode(fontNamed: "Menlo-Bold")
        tutorialNextButton.text = "Next >"
        tutorialNextButton.fontSize = 22
        tutorialNextButton.fontColor = .gray
        tutorialNextButton.position = CGPoint(x: 100, y: -40) // Positioned in the bottom-right of the card
        tutorialNextButton.name = "tutorialNextButton"
        //tutorialNextButton.isHidden = true // Start hidden
        tutorialNode.addChild(tutorialNextButton)
        
        // Start the first step
        completeTutorialStep()
    }
    
    /// Moves the tutorial to the next step and updates the UI.
    func advanceTutorial() {
        
        tutorialNextButton.fontColor = .gray
        // Find the next step in our enum's list of cases.
        if let currentIndex = TutorialStep.allCases.firstIndex(of: currentTutorialStep),
           currentIndex + 1 < TutorialStep.allCases.count {
            currentTutorialStep = TutorialStep.allCases[currentIndex + 1]
        } else {
            currentTutorialStep = .complete
        }
        
        // Update the instruction image based on the new step.
        switch currentTutorialStep {
        case .welcome:
            
            tutorialLabel.text = "Welcome to RockMagic! Let's learn the basics."
        case .moveRight:
            titleLabel.text = "Movement"
            tutorialLabel.text = "Use the joystick to move left and right."
        case .jump:
            titleLabel.text = "Jumping"
            tutorialLabel.text = "Push the joystick up to jump."
        case .swipeUp:
            titleLabel.text = "Boulder Pull"
            tutorialLabel.text = "Swipe Up to pull up a boulder from the ground"
            // Example of showing an optional image for this step
            tutorialImage.texture = SKTexture(imageNamed: "swipeArrow")
            tutorialImage.size = CGSize(width: 350, height: 350) // Set a size for the icon
            tutorialImage.isHidden = false
        case .quickAttack:
            magicManager.pullUpBoulder(position: CGPoint(x: player.worldPosition.x + 100, y: GameManager.shared.boulderFinalY))
            titleLabel.text = "Quick Attack"
            tutorialLabel.text = "Tap left/right side of the screen to shoot a rock piece"
            tutorialImage.isHidden = true
        case .strongAttack:
            magicManager.pullUpBoulder(position: CGPoint(x: player.worldPosition.x + 100, y: GameManager.shared.boulderFinalY))
            titleLabel.text = "Strong Attack"
            tutorialLabel.text = "Swipe right/left to launch the closest boulder"
            tutorialImage.zRotation = -.pi / 2
            tutorialImage.isHidden = false
        case .splashAttack:
            magicManager.pullUpBoulder(position: CGPoint(x: player.worldPosition.x - 400, y: GameManager.shared.boulderFinalY))
            titleLabel.text = "Splash Attack"
            tutorialLabel.text = "Swipe down to launch a boulder for area damage."
            tutorialImage.zRotation = .pi
        case .littleRat:
            enemiesManager.spawnSingleEnemy(type: .littleRat)
            titleLabel.text = "Enemies"
            tutorialLabel.text = "Litttle Rats dodge Strong attacks. Use your quick attack(TAP)!"
            tutorialImage.isHidden = true
        case .blocker:
            enemiesManager.spawnSingleEnemy(type: .blocker)
            titleLabel.text = "Enemies"
            tutorialLabel.text = "Blocker shields block direct hits. Use a Splash Attack(Swipe Down) to break them!"
        case .collectGem:
            let gem = PickupNode(type: .coin)
            gem.position = CGPoint(x: player.worldPosition.x + 100, y:GameManager.shared.groundLevel + 15)
            scene?.worldNode.addChild(gem)
            titleLabel.text = "Pick Ups"
            tutorialLabel.text = "Collect Gems from Enemies to increase your score and level up!"
        case .medPack:
            player.currentHealth = 50
            hud.updateHealthBar(currentHealth: CGFloat(player.currentHealth), maxHealth: CGFloat(GameManager.shared.playerMaxHealth))
            let med = PickupNode(type: .health)
            med.position = CGPoint(x: player.worldPosition.x + 100, y:GameManager.shared.groundLevel + 15)
            scene?.worldNode.addChild(med)
            
            tutorialLabel.text = "Restore health only when damaged."
        case .levelUp:
            enemiesManager.spawnSingleEnemy(type: .normal)
            GameManager.shared.currentScore = GameManager.shared.levelThresholdIncrements[0] - (GameManager.shared.normalEnemyValue + GameManager.shared.normalGemValue)
            titleLabel.text = "Upgrades"
            tutorialLabel.text = "When you level up, you get to choose an upgrade!"
        case .finalMessage:
            titleLabel.text = "Tutorial Complete"
            tutorialLabel.text = "Time to use your ROCK MAGIC!"
            completeTutorialStep()
        case .complete:
            isTutorialActive = false
            GameManager.shared.reset()
            enemiesManager.beginSpawning(gameMode: scene!.gameMode) // Tell the enemies to start
            // The tutorial is over, so remove all its UI.
            tutorialNode.removeFromParent()
            skipButton.removeFromParent()
        }
    }
    
    // --- ADD THIS NEW FUNCTION ---
    /// Called when the player completes the action for the current tutorial step.
    /// This makes the "Next" button appear.
    func completeTutorialStep() {
        // Only show the button if the tutorial isn't over.
        if currentTutorialStep != .complete {
            tutorialNextButton.fontColor = .cyan
        }
    }
    
}
