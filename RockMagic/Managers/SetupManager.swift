//
//  SetupManager.swift
//  RockMagic
//
//  Created by Tucker Hoppe on 7/17/25.
//

import SpriteKit
import Foundation

class SetupManager {
    unowned let scene: GameScene
    
    init(scene: GameScene) {
        self.scene = scene
    }
    
    func setupAll(view: SKView) {
        //setupBackground()
        setupParallaxBackgrounds()
        setupPhysics()
        setupCollissions()
        setupPlayer()
        setupGround()
        setupJoystick()
        
        setupEnemies()
        setupInput(view: view)
        setupMagic()
        
        setupWorldBoundaries()
    }
    
    private func setupPhysics() {
        scene.physicsWorld.contactDelegate = scene
    }
    
    private func setupCollissions() {
        let collisionManager = CollisionManager(scene: scene)
        scene.collisionManager = collisionManager
    }
    
    private func setupPlayer() {
        let player = PlayerNode()
        player.position = CGPoint(x: GameManager.shared.playerStartX, y: GameManager.shared.playerStartY)
        player.zPosition = ZPositions.player
        player.worldPosition = player.position
        scene.player = player
        scene.addChild(player) // Child of Scene
        
        print("player start x: ", GameManager.shared.playerStartX)
        print("Center Screen AreaR: ", GameManager.shared.centerScreenAreaR)
        print("Center Screen AreaL: ", GameManager.shared.centerScreenAreaL)
    }
    

    private func setupParallaxBackgrounds() {
        // Initialize the nodes
        scene.farBackgroundNode = SKNode()
        scene.midBackgroundNode = SKNode()
        
        scene.addChild(scene.farBackgroundNode)
        scene.addChild(scene.midBackgroundNode)
        
        // --- Far Layer (Distant Mountains) ---
        let farTexture = SKTexture(imageNamed: "niceGreenBackground")
        // Use many tiles to create a super-wide background that never runs out
        let numberOfFarTiles = 20
        
        for i in 0..<numberOfFarTiles {
            let tile = SKSpriteNode(texture: farTexture)
            
            // --- THE FIX for SIZE ---
            // Make the image much smaller (e.g., 30% of screen height)
            let scaleFactor = (scene.size.height / tile.size.height) * 0.2
            tile.setScale(scaleFactor)
            
            // Lay the tiles side-by-side
            let tileX = (tile.size.width * CGFloat(i)) - (tile.size.width * CGFloat(numberOfFarTiles) / 2)
            tile.position = CGPoint(x: tileX, y: 40) // Position near the horizon
            tile.zPosition = ZPositions.background - 2
            scene.farBackgroundNode.addChild(tile)
        }
        
        // --- Mid Layer (Closer Hills) ---
        let midTexture = SKTexture(imageNamed: "background")
        let numberOfMidTiles = 20
        
        for i in 0..<numberOfMidTiles {
            let tile = SKSpriteNode(texture: midTexture)
            
            // --- THE FIX for SIZE ---
            // Make this layer a bit larger (e.g., 50% of screen height)
            let scaleFactor = (scene.size.height / tile.size.height) * 0.2
            tile.setScale(scaleFactor)
            
            // Lay the tiles side-by-side
            let tileX = (tile.size.width * CGFloat(i)) - (tile.size.width * CGFloat(numberOfMidTiles) / 2)
            tile.position = CGPoint(x: tileX, y: 0) // Position slightly lower than the far layer
            tile.zPosition = ZPositions.background - 1
            //scene.midBackgroundNode.addChild(tile)
        }
    }
    
    
    // --- ADD THIS NEW FUNCTION ---
    private func setupBackground() {
        // 1. Replace "YourBackgroundImageName" with your actual image asset name.
        let backgroundTexture = SKTexture(imageNamed: "background")
        
        // 2. Make the background wide enough to cover the entire world.
        let worldWidth = scene.size.width * 3
        let background = SKSpriteNode(texture: backgroundTexture, size: CGSize(width: worldWidth, height: scene.size.height))
        
        // 3. Position it in the center of the world.
        background.position = CGPoint(x: 0, y: 0)
        
        // 4. Place it behind everything else.
        background.zPosition = ZPositions.background
        
        // 5. Add it to the worldNode so it scrolls.
        scene.worldNode.addChild(background)
    }
    
