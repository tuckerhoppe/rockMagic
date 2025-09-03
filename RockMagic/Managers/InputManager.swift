//
//  InputManager.swift
//  RockMagic
//
//  Created by Tucker Hoppe on 7/17/25.
//

import Foundation
import SpriteKit
import UIKit

// In InputManager.swift

import SpriteKit

// An enum to track what the gameplay finger is doing
enum TouchState {
    case idle
    case dragging(boulder: Boulder)
    case holding(startTime: TimeInterval, startLocation: CGPoint)
}

class InputManagerOLD {
    unowned let scene: GameScene
    
    // Properties to track the state of the single gameplay touch
    private var touchState: TouchState = .idle
    private var startTime: TimeInterval = 0
    private var startWorldLocation: CGPoint = .zero
    private var startScreenLocation: CGPoint = .zero
    
    private let holdTimeThreshold: TimeInterval = 0.5 // 0.5 seconds for a hold
    //private var currentTouch: UITouch? // Keep a reference to the touch
    
    init(scene: GameScene) {
        self.scene = scene
    }
    
    // --- The "Brain" Logic ---
    
    func touchesBeganOLD(at worldLocation: CGPoint, screenLocation: CGPoint, timestamp: TimeInterval) {
        startTime = timestamp
        startWorldLocation = worldLocation
        startScreenLocation = screenLocation
        
        // Check if the touch started on a boulder
        if let tappedPiece = scene.worldNode.atPoint(worldLocation) as? RockPiece,
           let boulder = tappedPiece.parentBoulder {
            
            // If yes, enter the dragging state
            touchState = .dragging(boulder: boulder)
            scene.startDrag(on: boulder, at: worldLocation)
        }
    }
    
    // ADD THIS NEW METHOD
//    func update(currentTime: TimeInterval) {
//        // 1. Only check for a hold if the finger is down in the 'idle' state.
//        guard case .idle = touchState, let touch = self.currentTouch else {
//            return
//        }
//
//        // 2. Check if the finger has moved too far to be considered a 'hold'.
//        let locationInWorld = touch.location(in: scene.worldNode)
//        let distance = startWorldLocation.distance(to: locationInWorld)
//        if distance > 20.0 { // Use a small tolerance
//            // If it moves too much, it can't be a hold. Reset.
//            // It might become a swipe later in touchesEnded.
//            return
//        }
//
//        // 3. Check if enough time has passed.
//        let duration = currentTime - startTime
//        if duration > holdTimeThreshold {
//            // 4. Threshold met! It's officially a hold gesture.
//            touchState = .holding
//            handleHold(at: startWorldLocation) // Call the action handler
//        }
//    }
    // In InputManager.swift

    func touchesBeganOLD(at worldLocation: CGPoint, screenLocation: CGPoint, timestamp: TimeInterval, touch: UITouch) {
        //self.currentTouch = touch
        startTime = timestamp
        startWorldLocation = worldLocation
        startScreenLocation = screenLocation

        
        
        // --- THE FIX: The "Magnetic Grab" logic now lives here ---
        
        // 1. Find the boulder closest to the touch.
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
        
        // 2. If the closest boulder is within the grab radius, start a drag.
        
        let grabRadius: CGFloat = GameManager.shared.grabRadius
        if let boulderToGrab = closestBoulder, minDistance <= grabRadius, boulderToGrab.type == .golden {
            touchState = .dragging(boulder: boulderToGrab)
            scene.startDrag(on: boulderToGrab, at: worldLocation)
        } else {
            // 3. If no boulder was grabbed, the state remains .idle, ready for a tap or swipe.
            touchState = .idle
        }
    }
    
