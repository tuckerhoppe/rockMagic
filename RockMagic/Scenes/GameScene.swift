//
//  GameScene.swift
//  RockMagic
//
//  Created by Tucker Hoppe on 4/28/25.
//

import SpriteKit


protocol GameSceneDelegate: AnyObject {
    func gameScene(_ scene: GameScene, didRequestHighScoreInputWith score: Int)
    func gameSceneDidRequestMainMenu(_ scene: GameScene) // <-- ADD THIS
    func gameSceneDidRestart(_ scene: GameScene)
}

enum gameMode {
    case survival
    case defense
    case attack
}

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    var player: PlayerNode!
    var joystick: Joystick!
    var enemies: [EnemyNode]! = []
    var boulders: [Boulder] = []
    var magicManager: MagicManager!
    
    var setupManager: SetupManager!
    var enemiesManager: EnemiesManager!
    var inputManager: InputManager!
    var collisionManager: CollisionManager!
    var tutorialManager: TutorialManager!
    
    private var pauseMenu: PauseMenuNode!
    private var upgradeMenu: UpgradeMenuNode!
    
    // --- WITH THIS NEW STATE PROPERTY ---
    private var flickState: JoystickFlickState = .neutral
    private var flickPrimeTime: TimeInterval = 0
    
    let levelData: LevelData
    // --- ADD THIS NEW INITIALIZER ---
    init(levelData: LevelData, size: CGSize) {
        self.levelData = levelData
        super.init(size: size)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    weak var gameDelegate: GameSceneDelegate?
    
    var gameMode: gameMode! //= GameManager.shared.currentGameMode
    
    // --- Add this new property ---
    private var gameplayTouch: UITouch?
    
    // --- ADD THESE NEW PROPERTIES for dragging ---
    private var draggedBoulder: Boulder?
    // This node is an invisible "hand" that we will move with the player's finger.
    private var touchAnchorNode: SKNode?
    // The joint is now a generic SKPhysicsJoint.
    private var touchJoint: SKPhysicsJoint?
    private var lastTouchTimestamp: TimeInterval = 0
    private var lastTouchLocation: CGPoint = .zero

    

    
    // --- ADD HUD AND SCORE PROPERTIES ---
    var hud: HUDNode!
    //private var score = 0
    
    // --- ADD THE CAMERA NODE ---
    //private let cameraNode = SKCameraNode()
    
    // Add a property to track the time of the last frame
    private var lastUpdateTime: TimeInterval = 0
    
    // --- 1. DEFINE THE WORLD NODE ---
    var worldNode: SKNode!
    
    // --- ADD THESE NEW NODES ---
    var farBackgroundNode: SKNode!
    var midBackgroundNode: SKNode!
    
    private var gameOverMenu: GameOverNode!
    private var victoryMenu: VictoryNode!
    
    /// A special node that will not be affected when the scene is paused.
    /// This is used to run timers and animations for menus.
    private var unpausableNode: SKNode!
    
    /// A flag to prevent accidental taps on the game over menu.
    var isGameOverInteractable = false
    
    // --- 2. DEFINE MOVEMENT PROPERTIES ---
    private let playerMoveSpeed: CGFloat = GameManager.shared.playerMoveSpeed
    private let centerScreenAreaR: CGFloat = GameManager.shared.centerScreenAreaR
    private let centerScreenAreaL: CGFloat = GameManager.shared.centerScreenAreaL
    private var screenBoundaryLeft: CGFloat!
    private var screenBoundaryRight: CGFloat!
    
    private var highlightedBoulder: Boulder?
    
    private var joystickTouch: UITouch?
    
    /// Tracks if the joystick was pointing down in the previous frame.
    private var wasJoystickPointingDown = false
    
    var pillarBeingPulled: PillarNode?
    private var hasCreatedPillarThisTouch = false
    
    //var testWorldNode: SKNode!
    
//    // --- ADD THESE NEW PROPERTIES ---
//    var currentTutorialStep: TutorialStep = .welcome
//    //private var tutorialImageNode: SKSpriteNode!
//    // --- ADD THESE NEW PROPERTIES ---
//    private var tutorialNode: SKNode!
//    private var titleLabel: SKLabelNode!
//    private var tutorialLabel: SKLabelNode!
//    private var tutorialImage: SKSpriteNode!
//    private var tutorialNextButton: SKLabelNode!
//    // --- ADD THIS NEW PROPERTY ---
//    var isTutorialActive: Bool = true


   // private var skipButton: SKLabelNode!
    
    override func didMove(to view: SKView) {
        
        // ADD THIS LINE!
        self.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        
        // --- ADD THIS BLOCK to create the unpausable node ---
        unpausableNode = SKNode()
        addChild(unpausableNode)
        
        
        // Add this to didMove(to:) to find the exact font name
        for family in UIFont.familyNames.sorted() {
            let names = UIFont.fontNames(forFamilyName: family)
            print("Family: \(family) Font names: \(names)")
        }
        
        
        screenBoundaryLeft = 6
        screenBoundaryRight = 14
        
        //--- All game Modes: ---
        backgroundColor = .cyan
        GameManager.shared.scene = self // Give the manager a reference to the scene
        
        GameManager.shared.reset()
        
        // Safely unwrap the view to get its dimensions
        guard let view = self.view else { return }
        
        EffectManager.shared.scene = self
        
        //--- SURVIVAL MODE ---
        // Might want a different sized world
        // 1. Define the size of your game world. Let's make it 3 screens wide.
        let worldWidth = self.size.width * 3
        let worldHeight = self.size.height
        let worldSize = CGSize(width: worldWidth, height: worldHeight)
        
        // --- 3. INITIALIZE THE WORLD NODE ---
        worldNode = SKNode()
        addChild(worldNode)
        let worldGrid = createWorldCoordinateGrid(worldSize: worldSize, step: 50)
        worldNode.addChild(worldGrid)
        
        let grid = createCoordinateGrid(in: self, step: 50)
        //addChild(grid)
        
        setupManager = SetupManager(scene: self)
        // Probably a generic setupall function and the setups for the other game modes
        setupManager.setupLevel(levelData: self.levelData, view: view)
        //setupManager.setupAll(view: view, gameMode: .survival)
        
        // Create the Pause Menu
        pauseMenu = PauseMenuNode(size: self.size)
        pauseMenu.position = CGPoint(x: -5000, y: -5000)
        pauseMenu.zPosition = ZPositions.hud + 10
        addChild(pauseMenu) // Add directly to the scene
        
        
        // Might want a different world size for other game modes
        hud = HUDNode(sceneSize: view.bounds.size)
        hud.zPosition = ZPositions.hud
        addChild(hud) // Add to scene, NOT worldNode
        hud.showMessage(levelData.levelMessage)
        
        tutorialManager = TutorialManager(scene: self)
        // This tutorial is just
        tutorialManager.setupTutorial()
        // Maybe future additional tutorials for the specific modes.
        
        
        
        
        
        
        //testWorldNode = createWorldCoordinateGrid(worldSize: worldSize, step: 50)
        //addChild(testWorldNode) // Add it directly to the scene
        
        
        
        // --- Defend Mode ---
        
        // Initialize Boulder Family
        //Initialize Enemies manager with specific Enemy behavior:
        // Some enemies go for just the family, some go for just the player. Probably 70/30 split

        
        // Setup different Background??
        
        // Family Health to Hud
        
        
        // --- Story Mode ---
        
        // initialize correct level stats based on saved distance
        // Enemy manager stats for level,
        
        // Structures for level
        // Distance for HUD along with configurable Health Hud(For any level specific objectives(family health, evil fort health))
        
        // --- ADD THIS ---
//        // 1. Create the built-in long press gesture recognizer.
//        let longPressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress))
//        
//        // 2. Configure it.
//        longPressRecognizer.minimumPressDuration = 0.4 // How long the press must be.
//
//        // 3. Add it to the main view that hosts the scene.
//        view.addGestureRecognizer(longPressRecognizer)
        

    }
    
    
    // --- Update plays every frame ---
    override func update(_ currentTime: TimeInterval) {
        
        // --- ALL GAME MODES ---
        inputManager.update(currentTime: currentTime)
        
        // Calculate the time elapsed since the last frame (deltaTime)
        if lastUpdateTime == 0 {
            lastUpdateTime = currentTime
        }
        let deltaTime = currentTime - lastUpdateTime
        lastUpdateTime = currentTime
        
        // Update the shared GameManager instance
        GameManager.shared.update(deltaTime: deltaTime)
        // Tell the HUD to update its timer display.
        hud.updateTimer(time: GameManager.shared.gameTime)

        
        let joystickVelocity = joystick.velocity
        
        // --- Maybe remove or adjust to run upgrades ---
        player.regenerateStamina(deltaTime: deltaTime)
        
        
        // Maybe put into a player Move function? Maybe not though it affects everything but the player for the most part
        if player.action(forKey: "action") == nil {
            if joystickVelocity.dx != 0 {
                player.playAnimation(.walk)
                player.updateFacingDirection(joystickVelocity: joystickVelocity)
            } else {
                player.playAnimation(.idle)
            }
        }
        
        
//        if joystickVelocity.dx > 0 { // Moving Right
//            //print(player.position.x)
//            player.isWalking = true
//            if player.worldPosition.x < 825 && (player.position.x < centerScreenAreaR && player.position.x > centerScreenAreaL){
//                worldNode.position.x -= playerMoveSpeed
//                farBackgroundNode.position.x -= playerMoveSpeed * 0.2
//                midBackgroundNode.position.x -= playerMoveSpeed * 0.5
//            } else { // On the right edge of the screen
//                player.position.x += playerMoveSpeed
//            }
//            
//        } else if joystickVelocity.dx < 0 { // Moving Left
//            player.isWalking = true
//            if player.worldPosition.x > -825 && (player.position.x < centerScreenAreaR && player.position.x > centerScreenAreaL){
//                // FOR DEBUGGING
//                //testWorldNode.position.x += playerMoveSpeed
//                
//                worldNode.position.x += playerMoveSpeed
//                farBackgroundNode.position.x += playerMoveSpeed * 0.2
//                midBackgroundNode.position.x += playerMoveSpeed * 0.5
//            } else { // On the left edge of the screen
//                player.position.x -= playerMoveSpeed
//            }
//            
//        } else {
//            player.isWalking = false
//        }
//        player.worldPosition.x = player.position.x - worldNode.position.x
        
        // 1. Handle animations (this part is the same)
            if player.action(forKey: "action") == nil {
                if joystickVelocity.dx != 0 {
                    player.playAnimation(.walk)
                    player.updateFacingDirection(joystickVelocity: joystickVelocity)
                } else {
                    player.playAnimation(.idle)
                }
            }
            
            // 2. Apply horizontal movement directly to the player's physics body.
            //    The physics engine will now handle collisions with pillars correctly.
//            if joystickVelocity.dx != 0 {
//                player.physicsBody?.velocity.dx = joystickVelocity.dx * playerMoveSpeed * 100 // Multiply for physics velocity
//            } else {
//                player.physicsBody?.velocity.dx = 0
//            }
        
        if joystickVelocity.dx > 0 { // Moving Right
            player.physicsBody?.velocity.dx = playerMoveSpeed * 100
        } else if joystickVelocity.dx < 0 { // Moving Left
            player.physicsBody?.velocity.dx = -playerMoveSpeed * 100
        } else {
            player.physicsBody?.velocity.dx = 0
        }
        
        
        // --- Vertical (Jump) Movement ---
        let yVelocity = joystickVelocity.dy
        let verticalThreshold: CGFloat = 0.7
        // If the joystick is pushed DOWN...
        if yVelocity < -verticalThreshold {
            // ...record the current time to "prime" the boulder jump.
            flickPrimeTime = currentTime
            
        }
        // If the joystick is pushed UP...
        else if yVelocity > verticalThreshold {
            // ...check if it was primed recently.
            // The time window is 0.3 seconds. You can adjust this value.
            if flickPrimeTime > 0 && currentTime - flickPrimeTime < 0.6 {
                // If yes, it's a boulder jump.
                print("BOULDER JUMP")
                player.boulderJump()
                // IMPORTANT: Reset the timer immediately to prevent multiple jumps.
                flickPrimeTime = 0
            } else {
                // Otherwise, it's a normal jump.
                player.jump()
            }
        }
        
        
        
        // Update enemies and managers
        enemiesManager.updateEnemies(defaultTarget: player)
        magicManager.update()
        
        // Highlight logic
        let closest = magicManager.closestBoulder()
        if closest !== highlightedBoulder {
            highlightedBoulder?.setHighlight(active: false)
            closest?.setHighlight(active: true)
            highlightedBoulder = closest
        }
        
        // Pillar Logic
        if let pillar = pillarBeingPulled {
            pillar.moveUp()
        }

        // --- ADD THIS BLOCK to check for tutorial actions ---
        if tutorialManager.currentTutorialStep != .complete {
            switch tutorialManager.currentTutorialStep {
            case .moveRight:
                if joystick.velocity.dx > 0.5 { tutorialManager.completeTutorialStep() }
            case .jump:
                if !player.isGrounded { tutorialManager.completeTutorialStep() }
            default:
                break // Other actions will be handled by the InputManager
            }
        }
        
        checkWinCondition()
        //
    }
    
    // --- ADD THIS NEW FUNCTION ---
    /// This function is called automatically AFTER the physics engine has calculated all movement.
    override func didFinishUpdate() {
        // --- THE FIX: Step 2 - Adjust the Camera (worldNode) ---
        
        // 1. Check if the player has moved outside the center screen boundaries.
        let playerX = player.position.x
        var worldXAdjustment: CGFloat = 0
        
        if playerX > screenBoundaryRight {
            worldXAdjustment = playerX - screenBoundaryRight
        } else if playerX < screenBoundaryLeft {
            worldXAdjustment = playerX - screenBoundaryLeft
        }
        
        // 2. If an adjustment is needed, scroll the world to bring the player back to the boundary.
        if worldXAdjustment != 0 {
            // Move the player's sprite back
            player.position.x -= worldXAdjustment
            
            // Move the world by the same amount
            worldNode.position.x -= worldXAdjustment
            
            // Move the parallax backgrounds
            farBackgroundNode.position.x -= worldXAdjustment * 0.2
            midBackgroundNode.position.x -= worldXAdjustment * 0.5
        }
        
        // 3. Finally, calculate the worldPosition based on the final, true positions.
        player.worldPosition.x = player.position.x - worldNode.position.x
    }
    
    // --- ADD these new helper functions ---
    func growPillar(at location: CGPoint) {
        // If we haven't already created a pillar for this touch, create one.
        if !hasCreatedPillarThisTouch {
            hasCreatedPillarThisTouch = true
            pillarBeingPulled = magicManager.pullUpPillar(at: location)
        }
        // Tell the pillar to grow.
        pillarBeingPulled?.moveUp()
    }

    func stopGrowingPillar() {
        // When the touch ends, we are no longer pulling a pillar.
        pillarBeingPulled?.pullingUp = false
        pillarBeingPulled = nil
        hasCreatedPillarThisTouch = false // Reset for the next touch
        //player.playAnimation(.idle)
    }
    
//    // --- ADD THIS ACTION METHOD ---
//    @objc func handleLongPress(gesture: UILongPressGestureRecognizer) {
//        // Convert the touch location from the view's coordinate system to the scene's.
//        let touchLocationInView = gesture.location(in: self.view)
//        let sceneLocation = self.convertPoint(fromView: touchLocationInView)
//
//        // The gesture has multiple states. We only care about when it starts and ends.
//        if gesture.state == .began {
//            // This is equivalent to your old `handleHold`.
//            // The user has successfully held their finger down.
//            print("UILongPress BEGAN at: \(sceneLocation)")
//            
//            // --- Place your hold action here ---
//            // Because the gesture recognizer runs separately from the main update loop,
//            // it's still safest to dispatch heavy work.
//            DispatchQueue.global(qos: .userInitiated).async {
//                self.magicManager.pullUpPillar(at: sceneLocation)
//                
//                DispatchQueue.main.async {
//                    // Update UI here if needed.
//                }
//            }
//        } else if gesture.state == .ended || gesture.state == .cancelled {
//            // This is for when the user lifts their finger.
//            print("UILongPress ENDED.")
//            pillarBeingPulled = nil
//            
//            // --- Place your "release" action here if you have one ---
//        }
//    }
    
    
    // --- ADD NEW CALLBACK FUNCTIONS ---
    func playerTookDamage() {
        hud.updateHealthBar(currentHealth: CGFloat(player.currentHealth), maxHealth: CGFloat(player.maxHealth))
    }
    
    // --- ADD this new helper function ---
    func showFloatingText(text: String, at position: CGPoint) {
        let label = SKLabelNode(fontNamed: GameManager.shared.fontName)
        label.text = text
        label.fontSize = 20
        label.fontColor = .white
        label.position = position
        label.zPosition = ZPositions.hud
        
        let moveUp = SKAction.moveBy(x: 0, y: 50, duration: 1.0)
        let fadeOut = SKAction.fadeOut(withDuration: 1.0)
        let remove = SKAction.removeFromParent()
        
        label.run(SKAction.group([moveUp, fadeOut]))
        label.run(SKAction.sequence([.wait(forDuration: 1.0), remove]))
        worldNode.addChild(label)
    }

    
    // --- REPLACE your addScore and enemyDefeated functions with this ---
    func addScore(amount: Int, at position: CGPoint) {
        let gm = GameManager.shared
        let previousLevelScore = gm.scoreForNextLevel - gm.levelThresholdIncrements[min(gm.playerLevel - 1, gm.levelThresholdIncrements.count - 1)]

        gm.currentScore += amount
        showFloatingText(text: "+\(amount)", at: position)
        
        hud.updateScore(newScore: gm.currentScore)
        hud.updateLevelProgress(currentScore: gm.currentScore, scoreForNextLevel: gm.scoreForNextLevel, previousLevelScore: previousLevelScore)
        
        if gm.currentScore >= gm.scoreForNextLevel {
            levelUp()
        }
        
    }
    
    
    private func levelUp() {
        let gm = GameManager.shared
        gm.levelUp()

        // 1. Show the "Level Up!" message immediately.
        hud.showLevelUpMessage()
        hud.updateLevelLabel(level: gm.playerLevel)
        
        // The previous level's score is needed to calculate the progress bar correctly after leveling up.
        // --- THE FIX: Add the 'min' safety check here ---
            let prevLevelThresholdIndex = min(max(0, gm.playerLevel - 2), gm.levelThresholdIncrements.count - 1)
            
        let previousLevelScore = gm.scoreForNextLevel - gm.levelThresholdIncrements[prevLevelThresholdIndex]
        hud.updateLevelProgress(currentScore: gm.currentScore, scoreForNextLevel: gm.scoreForNextLevel, previousLevelScore: previousLevelScore)

        // 2. Create a sequence to show the upgrade menu AFTER the message has faded.
        let wait = SKAction.wait(forDuration: 1.8) // Wait for the "Level Up!" message to finish
        let showUpgradeMenu = SKAction.run { [weak self] in
            guard let self = self else { return }
            
            self.isPaused = true
            self.upgradeMenu = UpgradeMenuNode(size: self.size)
            self.upgradeMenu.zPosition = ZPositions.hud + 10
            self.addChild(self.upgradeMenu)
        }
        
        // 3. Run the sequence.
        self.run(SKAction.sequence([wait, showUpgradeMenu]))
    }
    
    // --- ADD THIS HELPER FUNCTION ---
    private func resumeAfterUpgrade() {
        upgradeMenu.removeFromParent()
        self.isPaused = false
        
        // Also update the player's health to reflect the new max
        player.maxHealth = GameManager.shared.playerMaxHealth
        player.currentHealth = player.maxHealth // Full heal on level up
        playerTookDamage() // Update the HUD
    }
    
    func checkWinCondition() {
        switch gameMode {
        case .survival, .defense:
            if GameManager.shared.gameTime >= levelData.timeLimit {
                showVictoryMenu(message: "You Win!")
            }
        case .attack:
            if enemiesManager.spawnerNodes.isEmpty {
                showVictoryMenu(message: "You Win!")
            }
            
        case .none:
            break
        }
    }
    
    func showVictoryMenu(message: String = "You Won!") {
        // 1. Immediately display the game over node. This ensures it always appears.
        //self.displayGameOverNode()
        
        // 1. Immediately display the green message on the screen.
        showTemporaryMessage(message: message, color: .green)
        worldNode.isPaused = true
        
        // 1. Create the action that will display the game over node.
       let showMenuAction = SKAction.run { [weak self] in
           self?.displayVictoryNode()
       }

       // 2. Create a 1-second wait action.
       let wait = SKAction.wait(forDuration: 1.0)

       // 3. Create a sequence to wait, then show the menu.
       let sequence = SKAction.sequence([wait, showMenuAction])

       // 4. Run the sequence on the unpausableNode to ensure the timer
       //    works even if other parts of the scene are paused.
       unpausableNode.run(sequence)

        
    }

    // Your helper function is still needed
    func displayVictoryNode() {
        //guard GameManager.shared.currentScore > 0 else { return }
        self.isPaused = true
        
        victoryMenu = VictoryNode(size: self.size, score: GameManager.shared.currentScore)
        victoryMenu.zPosition = ZPositions.hud + 20
        addChild(victoryMenu)
        //print("GAME OVER NODE DISPLAYED")
        
        // --- ADD THIS LOGIC ---
         //Start a 1-second timer. The menu will only be interactable after it finishes.
//        let wait = SKAction.wait(forDuration: 5.0)
//        let makeInteractable = SKAction.run { [weak self] in
//            self?.isGameOverInteractable = true
//            print("Ok it should be interactable now!")
//        }
//        self.run(SKAction.sequence([wait, makeInteractable]))
    }
        

    func showGameOverMenu(message: String = "You Died") {
        // 1. Immediately display the game over node. This ensures it always appears.
        //self.displayGameOverNode()
        
        // 1. Immediately display the red message on the screen.
        showTemporaryMessage(message: message, color: .red)
        worldNode.isPaused = true
        
        // 1. Create the action that will display the game over node.
           let showMenuAction = SKAction.run { [weak self] in
               self?.displayGameOverNode()
           }

           // 2. Create a 1-second wait action.
           let wait = SKAction.wait(forDuration: 1.0)

           // 3. Create a sequence to wait, then show the menu.
           let sequence = SKAction.sequence([wait, showMenuAction])

           // 4. Run the sequence on the unpausableNode to ensure the timer
           //    works even if other parts of the scene are paused.
           unpausableNode.run(sequence)

        // 2. Separately, check for a high score in the background.
        CloudKitManager.shared.fetchHighScores { [weak self] (scores, error) in
            if let error = error {
                print("CRITICAL ERROR fetching high scores: \(error.localizedDescription)")
                // If you see this message, the problem is with your CloudKit setup.
                return
            }
            guard let self = self else { return }
            
            let highScores = scores ?? []
            let lowestScore = highScores.last?.score ?? 0
            let playerScore = GameManager.shared.currentScore
            
            // Sort all scores descending
            let sortedScores = highScores.sorted { $0.score > $1.score }

            // Take the top 10
            let topTenScores = Array(sortedScores.prefix(5)) // 5 for now

            // Get the lowest score among the top 10
            let lowestTopTenScore = topTenScores.last?.score ?? 0
            
            // --- ADD THIS "BLACK BOX RECORDER" ---
            print("--- High Score Check ---")
            print("Player's Score: \(playerScore)")
            print("Number of High Scores Found: \(highScores.count)")
            print("Lowest Score on Leaderboard: \(lowestScore)")
            print("Is player score > lowest score? \(playerScore > lowestScore)")
            print("Is leaderboard count < 10? \(highScores.count < 10)")
            // ------------------------------------
            
            if highScores.count < 5 || GameManager.shared.currentScore > lowestTopTenScore {
                print("well at least we made it here!")
                
                
                // If it's a high score, tell the view controller to show the pop-up.
                // This will now appear ON TOP of the already-visible game over screen.
                self.gameDelegate?.gameScene(self, didRequestHighScoreInputWith: GameManager.shared.currentScore)
            }
        }
    }

    // Your helper function is still needed
    func displayGameOverNode() {
        //guard GameManager.shared.currentScore > 0 else { return }
        self.isPaused = true
        
        gameOverMenu = GameOverNode(size: self.size, score: GameManager.shared.currentScore)
        gameOverMenu.zPosition = ZPositions.hud + 20
        addChild(gameOverMenu)
        print("GAME OVER NODE DISPLAYED")
        
        // --- ADD THIS LOGIC ---
         //Start a 1-second timer. The menu will only be interactable after it finishes.
//        let wait = SKAction.wait(forDuration: 5.0)
//        let makeInteractable = SKAction.run { [weak self] in
//            self?.isGameOverInteractable = true
//            print("Ok it should be interactable now!")
//        }
//        self.run(SKAction.sequence([wait, makeInteractable]))
    }
    
    // In GameScene.swift

    /// Displays a large, temporary message in the center of the screen that fades out.
    private func showTemporaryMessage(message: String, color: UIColor) {
        let messageLabel = SKLabelNode(fontNamed: GameManager.shared.fontName)
        messageLabel.text = message
        messageLabel.fontColor = color
        messageLabel.fontSize = 45
        messageLabel.position = .zero // Center of the scene
        messageLabel.zPosition = ZPositions.hud + 10 // On top of everything

        // Create a sequence to scale, wait, fade, and then remove the label.
        let scaleUp = SKAction.scale(to: 1.2, duration: 0.2)
        let wait = SKAction.wait(forDuration: 1.0)
        let fadeOut = SKAction.fadeOut(withDuration: 0.5)
        let remove = SKAction.removeFromParent()
        
        let sequence = SKAction.sequence([scaleUp, wait, fadeOut, remove])
        messageLabel.run(sequence)
        
        // Add the label to the scene itself so it's not affected by world scrolling.
        addChild(messageLabel)
    }
    
    
    
    // In GameScene.swift

    

    /// Draws a red rectangle in the world for debugging purposes.
    /// The rectangle will fade out and disappear after 1 second.
    func drawDebugHitbox(rect: CGRect) {
        let shape = SKShapeNode(rect: rect)
        shape.strokeColor = .red
        shape.lineWidth = 2
        shape.zPosition = ZPositions.hud // Make sure it's on top of everything
        
        let fadeOut = SKAction.fadeOut(withDuration: 1.0)
        let remove = SKAction.removeFromParent()
        let sequence = SKAction.sequence([fadeOut, remove])
        shape.run(sequence)
        
        worldNode.addChild(shape) // Add it to the world so it scrolls correctly
    }
    
    
    
    
    // --- ADD this new callback function ---
    func playerUsedStamina() {
        hud.updateStaminaBar(currentStamina: CGFloat(player.currentStamina), maxStamina: CGFloat(player.maxStamina))
        hud.updateGoldenBoulderButton(currentStamina: player.currentStamina, maxStamina: player.maxStamina)
    }
        
    // In GameScene.swift

    // This function now calls the main pullUpBoulder function.
    func playerDidRequestBoulder(at position: CGPoint) {
        magicManager.pullUpBoulder(position: position, playAnimation: false)
    }
    
    // In GameScene.swift

    // --- REPLACE ALL FOUR of your touches... functions with these ---

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            let location = touch.location(in: self)
            
            if !self.isPaused {
                // --- Check distance to the joystick's position ---
                let distanceToJoystick = joystick.position.distance(to: location)
                if distanceToJoystick <= joystick.touchAreaRadius && joystickTouch == nil {
                    joystickTouch = touch
                    joystick.update(at: touch.location(in: joystick))
                    continue
                }
            }
            
    
            
            
            
            // --- Menu & Upgrade Logic ---
            let tappedNode = self.atPoint(location)
            
            var currentNode: SKNode? = tappedNode
//
//            // Check for upgrade card taps first
//            if let cardBackground = tappedNode as? SKShapeNode, let cardName = cardBackground.name as? String {
//                upgradeMenu.selectCard(withName: cardName)
//                print("selecting: \(cardName)")
//                return // The touch has been handled
//            }
            
            
            // 1. CARD SELECTION LOGIC (The "Bubble Up" Method)
            // This loop travels up from the tapped node to find a parent card.
            while let node = currentNode {
                // Check if the node's name is one of our upgrade cards.
                if let nodeName = node.name, nodeName.starts(with: "upgrade") {
                    
                    // We found an upgrade card! Select it and stop all further touch processing.
                    upgradeMenu.selectCard(withName: nodeName)
                    print("Successfully selected card: \(nodeName)")
                    return // The touch has been handled, so we exit the function.
                }
                
                // If it's not a card, move up to the parent and check again.
                currentNode = node.parent
            }
            
            
//            if tappedNode.name == "restartButton" || tappedNode.name == "exitButton" {
//                // --- ADD THIS CHECK ---
//                // Only allow the buttons to be tapped if the grace period is over.
//                guard isGameOverInteractable else { continue }
//            }
            
            
            // In GameScene.swift, inside touchesBegan()

            // --- This is the new logic for handling upgrade card taps ---
            if let tappedName = tappedNode.name {
                var upgradeType: UpgradeType?
                var wasButtonTapped = true // A flag to track if a button was hit
                
                switch tappedName {
                case "confirmButton":
                    print("clicked on confirm")
                    if let upgradeName = upgradeMenu.getSelectedUpgradeName() {
                        // Apply the selected upgrade
                        var upgradeType: UpgradeType?
                        if upgradeName == "upgradeHealth" { upgradeType = .health }
                        else if upgradeName == "upgradeQuickAttack" { upgradeType = .quickAttack }
                        else if upgradeName == "upgradeStrongAttack" { upgradeType = .strongAttack }
                        else if upgradeName == "upgradeSplashAttack" { upgradeType = .splashAttack }
                        else if upgradeName == "upgradePillars" { upgradeType = .pillar }
                        else if upgradeName == "upgradeBoulderSize" { upgradeType = .boulderSize }
                        if let type = upgradeType {
                            GameManager.shared.applyUpgrade(type)
                            resumeAfterUpgrade()
                            print("Upgrade on its way!")
                        }
                        print("Sounds like you didn;t pick an upgrade!")
                        
                    }

                case "pauseButton": pauseGame()
                case "resumeButton": resumeGame()
                case "restartButton": restartGame()
                case "exitButton": exitToMainMenu()
                case "instructionsButton": pauseMenu.showInstructions()
                case "backButton": pauseMenu.hideInstructions()
                case "viewUpgradesButton": pauseMenu.showUpgrades()
                case "backToPauseMenuButton": pauseMenu.hideUpgrades()
                //case "goldenBoulderButton": magicManager.pullUpGoldenBoulderAtPlayer()
                case "tutorialNextButton":
                    // Only advance if the button is active (cyan).
                    if tutorialManager.tutorialNextButton.fontColor == .cyan {
                            tutorialManager.advanceTutorial()
                        }
                case "skipButton":
                    tutorialManager.currentTutorialStep = .complete
                    tutorialManager.isTutorialActive = false // Update the state here too
                    enemiesManager.beginSpawning(gameMode: gameMode) // Tell the enemies to start
                    tutorialManager.tutorialNode.removeFromParent()
                    tutorialManager.skipButton.removeFromParent()
                default:
                    wasButtonTapped = false // No known button was tapped
                }
                
                // --- THE FIX: If a button was tapped, consume the touch ---
                if wasButtonTapped {
                    continue // Stop processing this touch and move to the next finger.
                }
                
                if let type = upgradeType {
                    GameManager.shared.applyUpgrade(type)
                    resumeAfterUpgrade()
                }
            }
            

            
            // 3. If it's not for the joystick or a menu, it's a gameplay touch.
            if gameplayTouch == nil {
                gameplayTouch = touch
                let locationInWorld = touch.location(in: worldNode)
                let locationInScene = touch.location(in: self)
                inputManager.touchesBegan(at: locationInWorld, screenLocation: locationInScene, timestamp: touch.timestamp)
                //inputManager.touchesBegan(at: locationInWorld, screenLocation: locationInScene, timestamp: touch.timestamp, touch: touch)
            }
            
        }
    }

    // In GameScene.swift

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            if touch == joystickTouch {
                joystick.update(at: touch.location(in: joystick))
            } else if touch == gameplayTouch {
                inputManager.touchesMoved(to: touch.location(in: worldNode))
            }
        }
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            if touch == joystickTouch {
                joystick.reset()
                joystickTouch = nil
            } else if touch == gameplayTouch {
                let locationInWorld = touch.location(in: worldNode)
                let locationInScene = touch.location(in: self)
                inputManager.touchesEnded(at: locationInWorld, screenLocation: locationInScene, timestamp: touch.timestamp)
                gameplayTouch = nil
            }
        }
    }

    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        // This function can be simplified to handle both cases
        touchesEnded(touches, with: event)
    }
    

    func startDrag(on boulder: Boulder, at location: CGPoint) {
        // --- THE FIX: Check for full stamina before starting the drag ---
        guard player.currentStamina >= player.maxStamina else {
            print("Not enough stamina to drag the golden boulder!")
            return // Exit the function; the drag will not start.
        }
        
        player.currentStamina -= 20
        playerUsedStamina() // Update the HUD
        
        let shape = SKShapeNode(circleOfRadius: 10)
        shape.fillColor = .blue
        shape.strokeColor = .clear
        shape.zPosition = ZPositions.hud + 1 // Ensure it's drawn on top
        
        // Assign this new shape to your existing touchAnchorNode property
        touchAnchorNode = shape
        
        
        // 1. Create the invisible "hand" (touchAnchorNode) IN THE WORLD.
        //touchAnchorNode = SKNode()
        touchAnchorNode?.position = location
        // --- THE FIX: Correct the typo here ---
        touchAnchorNode?.physicsBody = SKPhysicsBody(circleOfRadius: 1)
        touchAnchorNode?.physicsBody?.isDynamic = false
        
        // --- ADD THESE TWO LINES ---
        touchAnchorNode?.physicsBody?.categoryBitMask = PhysicsCategory.anchor
        touchAnchorNode?.physicsBody?.collisionBitMask = PhysicsCategory.none
        
        worldNode.addChild(touchAnchorNode!)

        // 2. Create the joint. Both the boulder and the "hand" are now in the worldNode.
        let joint = SKPhysicsJointSpring.joint(withBodyA: boulder.physicsBody!,
                                               bodyB: touchAnchorNode!.physicsBody!,
                                               anchorA: location,
                                               anchorB: location)
        joint.frequency = 8.0
        joint.damping = 2.0

        self.physicsWorld.add(joint)
        self.touchJoint = joint

        // 3. Update the boulder's state.
        boulder.isBeingHeld = true
        draggedBoulder = boulder
        startStrengthMeter()
    }

    func updateDrag(at location: CGPoint) {
        // The location is already in world space, so we can update the "hand" directly.
        touchAnchorNode?.position = location
    }

    func endDrag(on boulder: Boulder, at location: CGPoint, with timestamp: TimeInterval) {
        guard let joint = touchJoint else { return }
        
        // Calculate throw velocity using world coordinates.
        let timeSinceLastMove = timestamp - lastTouchTimestamp
        if timeSinceLastMove > 0 {
            let dx = location.x - lastTouchLocation.x
            let dy = location.y - lastTouchLocation.y
            let flickPower: CGFloat = 8.0
            let velocityX = dx / CGFloat(timeSinceLastMove) * flickPower
            let velocityY = dy / CGFloat(timeSinceLastMove) * flickPower
            boulder.physicsBody?.applyImpulse(CGVector(dx: velocityX, dy: velocityY))
        }
        
        // Clean up the joint and the anchor node.
        self.physicsWorld.remove(joint)
        touchAnchorNode?.removeFromParent()
        
//        let wait = SKAction.wait(forDuration: 5.0)
//        let fadeOut = SKAction.fadeOut(withDuration: 0.5)
//        let remove = SKAction.removeFromParent()
//        boulder.run(SKAction.sequence([wait, fadeOut, remove]))
        scheduleRemoval(for: boulder)
        
        boulder.isBeingHeld = false
        draggedBoulder = nil
        touchJoint = nil
        touchAnchorNode = nil
        
        stopStrengthMeter()
    }
    // In GameScene.swift

    private func scheduleRemoval(for boulder: Boulder) {
        if boulder.type == .golden {
            let wait = SKAction.wait(forDuration: 5.0)
            let fadeOut = SKAction.fadeOut(withDuration: 0.5)
            let remove = SKAction.removeFromParent()
            
            // --- THE FIX: Add a final cleanup step ---
            // This block of code will run after the boulder is removed from the screen.
            let cleanupAction = SKAction.run { [weak self] in
                // Tell the MagicManager to remove the boulder from its list.
                self?.magicManager.remove(boulder: boulder)
            }
            
            // Add the cleanup action to the end of the sequence.
            boulder.run(SKAction.sequence([wait, fadeOut, remove, cleanupAction]))
        }
    }
    
    // --- ADD STRENGTH METER FUNCTIONS (logic only for now) ---
    private func startStrengthMeter() {
        print("Strength meter started!")
        // Create a timer that will force-drop the boulder after 3 seconds
        let wait = SKAction.wait(forDuration: 3.0)
        let forceDrop = SKAction.run { [weak self] in
            self?.forceDropBoulder()
        }
        self.run(SKAction.sequence([wait, forceDrop]), withKey: "strengthMeter")
    }
    
    private func stopStrengthMeter() {
        self.removeAction(forKey: "strengthMeter")
        print("Strength meter stopped.")
    }
    
    private func forceDropBoulder() {
        if let boulder = draggedBoulder, let joint = touchJoint {
            print("Held for too long! Dropping boulder.")
            // Clean up without applying a throw impulse
            self.physicsWorld.remove(joint)
            touchAnchorNode?.removeFromParent()
            boulder.isBeingHeld = false
            draggedBoulder = nil
            touchJoint = nil
            touchAnchorNode = nil
            
//            let wait = SKAction.wait(forDuration: 3.0)
//            let fadeOut = SKAction.fadeOut(withDuration: 0.5)
//            let remove = SKAction.removeFromParent()
//            boulder.run(SKAction.sequence([wait, fadeOut, remove]))
            scheduleRemoval(for: boulder)
        }
    }

    
    
    
    // --- ADD NEW GAME STATE FUNCTIONS ---
    private func pauseGame() {
        self.isPaused = true
        pauseMenu.position = .zero // Move the menu to the center of the screen
    }
    
    private func resumeGame() {
        self.isPaused = false
        pauseMenu.position = CGPoint(x: -5000, y: -5000) // Move it off-screen again
    }
    
    private func restartGame() {
        self.removeAllActions()
//        self.removeAllChildren()
        
        gameOverMenu?.removeFromParent()
        // Unpause before transitioning to prevent scenes from getting stuck
        
        
//        guard let newGameScene = GameScene(fileNamed: "GameScene") else { return }
//        newGameScene.scaleMode = .aspectFill
//        let transition = SKTransition.fade(withDuration: 1.0)
//        view?.presentScene(newGameScene, transition: transition)
//        GameManager.shared.reset()
        
        //if let newGameScene = GameScene(fileNamed: "GameScene") {
        guard let view = self.view as? SKView else { return }
        let newGameScene = GameScene(levelData: levelData, size: view.bounds.size)
            newGameScene.scaleMode = .aspectFill
            newGameScene.gameDelegate = self.gameDelegate

            let transition = SKTransition.fade(withDuration: 1.0)
            view.presentScene(newGameScene, transition: transition)

            GameManager.shared.reset()
            
            // 👇 tell the delegate we restarted
            gameDelegate?.gameSceneDidRestart(newGameScene)
        //}
        self.isPaused = false

    }
    
    private func exitToMainMenu() {
        
        
        // --- THE FIX: Use the view's size ---
        // 1. Safely unwrap the view, because it's an optional.
//        guard let view = self.view else { return }
//        
//        // 2. Create the new scene using the view's bounds size.
//        let mainMenu = MainMenuScene(size: view.bounds.size)
//        // ------------------------------------
//        
//        mainMenu.scaleMode = .aspectFill
//        let transition = SKTransition.fade(withDuration: 1.0)
//        view.presentScene(mainMenu, transition: transition)
        
        
        GameManager.shared.reset()
        
        gameDelegate?.gameSceneDidRequestMainMenu(self)
        
        self.isPaused = false
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        collisionManager.handleContact(contact)
    }
    
    // --- ADD THIS NEW FUNCTION ---
    func didEnd(_ contact: SKPhysicsContact) {
        collisionManager.handleEndContact(contact)
    }
    
    
    // MARK: Tutorial Logic
    
