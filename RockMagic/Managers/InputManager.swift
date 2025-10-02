//
//  InputManager.swift
//  RockMagic
//
//  Created by Tucker Hoppe on 7/17/25.
//

import Foundation
import SpriteKit
import UIKit

// An enum to track what the gameplay finger is doing
enum TouchState {
    case idle
    case dragging(boulder: Boulder)
    case holding(startTime: TimeInterval, startLocation: CGPoint)
}

class InputManager {
    unowned let scene: GameScene
    private var touchState: TouchState = .idle
    
    init(scene: GameScene) {
        self.scene = scene
    }

    /// This function is now synchronous and much simpler.
    func touchesBegan(at worldLocation: CGPoint, screenLocation: CGPoint, timestamp: TimeInterval) {
        // 1. Check if the touch started on a grabbable boulder.
        var closestBoulder: Boulder?
        var minDistance: CGFloat = .greatestFiniteMagnitude
        
        for boulder in scene.magicManager.boulders {
            if boulder.isBeingHeld { continue }
            let distance = boulder.position.distance(to: worldLocation)
            if distance < minDistance {
                minDistance = distance
                closestBoulder = boulder
            }
        }
        
        // 2. If a golden boulder is close enough, start a drag.
        let grabRadius: CGFloat = GameManager.shared.grabRadius
        if let boulderToGrab = closestBoulder, minDistance <= grabRadius, boulderToGrab.type == .golden {
            touchState = .dragging(boulder: boulderToGrab)
            scene.startDrag(on: boulderToGrab, at: worldLocation)
        } else {
            // 3. If not, it's a potential hold, tap, or swipe.
            touchState = .holding(startTime: timestamp, startLocation: worldLocation)
        }
    }


    
    func update(currentTime: TimeInterval) {
        if case let .holding(startTime, startLocation) = touchState {
            let duration = currentTime - startTime
            let holdThreshold: TimeInterval = 0.4

            if duration >= holdThreshold {
                // Start or continue growing while the player holds
                scene.growPillar(at: startLocation)
            }
        }
    }


    func touchesMoved(to worldLocation: CGPoint) {
        if case .dragging = touchState {
            scene.updateDrag(at: worldLocation)
        }
    }
    
    func touchesEnded(at worldLocation: CGPoint, screenLocation: CGPoint, timestamp: TimeInterval) {
        switch touchState {
        case .dragging(let boulder):
            scene.endDrag(on: boulder, at: worldLocation, with: timestamp)

        case .holding(let startTime, let startLocation):
            let duration = timestamp - startTime
            let distance = startLocation.distance(to: worldLocation)

            if duration < 0.15 && distance < 20 {
                // Quick tap
                handleTap(at: screenLocation)
            } else if duration < 0.5 && distance > 40 {
                // Short swipe
                handleSwipe(from: startLocation, to: worldLocation)
            } else {
                // It was a proper hold, so stop growing
                scene.stopGrowingPillar()
                // Return the player to the idle animation
                if let player = scene.player {
                    player.playAnimation(.idleStop)
                }
            }

        case .idle:
            break
        }

        touchState = .idle
    }

    
    
    private func handleTap(at screenLocation: CGPoint) {
        //print("InputManager: Detected Tap")
        let direction: LaunchDirection = (screenLocation.x > 0) ? .right : .left
        if scene.tutorialManager.currentTutorialStep == .quickAttack {
            scene.tutorialManager.completeTutorialStep()
        }
        scene.player.playAnimation(.quickStrike)
        scene.magicManager.shootRockPiece(direction: direction)
    }
    
    private func handleSwipe(from start: CGPoint, to end: CGPoint) {
        //print("InputManager: Detected Swipe")
        let dx = end.x - start.x
        let dy = end.y - start.y
        
        //TUTORIAL---------------
        if scene.tutorialManager.currentTutorialStep == .swipeUp && end.y > start.y {
            // Swipe UP
            scene.tutorialManager.completeTutorialStep()
        } else if scene.tutorialManager.currentTutorialStep == .strongAttack && abs(dx) > abs(dy){
            // Swipe left/right
            scene.tutorialManager.completeTutorialStep()
        } else if scene.tutorialManager.currentTutorialStep == .splashAttack && abs(dy) > abs(dx) && dy < 0 {
            // swipe down
            scene.tutorialManager.completeTutorialStep()
        }
        
        //------------------
        if abs(dy) > abs(dx) && dy > 0 {
            // It's a SWIPE UP
            scene.magicManager.pullUpBoulder(position: end)
            
        } else if abs(dx) > abs(dy) {
            // It's a SWIPE LEFT/RIGHT
            let direction: LaunchDirection = (dx > 0) ? .right : .left
            scene.player.playAnimation(.largeStrike)
            scene.magicManager.launchBoulder(direction: direction)
        } else if abs(dy) > abs(dx) && dy < 0 {
            // --- ADD THIS NEW CASE ---
            // It's a SWIPE DOWN
            scene.player.playAnimation(.splashAttack)
            scene.magicManager.splashAttack(at: end)
        }
    }
   
}

