//
//  TestScene_EnemyToss.swift
//  RockMagic
//
//  Created by Tucker Hoppe on 6/7/25.
//

// In TestScene_EnemyToss.swift

import SpriteKit

class TestScene_EnemyToss: SKScene, SKPhysicsContactDelegate {

    private var enemy: EnemyNode!
    private var debugLabel: SKLabelNode!

    override func didMove(to view: SKView) {
        // Use a different color to easily tell it's a test scene
        backgroundColor = SKColor.darkGray
        
        // Set up the physics world for this scene
        physicsWorld.gravity = CGVector(dx: 0, dy: -9.8)
        physicsWorld.contactDelegate = self
        
        print("--- Test Scene: Enemy Toss ---")
        print("Tap the screen to launch a rock at the enemy.")
        
        // 1. Add a floor
        let ground = SKSpriteNode(color: .brown, size: CGSize(width: frame.width, height: 30))
        ground.position = CGPoint(x: frame.midX, y: 50) // A bit higher for visibility
        ground.physicsBody = SKPhysicsBody(rectangleOf: ground.size)
        ground.physicsBody?.isDynamic = false
        ground.physicsBody?.categoryBitMask = PhysicsCategory.ground
        addChild(ground)

        // 2. Add a single enemy
        enemy = EnemyNode()
        enemy.position = CGPoint(x: frame.midX, y: 150)
        addChild(enemy)
        
        // 3. Add a debug label to see the enemy's state
        debugLabel = SKLabelNode(fontNamed: "Helvetica")
        debugLabel.fontSize = 20
        debugLabel.position = CGPoint(x: frame.midX, y: frame.height - 50)
        addChild(debugLabel)
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        // 4. On tap, create and launch a single rock piece
        let rock = RockPiece(color: .brown, size: CGSize(width: 40, height: 20))
        rock.position = CGPoint(x: frame.midX - 200, y: 150) // Start to the left of the enemy
        
        rock.physicsBody = SKPhysicsBody(rectangleOf: rock.size)
        rock.physicsBody?.categoryBitMask = PhysicsCategory.rockPiece
        rock.physicsBody?.contactTestBitMask = PhysicsCategory.enemy // Make sure it reports contact
        rock.physicsBody?.collisionBitMask = PhysicsCategory.ground | PhysicsCategory.enemy
        
        // Launch it!
        rock.isLaunched = true
        rock.physicsBody?.applyImpulse(CGVector(dx: 50, dy: 10))
        
        addChild(rock)
    }

    override func update(_ currentTime: TimeInterval) {
        // 5. Update the debug label every frame
        if let state = enemy?.currentState {
            debugLabel.text = "Enemy State: \(state)"
        }
        
        // We can also call the rock's update function here if needed
         for node in self.children {
            if let rock = node as? RockPiece {
                rock.update()
            }
        }
    }
    
    // You can copy your didBegin contact delegate function here to handle the physics logic
    func didBegin(_ contact: SKPhysicsContact) {
        // The same didBegin logic from your GameScene goes here
        let firstBody: SKPhysicsBody
        let secondBody: SKPhysicsBody

        if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask {
            firstBody = contact.bodyA
            secondBody = contact.bodyB
        } else {
            firstBody = contact.bodyB
            secondBody = contact.bodyA
        }

        if firstBody.categoryBitMask == PhysicsCategory.enemy && secondBody.categoryBitMask == PhysicsCategory.ground {
            if let enemy = firstBody.node as? EnemyNode, enemy.currentState == .tossed {
                enemy.setAnimationState(to: .idle)
            }
        }
        
        if firstBody.categoryBitMask == PhysicsCategory.enemy && secondBody.categoryBitMask == PhysicsCategory.rockPiece {
            if let enemy = firstBody.node as? EnemyNode, let rock = secondBody.node as? RockPiece {
                if rock.isLaunched {
                    enemy.getTossed(by: rock)
                    rock.removeFromParent()
                }
            }
        }
    }
}
