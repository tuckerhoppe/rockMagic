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
                if enemy.currentState == .tossed && !enemy.justTossed {
                    enemy.setAnimationState(to: .walking)
                }
                
                // --- NEW: TRIGGER FINAL DEATH ---
                // If the enemy hits the ground AND is in the 'dying' state, start the removal sequence.
                if enemy.currentState == .dying {
                    enemy.startDeathSequence()
                }
            }
        }
        
        // --- ADD THIS NEW BLOCK for Player and Enemy Contact ---
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
        
        // --- ADD THIS NEW CASE for Player and Pickup ---
        if firstBody.categoryBitMask == PhysicsCategory.player && secondBody.categoryBitMask == PhysicsCategory.pickup {
            if let player = firstBody.node as? PlayerNode,
               let pickup = secondBody.node as? PickupNode {
                
                switch pickup.type {
                case .coin:
                    // If it's a coin, increase the score
                    (scene as? GameScene)?.addScore(amount: GameManager.shared.normalGemValue, at: pickup.position)
                    pickup.removeFromParent()
                    
                    // TUTORIAL CHECK
                    if self.scene?.currentTutorialStep == .collectGem{
                        // 3. If yes, complete the step.
                        self.scene?.completeTutorialStep()
                    } else if self.scene?.currentTutorialStep == .levelUp {
                        self.scene?.completeTutorialStep()
                    }
                    
                case .health:
                    if player.currentHealth < player.maxHealth {
                        player.takeDamage(amount: -25)
                        pickup.removeFromParent()
                        // Tell the manager a new one can spawn
                        GameManager.shared.isHealthPickupActive = false
                    }
                    
                    // TUTORIAL CHECK
                    if self.scene?.currentTutorialStep == .medPack{
                        // 3. If yes, complete the step.
                        self.scene?.completeTutorialStep()
                    }
                case .stamina:
                    if player.currentStamina < player.maxStamina {
                        // Restore 25 stamina points
                        player.restoreStamina(amount: 25)
                        pickup.removeFromParent()
                    }
                    
                case .fiveCoin:
                    (scene as? GameScene)?.addScore(amount: GameManager.shared.specialGemValue, at: pickup.position)
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
}
