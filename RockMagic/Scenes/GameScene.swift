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
    
    var testWorldNode: SKNode!
    
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
        
        testWorldNode = createWorldCoordinateGrid(worldSize: worldSize, step: 50)
        addChild(testWorldNode) // Add it directly to the scene
        
        
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
    
    /// Adds a specified amount to the player's score and updates the HUD.
    func addScore(amount: Int) {
        score += amount
        hud.updateScore(newScore: score)
    }
    
    func enemyDefeated() {
        addScore(amount: 1)
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
        
        // --- ADD THIS BLOCK to handle stamina drain during drag ---
        if let _ = draggedBoulder {
            let hasStamina = player.drainStamina(deltaTime: deltaTime)
            if !hasStamina {
                // If the player runs out of stamina, force them to drop the boulder.
                forceDropBoulder()
            }
        }
        
        let joystickVelocity = joystick.velocity
        
        // --- ADD THIS LINE ---
        player.regenerateStamina(deltaTime: deltaTime)
        
        
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
                // FOR DEBUGGING
                testWorldNode.position.x -= playerMoveSpeed
                
                worldNode.position.x -= playerMoveSpeed
                farBackgroundNode.position.x -= playerMoveSpeed * 0.2
                midBackgroundNode.position.x -= playerMoveSpeed * 0.5
            } else { // On the right edge of the screen
                player.position.x += playerMoveSpeed
            }
            
        } else if joystickVelocity.dx < 0 { // Moving Left
            player.isWalking = true
            if player.worldPosition.x > -825 && (player.position.x < centerScreenArea && player.position.x > -centerScreenArea){
                // FOR DEBUGGING
                testWorldNode.position.x += playerMoveSpeed
                
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
            
            // --- THE FIX: Check distance to the joystick's position ---
            let distanceToJoystick = joystick.position.distance(to: location)
            
            if distanceToJoystick <= joystick.touchAreaRadius && joystickTouch == nil {
                joystickTouch = touch
                joystick.update(at: touch.location(in: joystick))
                continue
            }
    
            
            
            
            // 2. Check for menu buttons.
            let tappedNode = self.atPoint(location)
            if tappedNode.name != nil && tappedNode.name != "ground" {
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
                } else if tappedNode.name == "goldenBoulderButton" {
                    magicManager.pullUpGoldenBoulderAtPlayer()
                }
            }
            
            
            

            
            // 3. If it's not for the joystick or a menu, it's a gameplay touch.
            if gameplayTouch == nil {
                gameplayTouch = touch
                let locationInWorld = touch.location(in: worldNode)
                let locationInScene = touch.location(in: self)
                inputManager.touchesBegan(at: locationInWorld, screenLocation: locationInScene, timestamp: touch.timestamp)
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
    
    // In GameScene.swift

    // --- ADD THESE THREE NEW HELPER FUNCTIONS ---
    

    // In GameScene.swift

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