    // EVENTUALLY GO IN A SETUP ENVIORMNT Manager?
    private func setupGroundOG() {
        // Define your new lighter brown color
        let lightBrown = UIColor(red: 0.82, green: 0.71, blue: 0.55, alpha: 1.0) // This is a "Tan" color

        let groundHeight: CGFloat = GameManager.shared.groundHeight
        let ground = SKSpriteNode(color: lightBrown, size: CGSize(width: scene.frame.width * 3, height: groundHeight))
        //ground.anchorPoint = CGPoint(x: 0.5, y: 1.0) // Sets the anchor to the top-center
        ground.position = CGPoint(x: scene.frame.midX, y: GameManager.shared.groundY)
        ground.zPosition = 1
        ground.name = "ground"
        
        ground.physicsBody = SKPhysicsBody(rectangleOf: ground.size)
        ground.physicsBody?.isDynamic = false
        ground.physicsBody?.categoryBitMask = PhysicsCategory.ground
        ground.physicsBody?.contactTestBitMask = PhysicsCategory.enemy
        ground.physicsBody?.collisionBitMask = PhysicsCategory.enemy | PhysicsCategory.player
        
        scene.worldNode.addChild(ground)
    }
    
    private func setupGround() {
        let groundHeight: CGFloat = GameManager.shared.groundHeight
        let worldWidth = scene.size.width * 3

        let ground = SKNode()
        ground.position = CGPoint(x: 0, y: GameManager.shared.groundY)
        ground.zPosition = 1
        
        ground.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: worldWidth, height: groundHeight))
        ground.physicsBody?.isDynamic = false
        ground.physicsBody?.categoryBitMask = PhysicsCategory.ground
        ground.physicsBody?.collisionBitMask = PhysicsCategory.enemy | PhysicsCategory.player
        
        let groundTexture = SKTexture(imageNamed: "groundTextureB")
        
        let desiredTileWidth: CGFloat = 100.0
        let scaleFactor = desiredTileWidth / groundTexture.size().width
        
        let actualTileWidth = groundTexture.size().width * scaleFactor
        let numberOfTiles = Int(ceil(worldWidth / actualTileWidth))
        
        for i in 0...numberOfTiles {
            let tile = SKSpriteNode(texture: groundTexture)
            tile.anchorPoint = .zero
            tile.setScale(scaleFactor)
            
            // --- THE FIX: Multiply the width by a value less than 1 ---
            // Using 0.95 will make each tile overlap the last one by 5%.
            let overlapFactor: CGFloat = 1.0
            let xPos = (actualTileWidth * overlapFactor) * CGFloat(i) - (worldWidth / 2)
            tile.position = CGPoint(x: xPos, y: -groundHeight / 2)
            
            ground.addChild(tile)
        }
        
        scene.worldNode.addChild(ground)
    }
    
    // --- ADD THIS ENTIRE NEW FUNCTION ---
    private func setupWorldBoundaries() {
        // We'll use the world size defined in GameScene to place the pillars.
        // Let's assume the world is 3 screens wide for this example.
        let worldWidth = scene.size.width * 3
        print("SetupM World width: ", worldWidth)
        let pillarSize = CGSize(width: 50, height: scene.size.height * 2)
        
        // --- Left Pillar ---
        let leftPillar = SKSpriteNode(color: .darkGray, size: pillarSize)
        leftPillar.position = CGPoint(x: -worldWidth / 2, y: 0)
        leftPillar.zPosition = ZPositions.ground
        
        leftPillar.physicsBody = SKPhysicsBody(rectangleOf: pillarSize)
        leftPillar.physicsBody?.isDynamic = false // Makes it immovable
        leftPillar.physicsBody?.categoryBitMask = PhysicsCategory.wall
        // It collides with everything that moves
        leftPillar.physicsBody?.collisionBitMask = PhysicsCategory.player | PhysicsCategory.enemy | PhysicsCategory.boulder | PhysicsCategory.rockPiece
        
        scene.worldNode.addChild(leftPillar)
        
        // --- Right Pillar ---
        let rightPillar = SKSpriteNode(color: .darkGray, size: pillarSize)
        rightPillar.position = CGPoint(x: worldWidth / 2, y: 0)
        rightPillar.zPosition = ZPositions.ground
        
        rightPillar.physicsBody = SKPhysicsBody(rectangleOf: pillarSize)
        rightPillar.physicsBody?.isDynamic = false // Makes it immovable
        rightPillar.physicsBody?.categoryBitMask = PhysicsCategory.wall
        // It collides with everything that moves
        rightPillar.physicsBody?.collisionBitMask = PhysicsCategory.player | PhysicsCategory.enemy | PhysicsCategory.boulder | PhysicsCategory.rockPiece
        
        scene.worldNode.addChild(rightPillar)
    }
    
    private func setupJoystick() {
        let joystick = Joystick()
        joystick.position = CGPoint(x: -250, y: -75)
        joystick.zPosition = 100
        scene.joystick = joystick
        scene.addChild(joystick)
    }
    
    private func setupMagic() {
        scene.magicManager = MagicManager(scene: scene, player: scene.player, enemiesManager: scene.enemiesManager)
    }

    private func setupEnemies() {
        let enemiesManager = EnemiesManager(scene: scene)
        scene.enemiesManager = enemiesManager
        //enemiesManager.startSpawningEnemies()
    }
    
    
    func setupInput(view: SKView) {
        scene.inputManager = InputManager(scene: scene)
    }
    
}