//    /// Sets up the initial state of the tutorial UI.
//    private func setupTutorial() {
//        // Create a container for all tutorial UI
//        tutorialNode = SKNode()
//        tutorialNode.position = CGPoint(x: 0, y: 65) // Positioned above the player
//        tutorialNode.zPosition = ZPositions.hud
//        addChild(tutorialNode)
//        
//        // Create the semi-transparent background card
//        let card = SKShapeNode(rectOf: CGSize(width: 300, height: 120), cornerRadius: 10)
//        card.fillColor = .black.withAlphaComponent(0.7)
//        card.strokeColor = .clear
//        tutorialNode.addChild(card)
//        
//        // --- ADD THIS BLOCK to create the title ---
//        titleLabel = SKLabelNode(fontNamed: "Menlo-Bold")
//        titleLabel.text = "Tutorial"
//        titleLabel.fontSize = 22
//        titleLabel.fontColor = .green
//        // Position it at the top of the card
//        titleLabel.position = CGPoint(x: 0, y: 35)
//        tutorialNode.addChild(titleLabel)
//        // -----------------------------------------
//
//        
//        // Create the text label
//        tutorialLabel = SKLabelNode(fontNamed: "Menlo-Regular")
//        tutorialLabel.text = "Welcome to RockMagic! Let's learn the basics."
//        tutorialLabel.fontSize = 16
//        tutorialLabel.fontColor = .white
//        tutorialLabel.numberOfLines = 0
//        tutorialLabel.preferredMaxLayoutWidth = 280
//        tutorialLabel.verticalAlignmentMode = .center
//        tutorialNode.addChild(tutorialLabel)
//        
//        // Create the optional image node (initially hidden)
//        tutorialImage = SKSpriteNode()
//        tutorialImage.position = CGPoint(x: 200, y: -50) // Positioned above the text
//        tutorialImage.isHidden = true
//        tutorialNode.addChild(tutorialImage)
//        
//        // Create a "Skip" button (this part is the same)
//        skipButton = SKLabelNode(fontNamed: "Menlo-Regular")
//        skipButton.text = "Skip Tutorial"
//        skipButton.fontSize = 20
//        skipButton.fontColor = .cyan
//        //skipButton.position = CGPoint(x: size.width / 3, y: size.height / 3)
//        skipButton.position = CGPoint(x: 270, y: -150)
//        skipButton.zPosition = ZPositions.hud
//        skipButton.name = "skipButton"
//        addChild(skipButton)
//        
//        // --- ADD THE NEW "NEXT" BUTTON ---
//        // Create it once, but keep it hidden until a step is completed.
//        tutorialNextButton = SKLabelNode(fontNamed: "Menlo-Bold")
//        tutorialNextButton.text = "Next >"
//        tutorialNextButton.fontSize = 22
//        tutorialNextButton.fontColor = .gray
//        tutorialNextButton.position = CGPoint(x: 100, y: -40) // Positioned in the bottom-right of the card
//        tutorialNextButton.name = "tutorialNextButton"
//        //tutorialNextButton.isHidden = true // Start hidden
//        tutorialNode.addChild(tutorialNextButton)
//        
//        // Start the first step
//        completeTutorialStep()
//    }
//    
//    /// Moves the tutorial to the next step and updates the UI.
//    func advanceTutorial() {
//        
//        tutorialNextButton.fontColor = .gray
//        // Find the next step in our enum's list of cases.
//        if let currentIndex = TutorialStep.allCases.firstIndex(of: currentTutorialStep),
//           currentIndex + 1 < TutorialStep.allCases.count {
//            currentTutorialStep = TutorialStep.allCases[currentIndex + 1]
//        } else {
//            currentTutorialStep = .complete
//        }
//        
//        // Update the instruction image based on the new step.
//        switch currentTutorialStep {
//        case .welcome:
//            
//            tutorialLabel.text = "Welcome to RockMagic! Let's learn the basics."
//        case .moveRight:
//            titleLabel.text = "Movement"
//            tutorialLabel.text = "Use the joystick to move left and right."
//        case .jump:
//            titleLabel.text = "Jumping"
//            tutorialLabel.text = "Push the joystick up to jump."
//        case .swipeUp:
//            titleLabel.text = "Boulder Pull"
//            tutorialLabel.text = "Swipe Up to pull up a boulder from the ground"
//            // Example of showing an optional image for this step
//            tutorialImage.texture = SKTexture(imageNamed: "swipeArrow")
//            tutorialImage.size = CGSize(width: 350, height: 350) // Set a size for the icon
//            tutorialImage.isHidden = false
//        case .quickAttack:
//            magicManager.pullUpBoulder(position: CGPoint(x: player.worldPosition.x + 100, y: GameManager.shared.boulderFinalY))
//            titleLabel.text = "Quick Attack"
//            tutorialLabel.text = "Tap left/right side of the screen to shoot a rock piece"
//            tutorialImage.isHidden = true
//        case .strongAttack:
//            magicManager.pullUpBoulder(position: CGPoint(x: player.worldPosition.x + 100, y: GameManager.shared.boulderFinalY))
//            titleLabel.text = "Strong Attack"
//            tutorialLabel.text = "Swipe right/left to launch the closest boulder"
//            tutorialImage.zRotation = -.pi / 2
//            tutorialImage.isHidden = false
//        case .splashAttack:
//            magicManager.pullUpBoulder(position: CGPoint(x: player.worldPosition.x - 400, y: GameManager.shared.boulderFinalY))
//            titleLabel.text = "Splash Attack"
//            tutorialLabel.text = "Swipe down to launch a boulder for area damage."
//            tutorialImage.zRotation = .pi
//        case .littleRat:
//            enemiesManager.spawnSingleEnemy(type: .littleRat)
//            titleLabel.text = "Enemies"
//            tutorialLabel.text = "Litttle Rats dodge Strong attacks. Use your quick attack(TAP)!"
//            tutorialImage.isHidden = true
//        case .blocker:
//            enemiesManager.spawnSingleEnemy(type: .blocker)
//            titleLabel.text = "Enemies"
//            tutorialLabel.text = "Blocker shields block direct hits. Use a Splash Attack(Swipe Down) to break them!"
//        case .collectGem:
//            let gem = PickupNode(type: .coin)
//            gem.position = CGPoint(x: player.worldPosition.x + 100, y:GameManager.shared.groundLevel + 15)
//            self.worldNode.addChild(gem)
//            titleLabel.text = "Pick Ups"
//            tutorialLabel.text = "Collect Gems from Enemies to increase your score and level up!"
//        case .medPack:
//            player.currentHealth = 50
//            hud.updateHealthBar(currentHealth: CGFloat(player.currentHealth), maxHealth: CGFloat(GameManager.shared.playerMaxHealth))
//            let med = PickupNode(type: .health)
//            med.position = CGPoint(x: player.worldPosition.x + 100, y:GameManager.shared.groundLevel + 15)
//            self.worldNode.addChild(med)
//            
//            tutorialLabel.text = "Restore health only when damaged."
//        case .levelUp:
//            enemiesManager.spawnSingleEnemy(type: .normal)
//            GameManager.shared.currentScore = GameManager.shared.levelThresholdIncrements[0] - (GameManager.shared.normalEnemyValue + GameManager.shared.normalGemValue)
//            titleLabel.text = "Upgrades"
//            tutorialLabel.text = "When you level up, you get to choose an upgrade!"
//        case .finalMessage:
//            titleLabel.text = "Tutorial Complete"
//            tutorialLabel.text = "Time to use your ROCK MAGIC!"
//            completeTutorialStep()
//        case .complete:
//            isTutorialActive = false
//            GameManager.shared.reset()
//            enemiesManager.beginSpawning() // Tell the enemies to start
//            // The tutorial is over, so remove all its UI.
//            tutorialNode.removeFromParent()
//            skipButton.removeFromParent()
//        }
//    }
//    
//    // --- ADD THIS NEW FUNCTION ---
//    /// Called when the player completes the action for the current tutorial step.
//    /// This makes the "Next" button appear.
//    func completeTutorialStep() {
//        // Only show the button if the tutorial isn't over.
//        if currentTutorialStep != .complete {
//            tutorialNextButton.fontColor = .cyan
//        }
//    }
    
}




