//
//  MagicManager.swift
//  RockMagic
//
//  Created by Tucker Hoppe on 5/3/25.
//

import Foundation
import SpriteKit

enum LaunchDirection {
    case left
    case right
}

class MagicManager {
    
    private weak var scene: GameScene?
    private weak var player: PlayerNode?
    private var enemiesManager: EnemiesManager?
    private var currentBoulder: Boulder?
    var boulders: [Boulder] = []
    
    var magicBoundDistance: CGFloat = GameManager.shared.magicBoundaryDistance
    

    
    init(scene: GameScene, player: PlayerNode, enemiesManager: EnemiesManager){
        self.scene = scene
        self.player = player
        self.enemiesManager = enemiesManager
    }
    
    // --- ADD THIS NEW UPDATE FUNCTION ---
    func update() {
        // Loop through all boulders and call their update method
        for boulder in boulders {
            boulder.update()
        }
    }
    
    // In MagicManager.swift

    func pullUpBoulder(position: CGPoint, playAnimation: Bool = true) {
        // Check for stamina before doing anything
//        guard let player = player, player.useStamina(cost: GameManager.shared.summonBoulderCost) else {
//            print("Not enough stamina to summon!")
//            return
//        }
        guard let player = player else { return }
        // 1. Define the area where the boulder will appear in the world.
        let offset = position.x - 25
        let spot: CGFloat = setBendingBoundary(locationToCheck: offset)
        
        let boulderSize = CGSize(width: 50, height: 50)
        let boulderSpawnRect = CGRect(origin: CGPoint(x: spot - boulderSize.width / 2, y: GameManager.shared.boulderFinalY), size: boulderSize)
        
        if playAnimation {
            player.playAnimation(.summonBoulder)
        }
        
        
        // NO LONGER AFFECTS PLAYER DIRECTLY
//        // 2. Check if the player is in that area.
//        if let player = self.player, let scene = self.scene {
//            //player.playAnimation(.jump)
//            // --- THE FIX: Convert the origin point, then create a new rect ---
//            // First, convert the player's frame's origin from scene-space to world-space.
//            let playerOriginInWorld = scene.worldNode.convert(player.frame.origin, from: scene)
//            // Then, create a new frame in the world's coordinate system.
//            let playerFrameInWorld = CGRect(origin: playerOriginInWorld, size: player.frame.size)
//            
//            if boulderSpawnRect.intersects(playerFrameInWorld) {
//                // If they overlap, launch the player and stop.
//                player.launch(with: CGVector(dx: 0, dy: GameManager.shared.playerBoulderJumpForce))
//                //return // Exit the function early
//            }
//        }
        
        // 3. Check if any enemies are in that area.
        //var launchedAnEnemy = false
        if let enemies = enemiesManager?.enemies {
            for enemy in enemies {
                // An enemy's frame is already in world coordinates.
                if boulderSpawnRect.intersects(enemy.frame) {
                    let boulderCenter = CGPoint(x: boulderSpawnRect.midX, y: boulderSpawnRect.midY)
                    enemy.launchFromBelow(boulderPosition: boulderCenter)                    //launchedAnEnemy = true
                }
            }
        }
        
        // Give a 1 in 10 chance to spawn a golden boulder.
        let boulderType: BoulderType = (Int.random(in: 1...3) == 4) ? .golden : .normal
        
        // Create the boulder with the chosen type.
        let boulder = Boulder(type: boulderType)
        //boulder.gameScene = self.scene

        // Define the start and end points for the animation
        let finalYPosition: CGFloat = GameManager.shared.boulderFinalY
        let startYPosition: CGFloat = finalYPosition - 1000 // Start it lower, "in the ground"

        // Set the boulder's initial position
        boulder.position = CGPoint(x: spot, y: startYPosition)

        // Create the "move up" animation
        let finalPosition = CGPoint(x: spot, y: finalYPosition)
        let moveUpAction = SKAction.move(to: finalPosition, duration: 0.3)
        moveUpAction.timingMode = .easeOut // Makes the end of the animation smoother

        // Run the animation
        boulder.run(moveUpAction)

        // Add the boulder to the world and set up its physics
        scene?.worldNode.addChild(boulder)
        if let scene = scene {
            boulder.setupJoints(in: scene)
            //boulder.setupJoints()
        }
        boulders.append(boulder)
        
    }
    