    func touchesBegan(at worldLocation: CGPoint, screenLocation: CGPoint, timestamp: TimeInterval, touch: UITouch) {
        //self.currentTouch = touch
        startTime = timestamp
        startWorldLocation = worldLocation
        startScreenLocation = screenLocation
        touchState = .idle // Default to idle immediately

        // ✅ Move the boulder search to a background thread
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self = self else { return }

            var closestBoulder: Boulder?
            var minDistance: CGFloat = .greatestFiniteMagnitude
            
            // This loop now runs safely in the background
            for boulder in self.scene.magicManager.boulders {
                if boulder.isBeingHeld { continue }
                let distance = boulder.position.distance(to: worldLocation)
                if distance < minDistance {
                    minDistance = distance
                    closestBoulder = boulder
                }
            }
            
            let grabRadius: CGFloat = GameManager.shared.grabRadius
            
            // ✅ Once done, switch back to the main thread to update the game state
            DispatchQueue.main.async {
                // Make sure the touch hasn't ended while we were searching
                //guard self.currentTouch === touch else { return }

                if let boulderToGrab = closestBoulder, minDistance <= grabRadius, boulderToGrab.type == .golden {
                    // All game state and scene updates MUST be on the main thread
                    self.touchState = .dragging(boulder: boulderToGrab)
                    self.scene.startDrag(on: boulderToGrab, at: worldLocation)
                }
                // If no boulder was found, the state correctly remains .idle
            }
        }
    }
    
    
    
    
    func touchesMoved(to worldLocation: CGPoint) {
        if case .dragging = touchState {
            // If we are dragging, tell the scene to update the joint's position
            scene.updateDrag(at: worldLocation)
        }
    }
    
    func touchesEnded(at worldLocation: CGPoint, screenLocation: CGPoint, timestamp: TimeInterval) {
        let duration = timestamp - startTime
        let distance = startWorldLocation.distance(to: worldLocation)
        
        switch touchState {
        case .dragging(let boulder):
            // If we were dragging, it's a throw
            scene.endDrag(on: boulder, at: worldLocation, with: timestamp)
            
        //case .holding:
            // The hold action was already triggered in update().
            // You might have a "release" action here if needed,
            // but for now, we just break.
            //break
            
        case .idle:
            // If we were not dragging, analyze the gesture
            if duration < 0.15 && distance < 20 {
                // It's a TAP
                handleTap(at: screenLocation)
            } else if duration < 0.5 && distance > 40 {
                // It's a SWIPE
                handleSwipe(from: startWorldLocation, to: worldLocation)
            }
            
        case .holding:
            print("hehe")
        }
        
        //self.currentTouch = nil // Clear the touch
        
        // Reset for the next touch
        touchState = .idle
    }
    
    // --- Action Handlers ---
    
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
    
    // In InputManager.swift

    // This is the corrected function (the fix)
//    private func handleHold(at worldLocation: CGPoint) {
//        print("InputManager: Detected Hold at \(worldLocation)")
//
//        // --- The Fix ---
//        // Move the heavy work to a background thread to avoid blocking the UI.
//        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
//            // This code now runs in the background.
//            // It's safe to perform slow operations here.
//            // For example, let's pretend pullUpPillar is a slow function:
//            self?.scene.magicManager.pullUpPillar(at: worldLocation)
//
//            // IMPORTANT: If pullUpPillar (or any background work) needs to update the
//            // scene (like adding a node), you MUST do that back on the main thread.
//            DispatchQueue.main.async {
//                // For example, if a pillar was created and now needs to be added:
//                // self?.scene.addChild(newlyCreatedPillar)
//                print("Hold action complete and UI updated if necessary.")
//            }
//        }
//    }
}




import SpriteKit



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

    // In InputManager.swift

    func updateOLD(currentTime: TimeInterval) {
        // --- THE FIX: Use "if case let" to safely access the enum's values ---
        // This now correctly reads: "If the touchState is .holding, give me its
        // startTime and startLocation."
        if case let .holding(startTime, startLocation) = touchState {
            
            let duration = currentTime - startTime
            let holdThreshold: TimeInterval = 0.4

            if duration >= holdThreshold {
                // The hold is successful.
                scene.growPillar(at: startLocation)
                // The hold has been consumed, so we can set the state back to idle.
                touchState = .idle
            }
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
            }

        case .idle:
            break
        }

        touchState = .idle
    }


    func touchesEndedOLD(at worldLocation: CGPoint, screenLocation: CGPoint, timestamp: TimeInterval) {
        switch touchState {
        case .dragging(let boulder):
            scene.endDrag(on: boulder, at: worldLocation, with: timestamp)
            
        case .holding(let startTime, let startLocation):
            // If the touch ends before the hold timer is met, it's a tap or swipe.
            let duration = timestamp - startTime
            let distance = startLocation.distance(to: worldLocation)

            if duration < 0.15 && distance < 20 {
                handleTap(at: screenLocation)
            } else if duration < 0.5 && distance > 40 {
                handleSwipe(from: startLocation, to: worldLocation)
            }
        
        case .idle:
            // This happens if the hold was successful and the finger was lifted later.
            scene.stopGrowingPillar()
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
    
    // ... (your handleTap and handleSwipe functions are the same)
}

