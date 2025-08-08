//
//  GameScene.swift
//  RockMagic
//
//  Created by Tucker Hoppe on 4/28/25.
//

import SpriteKit

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
    
    private var pauseMenu: PauseMenuNode!
    
    // --- WITH THIS NEW STATE PROPERTY ---
    private var flickState: JoystickFlickState = .neutral
    private var flickPrimeTime: TimeInterval = 0

    
    // --- ADD HEALTH BAR NODES ---
//    private var playerHealthBarBackground: SKShapeNode!
//    private var playerHealthBar: SKShapeNode!
//    private let healthBarWidth: CGFloat = 200
//    private let healthBarHeight: CGFloat = 20
//    // This will hold both the label and the health bar
//    private var healthBarContainer: SKNode!
    
    // --- ADD HUD AND SCORE PROPERTIES ---
    private var hud: HUDNode!
    private var score = 0
    
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
    
    // --- 2. DEFINE MOVEMENT PROPERTIES ---
    private let playerMoveSpeed: CGFloat = GameManager.shared.playerMoveSpeed
    private let centerScreenArea: CGFloat = GameManager.shared.centerScreenArea
    private var screenBoundaryLeft: CGFloat!
    private var screenBoundaryRight: CGFloat!
    
    private var highlightedBoulder: Boulder?
    
    private var joystickTouch: UITouch?
    
    /// Tracks if the joystick was pointing down in the previous frame.
    private var wasJoystickPointingDown = false
    
    
    override func didMove(to view: SKView) {
        backgroundColor = .cyan
        GameManager.shared.scene = self // Give the manager a reference to the scene
        
        GameManager.shared.reset()
        // --- THE FIX: Use the view's size for the HUD ---
        // Safely unwrap the view to get its dimensions
        guard let view = self.view else { return }
        
        // --- 3. INITIALIZE THE WORLD NODE ---
        worldNode = SKNode()
        addChild(worldNode)
        
        // --- ADD THIS BLOCK FOR THE WORLD GRID ---
        // 1. Define the size of your game world. Let's make it 3 screens wide.
        let worldWidth = self.size.width * 3
        let worldHeight = self.size.height
        let worldSize = CGSize(width: worldWidth, height: worldHeight)

        // 2. Create the grid and add it to the worldNode so it scrolls
        let worldGrid = createWorldCoordinateGrid(worldSize: worldSize, step: 50)
        worldNode.addChild(worldGrid)
        
        
        hud = HUDNode(sceneSize: view.bounds.size)
        //print(self.size)
        hud.zPosition = ZPositions.hud
        addChild(hud) // Add to scene, NOT worldNode
       
        // Define the screen boundaries for scrolling
        screenBoundaryLeft = -self.size.width / 4
        screenBoundaryRight = self.size.width / 4
        
        
        setupManager = SetupManager(scene: self)
        setupManager.setupAll(view: view)
        
        //setupPlayerHealthBar()
        // --- ADD THIS FOR THE DEBUG GRID ---
        let grid = createCoordinateGrid(in: self, step: 50)
        //addChild(grid)
        
        // Create the Pause Menu
        pauseMenu = PauseMenuNode(size: self.size)
        pauseMenu.position = CGPoint(x: -5000, y: -5000)
        pauseMenu.zPosition = ZPositions.hud + 10
        addChild(pauseMenu) // Add directly to the scene

    }
    
    
    // --- ADD NEW CALLBACK FUNCTIONS ---
    func playerTookDamage() {
        hud.updateHealthBar(currentHealth: CGFloat(player.currentHealth), maxHealth: CGFloat(player.maxHealth))
    }
    
    func enemyDefeated() {
        score += 1
        hud.updateScore(newScore: score)
    }
    
    // --- ADD THIS NEW FUNCTION ---
    func showGameOverMenu() {
        // Pause the game to stop all action
        self.isPaused = true
        
        // Create the menu, passing in the final score
        gameOverMenu = GameOverNode(size: self.size, score: self.score)
        gameOverMenu.zPosition = ZPositions.hud + 20 // Ensure it's on top of everything
        addChild(gameOverMenu)
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
    
//    override func update(_ currentTime: TimeInterval) {
//        player.updateMovement(joystickVelocity: joystick.velocity)
//        //updateEnemies(enemies: enemies)
//        enemiesManager.updateEnemies(target: player)
//        magicManager.update()
//        
//        // --- MANAGE THE HIGHLIGHT ---
//        let closest = magicManager.closestBoulder()
//
//        if closest !== highlightedBoulder {
//            highlightedBoulder?.setHighlight(active: false)
//            // Highlight the new one
//            closest?.setHighlight(active: true)
//            // Update our tracker
//            highlightedBoulder = closest
//        }
//        for node in self.children {
//            
//            if let rock = node as? RockPiece {
//                rock.update()
//            }
//        }
//
//    }
    
    // In GameScene.swift

//    private func setupPlayerHealthBar() {
//        // Create the background bar
//        playerHealthBarBackground = SKShapeNode(rectOf: CGSize(width: healthBarWidth, height: healthBarHeight), cornerRadius: 5)
//        playerHealthBarBackground.fillColor = .darkGray
//        playerHealthBarBackground.strokeColor = .black
//        playerHealthBarBackground.lineWidth = 2
//        
//        // --- THE FIX: A more reliable way to position the health bar ---
//        // Start from the top-left corner of the visible frame and add some padding.
//        let xPos = self.frame.minX + healthBarWidth/2 + 20 // 20 points of padding from the left
//        let yPos = self.frame.minY - healthBarHeight/2 - 20 // 20 points of padding from the top
//        print(xPos)
//        print(yPos)
//        playerHealthBarBackground.position = CGPoint(x: 0, y: 0)
//        // -------------------------------------------------------------
//        
//        playerHealthBarBackground.zPosition = ZPositions.hud
//        addChild(playerHealthBarBackground) // Add to scene, NOT worldNode
//
//        // Create the foreground bar
//        playerHealthBar = SKShapeNode(rectOf: CGSize(width: healthBarWidth, height: healthBarHeight), cornerRadius: 5)
//        playerHealthBar.fillColor = .green
//        playerHealthBar.strokeColor = .clear
//        playerHealthBar.position = .zero
//        playerHealthBar.zPosition = playerHealthBarBackground.zPosition + 1
//        playerHealthBarBackground.addChild(playerHealthBar)
//    }
//    
//    // --- ADD HEALTH BAR UPDATE FUNCTION ---
//    func updatePlayerHealthBar() {
//        let healthPercentage = CGFloat(player.currentHealth) / CGFloat(player.maxHealth)
//        
//        let scaleAction = SKAction.scaleX(to: healthPercentage, duration: 0.2)
//        let newXPosition = -((healthBarWidth * (1 - healthPercentage)) / 2)
//        let moveAction = SKAction.moveTo(x: newXPosition, duration: 0.2)
//        
//        playerHealthBar.run(SKAction.group([scaleAction, moveAction]))
//    }
    
    // --- 4. NEW MOVEMENT LOGIC IN UPDATE ---
    override func update(_ currentTime: TimeInterval) {
        // --- ADD THIS BLOCK AT THE TOP OF THE UPDATE FUNCTION ---
                
        // Calculate the time elapsed since the last frame (deltaTime)
        if lastUpdateTime == 0 {
            lastUpdateTime = currentTime
        }
        let deltaTime = currentTime - lastUpdateTime
        lastUpdateTime = currentTime
        
        // Update the shared GameManager instance
        GameManager.shared.update(deltaTime: deltaTime)
        
        let joystickVelocity = joystick.velocity
        
        // Horizontal Movement & Animation
        if player.action(forKey: "action") == nil {
            if joystickVelocity.dx != 0 {
                player.playAnimation(.walk)
                player.updateFacingDirection(joystickVelocity: joystickVelocity)
            } else {
                player.playAnimation(.idle)
            }
        }
        
        
        if joystickVelocity.dx > 0 { // Moving Right
            //print(player.position.x)
            player.isWalking = true
            if player.worldPosition.x < 825 && (player.position.x < centerScreenArea && player.position.x > -centerScreenArea){
                
                worldNode.position.x -= playerMoveSpeed
                farBackgroundNode.position.x -= playerMoveSpeed * 0.2
                midBackgroundNode.position.x -= playerMoveSpeed * 0.5
            } else { // On the right edge of the screen
                player.position.x += playerMoveSpeed
            }
            
        } else if joystickVelocity.dx < 0 { // Moving Left
            player.isWalking = true
            if player.worldPosition.x > -825 && (player.position.x < centerScreenArea && player.position.x > -centerScreenArea){
                worldNode.position.x += playerMoveSpeed
                farBackgroundNode.position.x += playerMoveSpeed * 0.2
                midBackgroundNode.position.x += playerMoveSpeed * 0.5
            } else { // On the left edge of the screen
                player.position.x -= playerMoveSpeed
            }
            
        } else {
            player.isWalking = false
        }
        
        
        
        
        
        // --- REVISED Vertical (Jump) Movement ---
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
        
        
        player.worldPosition.x = player.position.x - worldNode.position.x
        // Update enemies and managers
        enemiesManager.updateEnemies(target: player)
        magicManager.update()
        
        // Highlight logic (no changes needed here)
        let closest = magicManager.closestBoulder()
        if closest !== highlightedBoulder {
            highlightedBoulder?.setHighlight(active: false)
            closest?.setHighlight(active: true)
            highlightedBoulder = closest
        }
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
            
            // --- THE FIX: Check distance to joystick, not frame ---
            // Calculate the distance from the touch to the center of the joystick.
            let distanceToJoystick = joystick.position.distance(to: location)
            
            // If the touch is within the joystick's larger activation radius...
            if distanceToJoystick <= joystick.touchAreaRadius && joystickTouch == nil {
                // ...claim this touch for the joystick.
                joystickTouch = touch
                joystick.update(at: touch.location(in: joystick))
                return // Stop processing other touches
            }
        }
        
        // If the touch wasn't for the joystick, check for menu buttons.
        guard let touch = touches.first else { return }
        let tappedNode = self.atPoint(touch.location(in: self))
        
        if tappedNode.name == "pauseButton" {
            pauseGame()
        } else if tappedNode.name == "resumeButton" {
            resumeGame()
        } else if tappedNode.name == "restartButton" {
            restartGame()
        } else if tappedNode.name == "exitButton" {
            exitToMainMenu()
        } else if tappedNode.name == "instructionsButton" {
            pauseMenu.showInstructions()
        } else if tappedNode.name == "backButton" {
            pauseMenu.hideInstructions()
        }
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        // If we are tracking a touch for the joystick, update it.
        if let touch = joystickTouch {
            joystick.update(at: touch.location(in: joystick))
        }
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        // If the touch that was lifted is the one controlling the joystick, reset it.
        if let touch = joystickTouch, touches.contains(touch) {
            joystick.reset()
            joystickTouch = nil // Stop tracking
        }
    }

    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        // This handles cases like an incoming phone call.
        if let touch = joystickTouch, touches.contains(touch) {
            joystick.reset()
            joystickTouch = nil
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
        // Unpause before transitioning to prevent scenes from getting stuck
        self.isPaused = false
        
        guard let newGameScene = GameScene(fileNamed: "GameScene") else { return }
        newGameScene.scaleMode = .aspectFill
        let transition = SKTransition.fade(withDuration: 1.0)
        view?.presentScene(newGameScene, transition: transition)
        GameManager.shared.reset()
    }
    
    private func exitToMainMenu() {
        self.isPaused = false
        
        // --- THE FIX: Use the view's size ---
        // 1. Safely unwrap the view, because it's an optional.
        guard let view = self.view else { return }
        
        // 2. Create the new scene using the view's bounds size.
        let mainMenu = MainMenuScene(size: view.bounds.size)
        // ------------------------------------
        
        mainMenu.scaleMode = .aspectFill
        let transition = SKTransition.fade(withDuration: 1.0)
        view.presentScene(mainMenu, transition: transition)
        GameManager.shared.reset()
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        collisionManager.handleContact(contact)
    }
    
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

        let label = SKLabelNode(fontNamed: "Menlo-Regular")
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
        
        let label = SKLabelNode(fontNamed: "Menlo-Regular")
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