    // In MagicManager.swift

    /// Creates a boulder specifically for the player's boulder jump.
    /// This version is simpler and doesn't check for collisions.
    func pullUpBoulderForJump(at position: CGPoint) {
        let boulderType: BoulderType = (Int.random(in: 1...10) == 11) ? .golden : .normal
        let boulder = Boulder(type: boulderType)
        
        // Use the position passed from the player
        let finalYPosition: CGFloat = -120
        let startYPosition: CGFloat = -180
        boulder.position = CGPoint(x: position.x, y: startYPosition)
        
        // Animate it rising from the ground
        let finalPosition = CGPoint(x: position.x, y: finalYPosition)
        let moveUpAction = SKAction.move(to: finalPosition, duration: 0.3)
        boulder.run(moveUpAction)
        
        // Add it to the world
        scene?.worldNode.addChild(boulder)
        if let scene = scene {
            boulder.setupJoints(in: scene)

        }
        boulders.append(boulder)
    }
    
    
    
    // In MagicManager.swift

    /// Creates a golden boulder directly in front of the player.
    func pullUpGoldenBoulderAtPlayer() {
        guard let player = player, let scene = scene else { return }
        
        // Check for full stamina before proceeding.
        guard player.currentStamina >= player.maxStamina else {
            print("Not enough stamina for golden boulder!")
            return
        }
        
        // Instantly use all stamina.
        //player.currentStamina = 0
        //(scene as? GameScene)?.playerUsedStamina()
        
        // Create a golden boulder.
        let boulder = Boulder(type: .golden)
        
        // Position it in front of the player.
        let direction: CGFloat = player.isFacingRight ? 1 : -1
        let spawnX = player.worldPosition.x + (50 * direction)
        boulder.position = CGPoint(x: spawnX, y: GameManager.shared.boulderFinalY)
        
        // Add it to the world.
        scene.worldNode.addChild(boulder)
        boulder.setupJoints(in: scene)
        boulders.append(boulder)
    }

    
    
    
//    private func setBendingBoundary(locationToCheck: CGFloat) -> CGFloat {
//        // Checks area between magic bounds
//        if locationToCheck < (player?.worldPosition.x)! + magicBoundDistance && locationToCheck > (player?.worldPosition.x)! - magicBoundDistance{
//            print("OH yeah")
//            
//            return locationToCheck
//            
//        } else if locationToCheck > (player?.worldPosition.x)! + magicBoundDistance { // Checks spot to the right
//            return (player?.worldPosition.x)! + magicBoundDistance - 25
//        } else { // otherwise to the left
//            return (player?.worldPosition.x)! - magicBoundDistance - 25
//        }
//    }
    
    private func setBendingBoundary(locationToCheck: CGFloat) -> CGFloat {
        // Safely unwrap the player and its position. If it fails, return the original location.
        guard let playerPositionX = player?.worldPosition.x else {
            print("Error: Player position could not be determined.")
            return locationToCheck
        }
        
        let worldWidth = scene!.size.width * 3
        print("MM World width: ", worldWidth)
        
        if locationToCheck > (worldWidth / 2) - 70{
            print("OUT OF BOUNDS RIGHT")
            return (worldWidth / 2) - 75
        } else if locationToCheck < -worldWidth / 2 {
            print("OUT OF BOUNDS Left")

            return -worldWidth / 2
        }
        
        // Checks area between magic bounds
        if locationToCheck < playerPositionX + magicBoundDistance && locationToCheck > playerPositionX - magicBoundDistance {
            
            return locationToCheck
            
        } else if locationToCheck > playerPositionX + magicBoundDistance{ // Checks spot to the right
            return playerPositionX + magicBoundDistance - 25
            
        } else { // otherwise to the left
            return playerPositionX - magicBoundDistance - 25
        }
    }