extension CGPoint {
    func distance(to point: CGPoint) -> CGFloat {
        return hypot(x - point.x, y - point.y)
    }
}

// In any Swift file, e.g., at the bottom of GameScene.swift

extension CGVector {
    /// Returns a new vector with the same direction and a length of 1.
    func normalized() -> CGVector {
        let length = sqrt(dx*dx + dy*dy)
        guard length != 0 else { return .zero }
        return CGVector(dx: dx / length, dy: dy / length)
    }
}



// Add this function outside of your GameScene class
func createCoordinateGrid(in scene: SKScene, step: Int) -> SKNode {
    let gridNode = SKNode()
    let width = Int(scene.frame.width)
    let height = Int(scene.frame.height)

    // Draw vertical lines
    for x in stride(from: -width / 2, to: width / 2, by: step) {
        let path = CGMutablePath()
        path.move(to: CGPoint(x: x, y: -height / 2))
        path.addLine(to: CGPoint(x: x, y: height / 2))
        
        let line = SKShapeNode(path: path)
        line.strokeColor = .lightGray
        line.lineWidth = 0.5
        line.alpha = 0.5
        gridNode.addChild(line)

        let label = SKLabelNode(fontNamed: GameManager.shared.fontName)
        label.text = "\(x)"
        label.fontSize = 12
        label.fontColor = .white
        label.position = CGPoint(x: x, y: 0)
        gridNode.addChild(label)
    }

    // Draw horizontal lines
    for y in stride(from: -height / 2, to: height / 2, by: step) {
        let path = CGMutablePath()
        path.move(to: CGPoint(x: -width / 2, y: y))
        path.addLine(to: CGPoint(x: width / 2, y: y))

        let line = SKShapeNode(path: path)
        line.strokeColor = .lightGray
        line.lineWidth = 0.5
        line.alpha = 0.5
        gridNode.addChild(line)
        
        let label = SKLabelNode(fontNamed: GameManager.shared.fontName)
        label.text = "\(y)"
        label.fontSize = 12
        label.fontColor = .white
        label.position = CGPoint(x: 0, y: y)
        gridNode.addChild(label)
    }
    
    gridNode.zPosition = 1000 // Ensure it's on top of everything
    return gridNode
}

