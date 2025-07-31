//
//  Joystick.swift
//  RockMagic
//
//  Created by Tucker Hoppe on 4/29/25.
//
//
//import Foundation
//import SpriteKit
//
//class Joystick: SKNode {
//    private var knob: SKShapeNode!
//    private var base: SKShapeNode!
//    private var isTracking = false
//    
//    private(set) var velocity = CGVector(dx: 0, dy: 0)
//    
//    private let knobRadius: CGFloat = 30
//    private let baseRadius: CGFloat = 50
//    
//    override init() {
//        super.init()
//        isUserInteractionEnabled = true
//        setup()
//    }
//    
//    required init?(coder aDecoder: NSCoder) {
//        super.init(coder: aDecoder)
//        setup()
//    }
//    
//    func setup() {
//        base = SKShapeNode(circleOfRadius: baseRadius)
//        base.fillColor = .darkGray
//        base.alpha = 0.5
//        addChild(base)
//        
//        knob = SKShapeNode(circleOfRadius: knobRadius)
//        knob.fillColor = .lightGray
//        knob.alpha = 0.8
//        knob.position = .zero
//        addChild(knob)
//    }
//    
//    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
//        isTracking = true
//    }
//
//    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
//        guard isTracking, let touch = touches.first else { return }
//        let location = touch.location(in: self)
//        let distance = hypot(location.x, location.y)
//        let angle = atan2(location.y, location.x)
//        
//        let limitedDistance = min(distance, baseRadius)
//        knob.position = CGPoint(x: cos(angle) * limitedDistance, y: sin(angle) * limitedDistance)
//        
//        velocity = CGVector(dx: knob.position.x / baseRadius, dy: knob.position.y / baseRadius)
//    }
//
//    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
//        reset()
//    }
//    
//    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
//        reset()
//    }
//
//    private func reset() {
//        isTracking = false
//        knob.run(SKAction.move(to: .zero, duration: 0.1))
//        velocity = .zero
//    }
//}


//import Foundation
//import SpriteKit
//
//class Joystick: SKNode {
//    private var knob: SKShapeNode!
//    private var base: SKShapeNode!
//    
//    // An invisible, larger sprite for better touch handling
//    private var touchArea: SKSpriteNode!
//    
//    private(set) var velocity = CGVector(dx: 0, dy: 0)
//    
//    private let knobRadius: CGFloat = 30
//    private let baseRadius: CGFloat = 50
//    // The touch area is much larger than the visible joystick
//    private let touchAreaRadius: CGFloat = 200
//
//    override init() {
//        super.init()
//        isUserInteractionEnabled = true
//        setup()
//    }
//    
//    required init?(coder aDecoder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//    
//    func setup() {
//        // 1. Create the large, invisible touch area
//        touchArea = SKSpriteNode(color: .clear, size: CGSize(width: touchAreaRadius * 2, height: touchAreaRadius * 2))
//        addChild(touchArea)
//        
//        // 2. Add the visible parts as children of the touch area
//        base = SKShapeNode(circleOfRadius: baseRadius)
//        base.fillColor = .darkGray
//        base.alpha = 0.5
//        touchArea.addChild(base)
//        
//        knob = SKShapeNode(circleOfRadius: knobRadius)
//        knob.fillColor = .lightGray
//        knob.alpha = 0.8
//        knob.position = .zero
//        touchArea.addChild(knob)
//    }
//    
//    // --- REVISED TOUCH LOGIC ---
//    
//    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
//        guard let touch = touches.first else { return }
//        let location = touch.location(in: self)
//        updateKnobPosition(at: location)
//    }
//
//    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
//        guard let touch = touches.first else { return }
//        let location = touch.location(in: self)
//        updateKnobPosition(at: location)
//    }
//
//    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
//        reset()
//    }
//    
//    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
//        reset()
//    }
//
//    // A new, reusable function to handle knob movement
//    private func updateKnobPosition(at location: CGPoint) {
//        let distance = hypot(location.x, location.y)
//        let angle = atan2(location.y, location.x)
//        
//        // We now limit the distance based on the larger touch area radius
//        let limitedDistance = min(distance, touchAreaRadius)
//        
//        // But the knob's visual movement is still capped by the base
//        let knobDistance = min(distance, baseRadius)
//        knob.position = CGPoint(x: cos(angle) * knobDistance, y: sin(angle) * knobDistance)
//        
//        // The velocity is calculated from the full touch area for more sensitivity
//        velocity = CGVector(dx: (cos(angle) * limitedDistance) / touchAreaRadius, dy: (sin(angle) * limitedDistance) / touchAreaRadius)
//    }
//
//    private func reset() {
//        knob.run(SKAction.move(to: .zero, duration: 0.1))
//        velocity = .zero
//    }
//}


// In Joystick.swift

import SpriteKit

class Joystick: SKNode {
    private var knob: SKShapeNode!
    private var base: SKShapeNode!
    
    private(set) var velocity = CGVector(dx: 0, dy: 0)
    
    private let knobRadius: CGFloat = 30
    private let baseRadius: CGFloat = 50
    let touchAreaRadius: CGFloat = 100 // Make this public so the scene can use it

    override init() {
        super.init()
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setup() {
        base = SKShapeNode(circleOfRadius: baseRadius)
        base.fillColor = .darkGray
        base.alpha = 0.5
        addChild(base)
        
        knob = SKShapeNode(circleOfRadius: knobRadius)
        knob.fillColor = .lightGray
        knob.alpha = 0.8
        knob.position = .zero
        addChild(knob)
    }
    
    // --- NEW PUBLIC FUNCTIONS ---
    // The GameScene will call this function to update the joystick's state.
    func update(at location: CGPoint) {
        let distance = hypot(location.x, location.y)
        let angle = atan2(location.y, location.x)
        
        let knobDistance = min(distance, baseRadius)
        knob.position = CGPoint(x: cos(angle) * knobDistance, y: sin(angle) * knobDistance)
        
        // The velocity is still calculated based on the larger touch radius for sensitivity.
        let limitedDistance = min(distance, touchAreaRadius)
        velocity = CGVector(dx: (cos(angle) * limitedDistance) / touchAreaRadius, dy: (sin(angle) * limitedDistance) / touchAreaRadius)
    }
    
    // The GameScene will call this to reset the joystick.
    func reset() {
        knob.run(SKAction.move(to: .zero, duration: 0.1))
        velocity = .zero
    }
}