     func closestBoulder() -> Boulder? {
        guard let player = player else { return nil }

         let activeBoulders = boulders.filter { !$0.isDepleted && !$0.isBeingHeld && $0.type != .golden }

        return activeBoulders.min(by: {
            $0.position.distance(to: player.worldPosition) < $1.position.distance(to: player.worldPosition)
        })
    }


    
    /// Launches the whole boulder (remaining pieces)
        func launchBoulderOG(direction: CGVector) {
            currentBoulder = closestBoulder()
            currentBoulder?.launchAllRemainingPieces(direction: direction)
            
        }
    
    /// Shoots a single piece of the boulder
        func shootRockPieceOG(direction: CGVector) {
            currentBoulder = closestBoulder()
            currentBoulder?.launchSinglePiece(direction: direction)
            if currentBoulder?.isDepleted == true {
                currentBoulder = nil
            }
        }
    
    // In MagicManager.swift

    func launchBoulder(direction: LaunchDirection) {
        // Check for stamina
//        guard let player = player, player.useStamina(cost: GameManager.shared.launchBoulderCost) else {
//            print("Not enough stamina to launch!")
//            return
//        }
        currentBoulder = closestBoulder()
        guard let boulderToLaunch = currentBoulder else { return }
        
        // --- Proactive Hit Detection ---
        // 1. Define a "hitbox" in front of the boulder.
        let hitboxWidth: CGFloat = 30
        let hitboxHeight = boulderToLaunch.calculateAccumulatedFrame().height
        // --- THE FIX: Correctly calculate the hitbox's X position ---
        let boulderCenter = boulderToLaunch.position.x
        let hitboxX: CGFloat
        
        if direction == .right {
            // When facing right, the hitbox should start at the center of the boulder.
            hitboxX = boulderCenter
        } else { // direction == .left
            // When facing left, the hitbox should start to the left of the boulder.
            hitboxX = boulderCenter - hitboxWidth
        }
        
        let hitboxY = boulderToLaunch.position.y - (hitboxHeight / 2)
        let launchHitbox = CGRect(x: hitboxX, y: hitboxY, width: hitboxWidth, height: hitboxHeight)
        // ----------------------------------------------------------------
        
        // Draw the hitbox for debugging
        //(scene as? GameScene)?.drawDebugHitbox(rect: launchHitbox)

        // 2. Check for enemies inside this hitbox.
        if let enemies = enemiesManager?.enemies, let representativePiece = boulderToLaunch.pieces.first(where: { $0.isAttached }) {
            for enemy in enemies {
                if enemy.frame.intersects(launchHitbox) {
                    // 3. If an enemy is there, hit them directly, BYPASSING the velocity check.
                    enemy.getTossed(by: representativePiece, bypassVelocityCheck: true)
                    print("Bypassed!")
                }
            }
        }
        
        // 4. Apply the launch impulse as usual.
        // Apply the launch impulse as usual.
        let horizontalForce: CGFloat = GameManager.shared.launchBoulderForce
        let verticalForce: CGFloat = 500.0
        var launchVector: CGVector

        switch direction {
        case .left:
            launchVector = CGVector(dx: -horizontalForce, dy: verticalForce)
        case .right:
            launchVector = CGVector(dx: horizontalForce, dy: verticalForce)
        }
        boulderToLaunch.launchAllRemainingPieces(direction: launchVector)
    }

