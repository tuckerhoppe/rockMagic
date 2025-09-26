//
//  AnimationManager.swift
//  RockMagic
//
//  Created by Tucker Hoppe on 7/23/25.
//

import Foundation
import SpriteKit

// An enum to define all possible animations
enum AnimationType {
    case idle, walk, jump, summonBoulder, quickStrike, largeStrike, splashAttack, pullPillar, idleStop
}

class AnimationManager {
    
    // --- Properties ---
    // A dictionary to store the pre-loaded animation actions
    private var animations: [AnimationType: SKAction] = [:]
    
    private var useFirstStrikeImage = true
    
    // --- Initializer ---
    init() {
        loadAnimations()
    }
    
    // --- Load All Animations Once ---
    private func loadAnimations() {
        // NOTE: Replace these texture names with your actual image asset names.
        
        // Idle (a single frame)
        let idleTexture = SKTexture(imageNamed: "earthStanceB")
        animations[.idle] = SKAction.setTexture(idleTexture, resize: true)
        
        // Walk
        let walkFrames = (1...5).map { SKTexture(imageNamed: "walk\($0)") }
        animations[.walk] = SKAction.repeatForever(SKAction.animate(with: walkFrames, timePerFrame: 0.1, resize: true, restore: false))
        
        // Jump (a single frame)
//        let jumpTexture = SKTexture(imageNamed: "jump2")
//        animations[.jump] = SKAction.setTexture(jumpTexture)
        let jumpFrames = (1...5).map { SKTexture(imageNamed: "jump\($0)") }
        animations[.jump] = SKAction.animate(with: jumpFrames, timePerFrame: 0.1, resize: true, restore: false)
        
        // Summon Boulder (a short animation)
        let summonFrames = [SKTexture(imageNamed: "summon"), SKTexture(imageNamed: "summon"), SKTexture(imageNamed: "summon"), SKTexture(imageNamed: "summon"), SKTexture(imageNamed: "summon"), ]
        animations[.summonBoulder] = SKAction.animate(with: summonFrames, timePerFrame: 0.04, resize: true, restore: false)
//        let summonTexture = SKTexture(imageNamed: "Player_Summon_2")
//        animations[.summonBoulder] = SKAction.setTexture(summonTexture, resize: true)
        
        // Quick Strike (a short animation)
        let quickStrikeFrames = [SKTexture(imageNamed: "QuickStrike1B"), SKTexture(imageNamed: "QuickStrike2")]
        animations[.quickStrike] = SKAction.animate(with: quickStrikeFrames, timePerFrame: 0.1, resize: true, restore: false)
        
        let strike1 = SKTexture(imageNamed: "QuickStrike1B")
                let strike2 = SKTexture(imageNamed: "QuickStrike2")
                animations[.quickStrike] = SKAction.setTexture(strike1,  resize: true)
        
        // Large Strike (a single frame)
        let largeStrikeTexture = SKTexture(imageNamed: "large strike")
        animations[.largeStrike] = SKAction.setTexture(largeStrikeTexture,  resize: true)
        
        let splashTexture = SKTexture(imageNamed: "kick")
                animations[.splashAttack] = SKAction.setTexture(splashTexture, resize: true)
        
        // pull up pillar (a short animation)
        let pullPillarFrames = [SKTexture(imageNamed: "lift1"), SKTexture(imageNamed: "lift2"), SKTexture(imageNamed: "lift3"), SKTexture(imageNamed: "lift4"), SKTexture(imageNamed: "lift5"),SKTexture(imageNamed: "lift6"), ]
        animations[.pullPillar] = SKAction.animate(with: pullPillarFrames, timePerFrame: 0.4, resize: true, restore: false)
    }
    
    // In AnimationManager.swift

    /// Returns a pre-loaded animation action without playing it.
    func getAction(for type: AnimationType) -> SKAction? {
        return animations[type]
    }