// Add this function outside your GameScene class
func createWorldCoordinateGrid(worldSize: CGSize, step: Int) -> SKNode {
    let gridNode = SKNode()
    let width = Int(worldSize.width)
    let height = Int(worldSize.height)

    // The world's origin (0,0) is its center. We draw lines out from there.
    let halfWidth = width / 2
    let halfHeight = height / 2

    // Draw vertical lines
    for x in stride(from: -halfWidth, to: halfWidth, by: step) {
        let path = CGMutablePath()
        path.move(to: CGPoint(x: x, y: -halfHeight))
        path.addLine(to: CGPoint(x: x, y: halfHeight))

        let line = SKShapeNode(path: path)
        line.strokeColor = .darkGray // Use a different color
        line.lineWidth = 1.0
        line.alpha = 0.3
        gridNode.addChild(line)

        let label = SKLabelNode(fontNamed: "Menlo-Regular")
        label.text = "\(x)"
        label.fontSize = 16
        label.fontColor = .darkGray
        label.position = CGPoint(x: x, y: 0)
        gridNode.addChild(label)
    }

    // Draw horizontal lines
    for y in stride(from: -halfHeight, to: halfHeight, by: step) {
        let path = CGMutablePath()
        path.move(to: CGPoint(x: -halfWidth, y: y))
        path.addLine(to: CGPoint(x: width / 2, y: y))

        let line = SKShapeNode(path: path)
        line.strokeColor = .darkGray
        line.lineWidth = 1.0
        line.alpha = 0.3
        gridNode.addChild(line)
    }

    // Place it just above the background so it's visible but not intrusive
    gridNode.zPosition = ZPositions.background + 1
    return gridNode
}


enum JoystickFlickState {
    case neutral
    case primed // The joystick has been pushed down, ready for a flick up.
}





