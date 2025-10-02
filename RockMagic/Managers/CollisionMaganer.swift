//
//  CollisionMaganer.swift
//  RockMagic
//
//  Created by Tucker Hoppe on 7/17/25.
//

import Foundation
import SpriteKit
import SpriteKit

class CollisionManager {
    weak var scene: GameScene?

    init(scene: GameScene) {
        self.scene = scene
    }

    func handleContact(_ contact: SKPhysicsContact) {
        let firstBody = contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask ? contact.bodyA : contact.bodyB
        let secondBody = contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask ? contact.bodyB : contact.bodyA

//        MOST RECENT THING
//        // --- Enemy and RockPiece Collision ---
//        if firstBody.categoryBitMask == PhysicsCategory.enemy && secondBody.categoryBitMask == PhysicsCategory.rockPiece {
//            if let enemy = firstBody.node as? EnemyNode,
//               let rock = secondBody.node as? RockPiece {
//                enemy.getTossed(by: rock)
//                //rock.physicsBody?.velocity = .zero
//                //rock.removeFromParent()
//            }
//            
//        }
        
        
        // --- ADD THIS NEW BLOCK for Player and Ground Contact ---
        if firstBody.categoryBitMask == PhysicsCategory.player && secondBody.categoryBitMask == PhysicsCategory.ground {
            if let player = firstBody.node as? PlayerNode {
                // When the player touches the ground, they can jump again.
                player.isGrounded = true
            }
        }
        
        
        // --- Enemy and Ground Collision ---
        if firstBody.categoryBitMask == PhysicsCategory.enemy && secondBody.categoryBitMask == PhysicsCategory.ground {
            if let enemy = firstBody.node as? EnemyNode {
                // If the enemy hits the ground while tossed, return to idle
//                if enemy.currentState == .tossed && !enemy.justTossed {
//                    enemy.setAnimationState(to: .walking)
//                }
//                
//                // --- NEW: TRIGGER FINAL DEATH ---
//                // If the enemy hits the ground AND is in the 'dying' state, start the removal sequence.
//                if enemy.currentState == .dying {
//                    enemy.startDeathSequence()
//                }
                // NEW LOGIC: Check for death upon landing
                if enemy.currentState == .tossed && enemy.currentHealth <= 0 {
                    // If the tossed enemy has no health, it's defeated.
                    enemy.startDeathSequence()

                } else if enemy.currentState == .tossed && !enemy.justTossed {
                    // If it has health, it just gets back up.
                    enemy.setAnimationState(to: .walking)
                }
                
                
            }
        }
        
        // ---  Enemy and Pillar contact ---
        if (firstBody.categoryBitMask == PhysicsCategory.enemy && secondBody.categoryBitMask == PhysicsCategory.pillar) {
            if let enemy = firstBody.node as? EnemyNode, let pillar = secondBody.node as? PillarNode {
                // When an enemy lands on a pillar, make it slippery.
                
                enemy.isOnPillar = true
//                enemy.physicsBody?.friction = 0.0
//                print("enemy posY: \(enemy.position.y)")
//                print("ground Y: \(GameManager.shared.groundY)")
//                
//                if enemy.position.y >= GameManager.shared.groundY {
//                    print("we're in business")
//                    let direction: CGFloat = (enemy.position.x < pillar.position.x) ? -1.0 : 1.0
//                            
//                    // 3. Apply a small, consistent impulse to push them off.
//                    let nudgeForce: CGFloat = 20.0 // You can tune this value
//                    let nudgeImpulse = CGVector(dx: nudgeForce * direction, dy: 0)
//                    enemy.physicsBody?.applyImpulse(nudgeImpulse)
//                }
            }
        }
        

        
        
        // ---  Player and Enemy Contact ---
        if firstBody.categoryBitMask == PhysicsCategory.player && secondBody.categoryBitMask == PhysicsCategory.enemy {
            if let player = firstBody.node as? PlayerNode,
               let enemy = secondBody.node as? EnemyNode {
                
                let contactDamageCooldown: TimeInterval = 0.5
                let currentTime = CACurrentMediaTime()

                // 2. Check if the enemy is off cooldown.
                if currentTime - enemy.lastContactDamageTime > contactDamageCooldown {
                    // Only deal contact damage if the enemy is not tossed or dying.
                    if enemy.currentState != .tossed && enemy.currentState != .dying {
                        
                        // 3. If yes, deal damage and update the enemy's timer.
                        enemy.lastContactDamageTime = currentTime
                        player.takeDamage(amount: enemy.damage)
                    }
                }
            }
        }
        
        
        // Case 1: Enemy hits a RockPiece
        if firstBody.categoryBitMask == PhysicsCategory.enemy && secondBody.categoryBitMask == PhysicsCategory.rockPiece {
            if let enemy = firstBody.node as? EnemyNode, let rockPiece = secondBody.node as? RockPiece {
                
                // For a normal collision, we do NOT bypass the velocity check.
                enemy.getTossed(by: rockPiece, bypassVelocityCheck: false)
                //rockPiece.removeFromParent()
            }
        }

        // Case 2: Enemy hits a Boulder
        if firstBody.categoryBitMask == PhysicsCategory.enemy && secondBody.categoryBitMask == PhysicsCategory.boulder {
            if let enemy = firstBody.node as? EnemyNode, let boulder = secondBody.node as? Boulder {
                if let representativePiece = boulder.pieces.first(where: { $0.isAttached }) {
                    // For a normal collision, we do NOT bypass the velocity check.
                    enemy.getTossed(by: representativePiece, bypassVelocityCheck: false)
                }
                boulder.applyBrakes()
            }
        }
        
        // --- RockPiece and DestroyableObject ---
        if (firstBody.categoryBitMask == PhysicsCategory.rockPiece && secondBody.categoryBitMask == PhysicsCategory.destroyableObject) {
            if let destroyable = secondBody.node as? Damageable, let rockPiece = firstBody.node as? RockPiece{
                destroyable.takeDamage(amount: GameManager.shared.quickStrikeDamage)
                if rockPiece.isAttached == false{
                    rockPiece.removeFromParent()
                }
                //rockPiece.removeFromParent()
            }
        }

        // --- ADD a new case for Boulder and DestroyableObject ---
        if (firstBody.categoryBitMask == PhysicsCategory.boulder && secondBody.categoryBitMask == PhysicsCategory.destroyableObject) {
            if let destroyable = secondBody.node as? Damageable, let boulder = firstBody.node as? Boulder {
                destroyable.takeDamage(amount: GameManager.shared.fullBoulderDamage)
                boulder.applyBrakes()
            }
        }
        
        if (firstBody.categoryBitMask == PhysicsCategory.rockPiece && secondBody.categoryBitMask == PhysicsCategory.destroyableObject) {
                if let base = secondBody.node as? EnemyBaseNode,
                   let rockPiece = firstBody.node as? RockPiece {
                    
                    // Deal damage and remove the rock piece
                    base.takeDamage(amount: GameManager.shared.quickStrikeDamage)
                    //rockPiece.removeFromParent()
                }
            }
            
            // --- ADD THIS NEW CASE for Boulder and EnemyBase ---
            if (firstBody.categoryBitMask == PhysicsCategory.boulder && secondBody.categoryBitMask == PhysicsCategory.destroyableObject) {
                if let base = secondBody.node as? EnemyBaseNode,
                   let boulder = firstBody.node as? Boulder {
                    
                    // Deal damage and apply brakes to the boulder
                    base.takeDamage(amount: GameManager.shared.fullBoulderDamage)
                    boulder.applyBrakes()
                }
            }
        
        // --- ADD THIS NEW CASE for Player and Pickup ---
        if firstBody.categoryBitMask == PhysicsCategory.player && secondBody.categoryBitMask == PhysicsCategory.pickup {
            if let player = firstBody.node as? PlayerNode,
               let pickup = secondBody.node as? PickupNode {
                
                switch pickup.type {
                case .coin:
                    // If it's a coin, increase the score
                    (scene)?.addScore(amount: GameManager.shared.normalGemValue, at: pickup.position)
                    pickup.removeFromParent()
                    
                    // TUTORIAL CHECK
                    if self.scene?.tutorialManager.currentTutorialStep == .collectGem{
                        // 3. If yes, complete the step.
                        self.scene?.tutorialManager.completeTutorialStep()
                    } else if self.scene?.tutorialManager.currentTutorialStep == .levelUp {
                        self.scene?.tutorialManager.completeTutorialStep()
                    }
                    
                case .health:
                    if player.currentHealth < player.maxHealth {
                        player.takeDamage(amount: -25)
                        pickup.removeFromParent()
                        // Tell the manager a new one can spawn
                        GameManager.shared.isHealthPickupActive = false
                    }
                    
                    // TUTORIAL CHECK
                    if self.scene?.tutorialManager.currentTutorialStep == .medPack{
                        // 3. If yes, complete the step.
                        self.scene?.tutorialManager.completeTutorialStep()
                    }
                case .stamina:
                    if player.currentStamina < player.maxStamina {
                        // Restore 25 stamina points
                        player.restoreStamina(amount: 25)
                        pickup.removeFromParent()
                    }
                    
                case .fiveCoin:
                    (scene)?.addScore(amount: GameManager.shared.specialGemValue, at: pickup.position)
                    pickup.removeFromParent()
                
                    
                case .geode:
                    if player.currentStamina < player.maxStamina {
                        // Restore 25 stamina points
                        player.restoreStamina(amount: 100)
                        pickup.removeFromParent()
                    }


                
                }
            }
        }

//        // --- ADD PLAYER AND ENEMY COLLISION LOGIC ---
//        // This assumes player is firstBody and enemy is secondBody based on their category values
//        if firstBody.categoryBitMask == PhysicsCategory.player && secondBody.categoryBitMask == PhysicsCategory.enemy {
//            if let player = firstBody.node as? PlayerNode {
//                // Define how much damage an enemy does on contact
//                let enemyContactDamage = 10
//                player.takeDamage(amount: enemyContactDamage)
//                
//                // Tell the scene to update the visual health bar
//                scene?.updatePlayerHealthBar()
//            }
//        }
        
    }
    
    
    // --- ADD THIS NEW FUNCTION to handle when contact ends ---
    func handleEndContact(_ contact: SKPhysicsContact) {
        let firstBody = contact.bodyA
        let secondBody = contact.bodyB
        
        // Check if an enemy has STOPPED touching a pillar
        if (firstBody.categoryBitMask == PhysicsCategory.enemy && secondBody.categoryBitMask == PhysicsCategory.pillar) {
            if let enemy = firstBody.node as? EnemyNode {
                // When the enemy slides off, restore its normal friction.
                enemy.physicsBody?.friction = enemy.originalFriction
                enemy.isOnPillar = false
            }
        } else if (firstBody.categoryBitMask == PhysicsCategory.pillar && secondBody.categoryBitMask == PhysicsCategory.enemy) {
            if let enemy = secondBody.node as? EnemyNode {
                enemy.physicsBody?.friction = enemy.originalFriction
                enemy.isOnPillar = false
            }
        }
        
        
    }
}
