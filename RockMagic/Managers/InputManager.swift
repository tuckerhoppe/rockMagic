//
//  InputManager.swift
//  RockMagic
//
//  Created by Tucker Hoppe on 7/17/25.
//

import Foundation
import SpriteKit
import UIKit

//class InputManager {
//    unowned let scene: GameScene
//
//    init(scene: GameScene, view: SKView) {
//        self.scene = scene
//        setupGestures(in: view)
//    }
//
//    private func setupGestures(in view: SKView) {
//        let swipeUp = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe(_:)))
//        swipeUp.direction = .up
//        view.addGestureRecognizer(swipeUp)
//
//        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe(_:)))
//        swipeLeft.direction = .left
//        view.addGestureRecognizer(swipeLeft)
//
//        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe(_:)))
//        swipeRight.direction = .right
//        view.addGestureRecognizer(swipeRight)
//
//        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
//        view.addGestureRecognizer(tap)
//    }
//
//    @objc private func handleSwipe(_ gesture: UISwipeGestureRecognizer) {
//        switch gesture.direction {
//        case .up:
//            // 1. Get the touch location in the view's coordinates.
//            let locationInView = gesture.location(in: gesture.view)
//            
//            // 2. Convert the view location to the scene's coordinate system.
//            let locationInScene = scene.convertPoint(fromView: locationInView)
//            
//            // --- THE FIX: Convert the scene location to the worldNode's coordinate system. ---
//            let locationInWorld = scene.worldNode.convert(locationInScene, from: scene)
//            
//            // 4. Pass this final world position to the magic manager.
//            scene.magicManager.pullUpBoulder(position: locationInWorld)
//            //print("SWIPE UP at: \(locationInScene)")
//        case .left:
//            scene.magicManager.launchBoulder(direction: .left)
//            scene.player.playAnimation(.largeStrike) // Play large strike animation
//            //print("SWIPE LEFT")
//        case .right:
//            scene.magicManager.launchBoulder(direction: .right)
//            scene.player.playAnimation(.largeStrike) // Play large strike animation
//            //print("SWIPE RIGHT")
//        default:
//            break
//        }
//    }
//
//    @objc private func handleTap(_ gesture: UITapGestureRecognizer) {
//        //print("TAP")
//        scene.player.playAnimation(.quickStrike) // Play quick strike animation
//        var direction: LaunchDirection
//
//        if scene.player.isFacingRight {
//            direction = .right
//        } else {
//            direction = .left
//        }
//        
//        scene.magicManager.shootRockPiece(direction: direction)
//    }
//}


// In InputManager.swift

import UIKit
import SpriteKit

// Make the class an NSObject and conform to the delegate protocol
class InputManager: NSObject, UIGestureRecognizerDelegate {
    unowned let scene: GameScene

    init(scene: GameScene, view: SKView) {
        self.scene = scene
        super.init() // Call the superclass initializer
        setupGestures(in: view)
    }

    private func setupGestures(in view: SKView) {
        let swipeUp = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe(_:)))
        swipeUp.direction = .up
        swipeUp.delegate = self // Set the delegate
        view.addGestureRecognizer(swipeUp)

        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe(_:)))
        swipeLeft.direction = .left
        swipeLeft.delegate = self // Set the delegate
        view.addGestureRecognizer(swipeLeft)

        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe(_:)))
        swipeRight.direction = .right
        swipeRight.delegate = self // Set the delegate
        view.addGestureRecognizer(swipeRight)

        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        tap.delegate = self // Set the delegate
        view.addGestureRecognizer(tap)
    }
    
    // --- ADD THIS NEW DELEGATE FUNCTION ---
    // This function acts as a bouncer for all gestures.
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        // Get the location of the touch
        let location = touch.location(in: scene)
        
        // Calculate the distance from the touch to the center of the joystick
        let distanceToJoystick = scene.joystick.position.distance(to: location)
        
        // If the touch is inside the joystick's activation area, IGNORE the gesture.
        if distanceToJoystick <= scene.joystick.touchAreaRadius {
            return false
        }
        
        // Otherwise, allow the gesture to proceed.
        return true
    }

    @objc private func handleSwipe(_ gesture: UISwipeGestureRecognizer) {
        switch gesture.direction {
        case .up:
            // 1. Get the touch location in the view's coordinates.
            let locationInView = gesture.location(in: gesture.view)
            
            // 2. Convert the view location to the scene's coordinate system.
            let locationInScene = scene.convertPoint(fromView: locationInView)
            
            // --- THE FIX: Convert the scene location to the worldNode's coordinate system. ---
            let locationInWorld = scene.worldNode.convert(locationInScene, from: scene)
            
            // 4. Pass this final world position to the magic manager.
            scene.magicManager.pullUpBoulder(position: locationInWorld)
            //print("SWIPE UP at: \(locationInScene)")
        case .left:
            scene.magicManager.launchBoulder(direction: .left)
            scene.player.playAnimation(.largeStrike) // Play large strike animation
            //print("SWIPE LEFT")
        case .right:
            scene.magicManager.launchBoulder(direction: .right)
            scene.player.playAnimation(.largeStrike) // Play large strike animation
            //print("SWIPE RIGHT")
        default:
            break
        }
    }

    @objc private func handleTap(_ gesture: UITapGestureRecognizer) {
        //print("TAP")
        scene.player.playAnimation(.quickStrike) // Play quick strike animation
        var direction: LaunchDirection

        if scene.player.isFacingRight {
            direction = .right
        } else {
            direction = .left
        }
        
        scene.magicManager.shootRockPiece(direction: direction)
    }
}