    func shootRockPiece(direction: LaunchDirection) {
        // Check for stamina
//        guard let player = player, player.useStamina(cost: GameManager.shared.shootPieceCost) else {
//            print("Not enough stamina to shoot!")
//            return
//        }
        guard let player = player else { return }
        
        currentBoulder = closestBoulder()
        guard let boulderToShoot = currentBoulder, let topPiece = boulderToShoot.pieces.last(where: { $0.isAttached }) else { return }
        
        // --- Apply the same fix here ---
        let hitboxWidth: CGFloat = 30
        let hitboxHeight = topPiece.calculateAccumulatedFrame().height
        
        // --- THE FIX: A more robust way to calculate the hitbox's X position ---
        let topPieceWorldPos = boulderToShoot.convert(topPiece.position, to: scene!.worldNode)
        let topPieceCenter = topPieceWorldPos.x

        let hitboxX: CGFloat
        if direction == .right {
            // When facing right, the hitbox should start at the center of the rock piece.
            hitboxX = topPieceCenter
        } else { // direction == .left
            // When facing left, the hitbox should start to the left of the rock piece.
            hitboxX = topPieceCenter - hitboxWidth
        }

        let hitboxY = topPieceWorldPos.y - (hitboxHeight / 2)

        let launchHitbox = CGRect(x: hitboxX, y: hitboxY, width: hitboxWidth, height: hitboxHeight)

        
        // --- ADD THIS LINE TO DRAW THE HITBOX ---
        //(scene as? GameScene)?.drawDebugHitbox(rect: launchHitbox)

        if let enemies = enemiesManager?.enemies {
            for enemy in enemies {
                if enemy.frame.intersects(launchHitbox) {
                    enemy.getTossed(by: topPiece, bypassVelocityCheck: true, isQuickStrike: true)
                }
            }
        }
        
        // Apply the launch impulse as usual.
        let horizontalForce: CGFloat = GameManager.shared.quickStrikeForce
        let verticalForce: CGFloat = 10.0
        var launchVector: CGVector

        switch direction {
        case .left:
            launchVector = CGVector(dx: -horizontalForce, dy: verticalForce)
        case .right:
            launchVector = CGVector(dx: horizontalForce, dy: verticalForce)
        }
         boulderToShoot.launchSinglePiece(direction: launchVector)
        
        // --- ADD THIS BLOCK TO FADE OUT THE DEPLETED BOULDER ---
        // After launching the piece, check if the boulder is now empty.
        if boulderToShoot.isDepleted {
            // Remove it from the array so it can't be targeted again.
            boulders.removeAll(where: { $0 === boulderToShoot })
            
            // Run the fade-out and remove sequence.
            let sequence = SKAction.sequence([SKAction.fadeOut(withDuration: 2.0), SKAction.removeFromParent()])
            boulderToShoot.run(sequence)

            // Clear the current boulder reference.
            currentBoulder = nil
        }
    }
    
    /// Safely removes a specific boulder from the internal tracking array.
    func remove(boulder: Boulder) {
        boulders.removeAll { $0 === boulder }
    }
    
    // In MagicManager.swift

    /// Launches the nearest boulder in a parabolic arc to a target location for a splash attack.
    func splashAttack(at targetLocation: CGPoint) {
        // 1. Find the nearest available boulder.
        guard let boulder = closestBoulder() else {
            print("No boulder available for splash attack.")
            return
        }
        
        // 2. Calculate the path for the parabolic arc.
        let startPoint = boulder.position
        // Use the swipe's X, but force the Y to be on the ground.
        let endPoint = CGPoint(x: targetLocation.x, y: GameManager.shared.groundLevel)
        
        // Control the height of the arc
        let controlPoint = CGPoint(x: (startPoint.x + endPoint.x) / 2, y: startPoint.y + 200)
        
        // Create a curved path for the boulder to follow
        let path = CGMutablePath()
        path.move(to: startPoint)
        path.addQuadCurve(to: endPoint, control: controlPoint)
        
        // 3. Create the actions for the boulder.
        let followPath = SKAction.follow(path, asOffset: false, orientToPath: false, duration: 0.7)
        followPath.timingMode = .easeInEaseOut
        
        // This action will run after the boulder lands.
        let createSplashDamage = SKAction.run { [weak self] in
            self?.createSplashHitbox(at: endPoint)
        }
        
        // 4. Create the final sequence and run it on the boulder.
        let sequence = SKAction.sequence([followPath, createSplashDamage])
        boulder.run(sequence)
        
        // 5. Remove the boulder from the tracking array immediately.
        //boulders.removeAll { $0 === boulder }
    }

