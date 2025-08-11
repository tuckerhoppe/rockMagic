//
//  BoulderNode.swift
//  RockMagic
//
//  Created by Tucker Hoppe on 5/4/25.
//

import Foundation
import SpriteKit


// In Boulder.swift

import Foundation
import SpriteKit

class Boulder: SKNode {
    var pieces: [RockPiece] = []
    var joints: [SKPhysicsJoint] = []
    private var highlightNode: SKShapeNode?
    var isBraking: Bool = true
    
    /// True if the player is currently dragging this boulder
    var isBeingHeld: Bool = false
    
    

    override init() {
        super.init()

        // --- SETUP THE MAIN BOULDER BODY ---
        self.physicsBody = SKPhysicsBody(circleOfRadius: 5)
        self.physicsBody?.isDynamic = true
        self.physicsBody?.affectedByGravity = true
        
        // --- THE FIX ---
        self.physicsBody?.allowsRotation = false // <-- 1. PREVENTS TUMBLING
        self.physicsBody?.friction = 0.8         // <-- 2. STOPS SLIDING ON LANDING
        self.physicsBody?.mass = 5.0            // <-- 3. MAKES IT THE HEAVY ANCHOR
        // ---------------

        self.physicsBody?.categoryBitMask = PhysicsCategory.boulder
        self.physicsBody?.collisionBitMask = PhysicsCategory.ground | PhysicsCategory.wall | PhysicsCategory.edge //| PhysicsCategory.enemy
        self.physicsBody?.contactTestBitMask = PhysicsCategory.enemy

        // --- SETUP THE PIECES ---
        var increase = 0
        for _ in 0..<3 {
            let piece = RockPiece(color: .brown, size: CGSize(width: 50 - increase, height: 20))
            piece.parentBoulder = self
            piece.position = CGPoint(x: 25, y: increase)
            piece.zPosition = ZPositions.boulder
            piece.physicsBody = SKPhysicsBody(rectangleOf: piece.size)
            piece.physicsBody?.isDynamic = true
            piece.physicsBody?.affectedByGravity = false
            
            // Make pieces very light so the main body dominates
            piece.physicsBody?.mass = 0.1

            piece.physicsBody?.categoryBitMask = PhysicsCategory.rockPiece
            piece.physicsBody?.collisionBitMask = PhysicsCategory.wall | PhysicsCategory.edge | PhysicsCategory.ground
            piece.physicsBody?.contactTestBitMask = PhysicsCategory.player | PhysicsCategory.wall | PhysicsCategory.enemy | PhysicsCategory.edge

            piece.isAttached = true
            addChild(piece)
            pieces.append(piece)
            increase += 10
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }


    // 3. Refactor setupJoints to join pieces to the central body
    func setupJoints(in scene: SKScene) {
        guard let boulderBody = self.physicsBody else { return }

        for piece in pieces {
            guard let pieceBody = piece.physicsBody else { continue }

            // Anchor point is the piece's position relative to the scene
            let anchorPoint = scene.convert(piece.position, from: self)
            let joint = SKPhysicsJointFixed.joint(withBodyA: boulderBody, bodyB: pieceBody, anchor: anchorPoint)
            scene.physicsWorld.add(joint)
            joints.append(joint)
        }
    }
    
    // --- ADD THIS NEW UPDATE FUNCTION ---
    func update() {
        // Only run this check if the brakes are currently on
        if isBraking {
            // Check if the physics body exists and is at rest
            if let body = self.physicsBody, body.isResting {
                // The boulder has stopped. Release the brakes.
                print("Boulder has stopped. Releasing brakes.")
                body.linearDamping = 0.0 // Default value
                body.angularDamping = 0.0 // Default value
                isBraking = false // Reset the flag
            }
        }
    }

    // 4. Refactor launchAllRemainingPieces to move the main body
    func launchAllRemainingPieces(direction: CGVector) {
        // Apply impulse to the main boulder body. The attached pieces will follow.
        self.physicsBody?.applyImpulse(direction)
        //print("I'm trying")
    }


    func launchSinglePiece(direction: CGVector) {
        // Find the last attached piece in the array, which is the topmost one.
        guard let topPiece = pieces.last(where: { $0.isAttached }) else { return }
        // ----------------------

        // Find the specific joint connecting this piece to the main body
        if let jointToRemove = joints.first(where: { ($0.bodyA == self.physicsBody && $0.bodyB == topPiece.physicsBody) || ($0.bodyB == self.physicsBody && $0.bodyA == topPiece.physicsBody) }) {
            
            // Remove the joint from the physics world and our tracking array
            scene?.physicsWorld.remove(jointToRemove)
            joints.removeAll(where: { $0 === jointToRemove })
            
            // Mark the piece as detached
            topPiece.isAttached = false
            
            // IMPORTANT: Turn gravity ON for the detached piece and launch it
            topPiece.physicsBody?.affectedByGravity = true
            topPiece.quickLaunch(direction: direction)
        }
    }

    var isDepleted: Bool {
        // A boulder is depleted when no pieces are attached anymore.
        return !pieces.contains { $0.isAttached }
    }

    func applyBrakes() {
        // 1. Immediately apply the high damping to start braking.
        self.physicsBody?.linearDamping = GameManager.shared.boulderBrakes
        self.physicsBody?.angularDamping = 10.0
        
        // 2. Create an action sequence to release the brakes.
        let wait = SKAction.wait(forDuration: 0.25) // A very short, predictable delay.
        let releaseBrakes = SKAction.run { [weak self] in
            // Reset damping back to the default values.
            self?.physicsBody?.linearDamping = 0.1
            self?.physicsBody?.angularDamping = 0.1
        }
        
        // 3. Run the sequence.
        self.run(SKAction.sequence([wait, releaseBrakes]))
    }
    
    func setHighlight(active: Bool) {
        // Remove old highlight if it exists
        highlightNode?.removeFromParent()
        highlightNode = nil

        if active {
            // Create a new highlight shape
            let shape = SKShapeNode(circleOfRadius: GameManager.shared.boulderHighlightRadius) // Adjust size as needed
            
            shape.position.x = 25 // Adjusts the x position by 25 points
            shape.position.y = 5 // Adjusts the x position by 25 points

            shape.strokeColor = .yellow
            shape.fillColor = .yellow.withAlphaComponent(0.3)
            shape.lineWidth = 3
            shape.zPosition = -1 // Place it behind the rock pieces
            
            // Add a pulsing animation for effect
            let scaleUp = SKAction.scale(to: 1.2, duration: 0.5)
            let scaleDown = SKAction.scale(to: 1.0, duration: 0.5)
            let pulse = SKAction.repeatForever(SKAction.sequence([scaleUp, scaleDown]))
            shape.run(pulse)

            self.highlightNode = shape
            addChild(shape)
        }
    }
}


class RockPiece: SKSpriteNode {
    var isLaunched = false
    var isAttached = true
    var damage: Int = 10
    weak var parentBoulder: Boulder?
    
    //Strong attack
    func strongLaunch(direction: CGVector) {
        //if isLaunched { return } // Prevent re-launching
        //isLaunched = true      // <-- ADD THIS
        //self.physicsBody?.applyImpulse(direction)
    }
    
    //quick attack
    func quickLaunch(direction: CGVector) {
        if isLaunched { return } // Prevent re-launching
        isLaunched = true      // <-- ADD THIS
        self.physicsBody?.applyImpulse(direction)
    }
    
    func update() {
            // We only care about deactivating rocks that have been launched.
            guard isLaunched, let physicsBody = self.physicsBody else { return }
            
            // The `isResting` property automatically becomes true when the physics
            // engine determines the object has stopped moving. This is perfect for our needs.
            if physicsBody.isResting {
                print("A rock piece came to rest. Deactivating.")
                self.isLaunched = false
            }
        }
}
