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
}

class InputManager {
    unowned let scene: GameScene
    
    // Properties to track the state of the single gameplay touch
    private var touchState: TouchState = .idle
    private var startTime: TimeInterval = 0
    private var startWorldLocation: CGPoint = .zero
    private var startScreenLocation: CGPoint = .zero
    
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
    
    // In InputManager.swift

    func touchesBegan(at worldLocation: CGPoint, screenLocation: CGPoint, timestamp: TimeInterval) {
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
            
        case .idle:
            // If we were not dragging, analyze the gesture
            if duration < 0.15 && distance < 20 {
                // It's a TAP
                handleTap(at: screenLocation)
            } else if duration < 0.5 && distance > 40 {
                // It's a SWIPE
                handleSwipe(from: startWorldLocation, to: worldLocation)
            }
        }
        
        // Reset for the next touch
        touchState = .idle
    }
    
    // --- Action Handlers ---
    
    private func handleTap(at screenLocation: CGPoint) {
        print("InputManager: Detected Tap")
        let direction: LaunchDirection = (screenLocation.x > 0) ? .right : .left
        scene.player.playAnimation(.quickStrike)
        scene.magicManager.shootRockPiece(direction: direction)
    }
    
    private func handleSwipe(from start: CGPoint, to end: CGPoint) {
        print("InputManager: Detected Swipe")
        let dx = end.x - start.x
        let dy = end.y - start.y
        
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