    /// Creates a temporary hitbox to deal splash damage to nearby enemies.
    private func createSplashHitbox(at location: CGPoint) {
        guard let enemies = enemiesManager?.enemies else { return }
        
        let splashRadius: CGFloat = 100.0
        // --- ADD THIS BLOCK TO DRAW THE HITBOX ---
        if let scene = self.scene {
            let debugCircle = SKShapeNode(circleOfRadius: splashRadius)
            debugCircle.position = location
            debugCircle.strokeColor = .red
            debugCircle.lineWidth = 2
            debugCircle.zPosition = ZPositions.hud

            let fadeOut = SKAction.fadeOut(withDuration: 1.0)
            let remove = SKAction.removeFromParent()
            debugCircle.run(SKAction.sequence([fadeOut, remove]))
            
            scene.worldNode.addChild(debugCircle)
        }
        // ------------------------------------------
        
        for enemy in enemies {
            let distance = enemy.position.distance(to: location)
            if distance <= splashRadius {
                
                // --- THE FIX: Calculate the vector components manually ---
                let dx = enemy.position.x - location.x
                let dy = enemy.position.y - location.y
                let knockbackDirection = CGVector(dx: dx, dy: dy).normalized()
                // ----------------------------------------------------
                
                let knockbackForce: CGFloat = 100.0
                let impulse = CGVector(dx: knockbackDirection.dx * knockbackForce, dy: 100)
                
                enemy.physicsBody?.applyImpulse(impulse)
                enemy.takeDamage(amount: 20)
                
                enemy.shield = false
                
//                // --- THE FIX: We need a rockPiece to pass to getTossed ---
//                // Create a temporary, invisible rock piece to act as the source of the damage.
//                let dummyPiece = RockPiece(color: .clear, size: .zero)
//                
//                // Call getTossed with the new .splash attack type
//                enemy.getTossed(by: dummyPiece, bypassVelocityCheck: true, attackType: .splash)
            }
        }
    }
    
    // In MagicManager.swift
// MOST RECENT
//    func launchBoulder(direction: LaunchDirection) {
//        currentBoulder = closestBoulder()
//        guard let boulderToLaunch = currentBoulder else { return }
//
//        // --- THE FIX: Nudge the boulder just before launching ---
//        boulderToLaunch.nudge()
//        
//        let horizontalForce: CGFloat = GameManager.shared.launchBoulderForce
//        let verticalForce: CGFloat = 500.0
//        var launchVector: CGVector
//        
//        switch direction {
//        case .left:
//            launchVector = CGVector(dx: -horizontalForce, dy: verticalForce)
//        case .right:
//            launchVector = CGVector(dx: horizontalForce, dy: verticalForce)
//        }
//        // Use a guard to make sure a boulder was actually found
//        guard let boulderToLaunch = currentBoulder else { return }
//
//        //boulderToLaunch.launchAllRemainingPieces(direction: launchVector)
//        boulderToLaunch.launchAllPiecesWithNudge(direction: launchVector)
//    }
//
//    func shootRockPiece(direction: LaunchDirection) {
//        currentBoulder = closestBoulder()
//        var launchVector: CGVector
//        let horizontalForce: CGFloat = GameManager.shared.quickStrikeForce
//        let verticalForce: CGFloat = 5.0
//        
//        switch direction {
//        case .left:
//            launchVector = CGVector(dx: -horizontalForce, dy: verticalForce)
//        case .right:
//            launchVector = CGVector(dx: horizontalForce, dy: verticalForce)
//        }
//        
//        // Use a guard here as well
//        guard let boulderToShoot = currentBoulder else { return }
//        
//        //boulderToShoot.launchSinglePiece(direction: launchVector)
//        boulderToShoot.launchSinglePieceWithNudge(direction: launchVector)
//        
//        if boulderToShoot.isDepleted {
//            // Remove from the tracking array
//            boulders.removeAll(where: { $0 === boulderToShoot })
//            
//            // You can optionally fade it out before removing
//            let sequence = SKAction.sequence([SKAction.fadeOut(withDuration: 2.0), SKAction.removeFromParent()])
//            boulderToShoot.run(sequence)
//
//            currentBoulder = nil
//        }
//    }
    
    
}