    func play(animationType: AnimationType, on node: SKSpriteNode) {
        let locomotionKey = "locomotion"
        let actionKey = "action"
        
        // 1. Add a new key for our cancellable animation.
       let cancellableActionKey = "cancellableAction"
        
        switch animationType {
        case .idle, .walk:
            // Only play a walk/idle animation if no other action is currently running.
            if node.action(forKey: actionKey) == nil {
                guard let animationAction = animations[animationType] else { return }
                // Stop the other looping animation before playing the new one.
                node.removeAction(forKey: locomotionKey)
                node.run(animationAction, withKey: locomotionKey)
            }
            
        // 1. Make '.idle' a special "reset" case.
        case .idleStop:
            // This is our universal "stop everything" command.
            // It removes any action or locomotion animation that is running.
            node.removeAllActions() // A simpler way to stop everything.
            
            // Then, play the idle animation.
            if let idleAction = animations[.idle] {
                node.run(idleAction, withKey: locomotionKey)
            }
            
        case .quickStrike:
            // Handle the alternating strike
            let strikeTexture: SKTexture
            if useFirstStrikeImage {
                strikeTexture = SKTexture(imageNamed: "QuickStrike1B")
            } else {
                strikeTexture = SKTexture(imageNamed: "QuickStrike2")
            }
            useFirstStrikeImage.toggle()
            
            let strikeAction = SKAction.setTexture(strikeTexture, resize: true)
            let wait = SKAction.wait(forDuration: 0.2) // Hold the frame
            let sequence = SKAction.sequence([strikeAction, wait])
            
            // Stop any looping animation and run the action
            node.removeAction(forKey: locomotionKey)
            node.run(sequence, withKey: actionKey)

        case .jump, .summonBoulder, .largeStrike, .splashAttack, .pullPillar:
            // This is for all other one-shot animations
            guard let animationAction = animations[animationType] else { return }
            var finalAction = animationAction
            
            // If it's a single frame, add a wait to give it a visible duration
            if animationAction.duration == 0 {
                let wait = SKAction.wait(forDuration: 0.25)
                finalAction = SKAction.sequence([animationAction, wait])
            }
            
            // Stop any looping animation and run the action
            node.removeAction(forKey: locomotionKey)
            node.run(finalAction, withKey: actionKey)
        }
    }

    // In AnimationManager.swift

    func playOG(animationType: AnimationType, on node: SKSpriteNode) {
        guard let animationAction = animations[animationType] else { return }
        
        let locomotionKey = "locomotion"
        let actionKey = "action"
        
        switch animationType {
        case .idle, .walk,.pullPillar:
            // This part is correct
            node.run(animationAction, withKey: locomotionKey)
        
        case .quickStrike, .idleStop:
            guard let idleAction = animations[.idle] else { return }
                    
            // Choose the texture based on the flag
            let strikeTexture: SKTexture
            if useFirstStrikeImage {
                strikeTexture = SKTexture(imageNamed: "strike")
            } else {
                strikeTexture = SKTexture(imageNamed: "strike2thin")
            }
            
            // Flip the flag for next time
            useFirstStrikeImage.toggle()
            
            // Build the animation on the fly
            let strikeAction = SKAction.setTexture(strikeTexture)
            let wait = SKAction.wait(forDuration: 0.2)
            let sequence = SKAction.sequence([strikeAction, wait, idleAction])
            node.run(sequence, withKey: actionKey)
            
        case .jump, .summonBoulder, .quickStrike, .largeStrike, .splashAttack:
            guard let idleAction = animations[.idle] else { return }
            
            // --- THE FIX: Add a "wait" for single-frame animations ---
            // Check if the animation is instantaneous (has a duration of 0)
            if animationAction.duration == 0 {
                // If it's a single frame, hold it on screen for a moment.
                let wait = SKAction.wait(forDuration: 0.25) // Adjust this duration to feel right
                let sequence = SKAction.sequence([animationAction, wait, idleAction])
                node.run(sequence, withKey: actionKey)
            } else {
                // If it's a multi-frame animation, it already has a duration, so just play it.
                let sequence = SKAction.sequence([animationAction, idleAction])
                node.run(sequence, withKey: actionKey)
            }
            
        
        }
    }
    
//    
//    // This is the same simple version from before
//    func play(animationType: AnimationType, on node: SKSpriteNode) {
//        guard let animationAction = animations[animationType] else { return }
//        
//        // We need to cast the generic node to our specific PlayerNode to access the isBusy flag
//        guard let playerNode = node as? PlayerNode else {
//            // If it's not a player, just run the animation simply
//            node.run(animationAction)
//            return
//        }
//
//        // --- NEW LOGIC TO MANAGE THE "BUSY" STATE ---
//        let animationKey = "playerAnimation"
//        
//        switch animationType {
//        case .idle, .walk:
//            // For looping animations, just play them.
//            node.run(animationAction, withKey: animationKey)
//            
//        case .jump, .summonBoulder, .quickStrike, .largeStrike:
//            // For one-shot actions:
//            // 1. Set the player to "busy".
//            playerNode.isBusy = true
//            
//            // 2. Create an action that will set the player back to "not busy" when finished.
//            let doneAction = SKAction.run {
//                playerNode.isBusy = false
//            }
//            
//            // 3. Create a sequence to play the animation and then run the doneAction.
//            let sequence = SKAction.sequence([animationAction, doneAction])
//            node.run(sequence, withKey: animationKey)
//        }
//    }
}
