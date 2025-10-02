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
    private var pillars: [PillarNode] = []
    
    var magicBoundDistance: CGFloat = GameManager.shared.magicBoundaryDistance
    
    init(scene: GameScene, player: PlayerNode, enemiesManager: EnemiesManager){
        self.scene = scene
        self.player = player
        self.enemiesManager = enemiesManager
    }
    
    // --- UPDATE FUNCTION ---
    func update() {
        // update each boulder
        for boulder in boulders {
            boulder.update()
        }
        
        // update each pillar
        for pillar in pillars {
            pillar.update()
        }
        
        // Clean up any destroyed pillars from the tracking array.
        pillars.removeAll { $0.parent == nil }
    }
    

    // MARK: - Summoning
    
    func pullUpBoulder(position: CGPoint, playAnimation: Bool = true) {
        guard let player = player else { return }
        // Define the area where the boulder will appear in the world.
        let offset = position.x - 25
        let spot: CGFloat = setBendingBoundary(locationToCheck: offset)
        
        let boulderSize = CGSize(width: 50, height: 50)
        let boulderSpawnRect = CGRect(origin: CGPoint(x: spot - boulderSize.width / 2, y: GameManager.shared.boulderFinalY), size: boulderSize)
        
        if playAnimation {
            player.playAnimation(.summonBoulder)
        }

        // 3. Check if any enemies are in that area.

        if let enemies = enemiesManager?.enemies {
            for enemy in enemies {
                // An enemy's frame is already in world coordinates.
                if boulderSpawnRect.intersects(enemy.frame) {
                    let boulderCenter = CGPoint(x: boulderSpawnRect.midX, y: boulderSpawnRect.midY)
                    enemy.launchFromBelow(boulderPosition: boulderCenter)                    //launchedAnEnemy = true
                }
            }
        }
        
        
        // Create the boulder with the chosen type.
        let boulder = Boulder(type: .normal)

        // Define the start and end points for the animation
        let finalYPosition: CGFloat = GameManager.shared.boulderFinalY
        let startYPosition: CGFloat = finalYPosition - 1000 // Start it lower, "in the ground"

        // Set the boulder's initial position
        boulder.position = CGPoint(x: spot, y: startYPosition)

        // Create the "move up" animation
        let finalPosition = CGPoint(x: spot, y: finalYPosition)
        let moveUpAction = SKAction.move(to: finalPosition, duration: 0.3)
        moveUpAction.timingMode = .easeOut // Makes the end of the animation smoother
        EffectManager.shared.playBoulderSummonEffect(at: finalPosition)
        // Run the animation
        boulder.run(moveUpAction)
        // We play it at the final position where the boulder will land.
        
        EffectManager.shared.playBoulderSummonEffect(at: finalPosition)
        // Add the boulder to the world and set up its physics
        scene?.worldNode.addChild(boulder)
        if let scene = scene {
            boulder.setupJoints(in: scene)
            //boulder.setupJoints()
        }
        boulders.append(boulder)
        
    }
    
    func pullUpPillar(at: CGPoint) -> PillarNode{
        // sets position
        let pillar = PillarNode()
        pillar.position.x = at.x
        
        scene?.pillarBeingPulled = pillar
        scene?.worldNode.addChild(pillar)
        
        pillars.append(pillar)
        
        // Check if the new pillar puts us over the limit.
        if pillars.count > GameManager.shared.maxPillarCount {
            // If yes, destroy the oldest pillar (the first one in the array)
            let oldestPillar = pillars.removeFirst()
            oldestPillar.destroy()
        }
        
        player?.playAnimation(.pullPillar)
        
        
        return pillar
        
    }
    

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
        
        // We play it at the final position where the boulder will land.
        EffectManager.shared.playBoulderSummonEffect(at: finalPosition)
        // Add it to the world
        scene?.worldNode.addChild(boulder)
        if let scene = scene {
            boulder.setupJoints(in: scene)

        }
        boulders.append(boulder)
    }


 
    // MARK: - Attacks

    func launchBoulder(direction: LaunchDirection) {

        currentBoulder = closestBoulder()
        guard let boulderToLaunch = currentBoulder else { return }
        
        // --- ADD THIS LINE to play the effect ---
        EffectManager.shared.playStrongAttackEffect(at: boulderToLaunch.position, direction: direction, level: GameManager.shared.strongAttackLevel)
            
        // --- Proactive Hit Detection ---
        //  Define a "hitbox" in front of the boulder.
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
        currentBoulder = closestBoulder()
        guard let boulderToShoot = currentBoulder, let topPiece = boulderToShoot.pieces.last(where: { $0.isAttached }) else { return }
        
        // --- Apply the same fix here ---
        let hitboxWidth: CGFloat = 30
        let hitboxHeight = topPiece.calculateAccumulatedFrame().height
        
        // --- THE FIX: A more robust way to calculate the hitbox's X position ---
        let topPieceWorldPos = boulderToShoot.convert(topPiece.position, to: scene!.worldNode)
        let topPieceCenter = topPieceWorldPos.x
        
        // --- ADD THIS LINE to play the effect ---
        EffectManager.shared.playQuickStrikeEffect(at: topPieceWorldPos, direction: direction, level: GameManager.shared.quickAttackLevel)
        
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
        
        // --- play the effect ---
        EffectManager.shared.playSplashAttackEffect(at: location, level: GameManager.shared.splashAttackLevel)

        
        let splashRadius: CGFloat = GameManager.shared.splashAttackRadius
        // --- ADD THIS BLOCK TO DRAW THE HITBOX ---
//        if let scene = self.scene {
//            let debugCircle = SKShapeNode(circleOfRadius: splashRadius)
//            debugCircle.position = location
//            debugCircle.strokeColor = .red
//            debugCircle.lineWidth = 2
//            debugCircle.zPosition = ZPositions.hud
//
//            let fadeOut = SKAction.fadeOut(withDuration: 1.0)
//            let remove = SKAction.removeFromParent()
//            debugCircle.run(SKAction.sequence([fadeOut, remove]))
//            
//            scene.worldNode.addChild(debugCircle)
//        }
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
                
                var damageToDeal: Int = GameManager.shared.splashAttackDamage
                var sizeBonus = CGFloat(damageToDeal) * GameManager.shared.sizeMultiplier
                //print("size Multiplier: \(GameManager.shared.sizeMultiplier)")
                damageToDeal = Int(sizeBonus)
                
                enemy.physicsBody?.applyImpulse(impulse)
                enemy.takeDamage(amount: damageToDeal, contactPoint: .zero)
                
                enemy.shield = false
                enemy.updateShieldVisibility()
                
            }
        }
    }
    
    
    // MARK: - Helpers
    
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
    
    func farthestBoulder() -> Boulder? {
        guard let player = player else { return nil }

        let activeBoulders = boulders.filter { !$0.isDepleted && !$0.isBeingHeld && $0.type != .golden }

        // Use .max(by:) instead of .min(by:) to find the element with the greatest distance.
        return activeBoulders.max(by: {
            $0.position.distance(to: player.worldPosition) < $1.position.distance(to: player.worldPosition)
        })
    }
    
    /// Safely removes a specific boulder from the internal tracking array.
    func remove(boulder: Boulder) {
        boulders.removeAll { $0 === boulder }
    }
    
}
