//
//  Untitled.swift
//  RockMagic
//
//  Created by Tucker Hoppe on 8/14/25.
//

// In EffectManager.swift


// In EffectManager.swift

import SpriteKit

class EffectManager {
    
    static let shared = EffectManager()
    
    weak var scene: GameScene?
    
    // A simple, reusable texture for our particles
    private let particleTexture = SKTexture(imageNamed: "sparkB") // Assuming you have a simple white dot/spark image
    
    private init() {}
    
    /// Plays a speed line effect for the quick strike, scaled by upgrade level.
    func playQuickStrikeEffect(at position: CGPoint, direction: LaunchDirection, level: Int) {
        let emitter = SKEmitterNode()
        emitter.particleTexture = particleTexture
        emitter.position = position
        
        // Emitter settings scale with level
        emitter.numParticlesToEmit = 10 + (level * 3)
        emitter.particleBirthRate = 500
        
        // --- THE FIX: Change color at max level ---
        if level >= GameManager.shared.maxUpgradeLevel {
            emitter.particleColor = .orange
        } else {
            emitter.particleColor = .white
        }
        
        emitter.particleColorBlendFactor = 1.0
        emitter.particleAlphaSequence = SKKeyframeSequence(keyframeValues: [1.0, 0.0], times: [0, 1])
        // --- THE FIX: Scale particle size with level ---
        let scale = 0.1 + (CGFloat(level) * 0.03)
        emitter.particleScaleSequence = SKKeyframeSequence(keyframeValues: [scale, 0.0], times: [0, 1])
        
        // Particle physics scale with level
        emitter.particleLifetime = 0.3
        emitter.particleSpeed = 300 + CGFloat(level * 20)
        emitter.emissionAngle = (direction == .left) ? 0 : .pi
        emitter.emissionAngleRange = .pi / 8
        
        addEffect(emitter)
    }
    
    /// Plays a larger speed line effect for the strong attack.
    func playStrongAttackEffect(at position: CGPoint, direction: LaunchDirection, level: Int) {
        let emitter = SKEmitterNode()
        emitter.particleTexture = particleTexture
        emitter.position = position
        
        emitter.numParticlesToEmit = Int(CGFloat(20 + (level * 5)))
        emitter.particleBirthRate = 800
        
        
        if level >= GameManager.shared.maxUpgradeLevel {
            emitter.particleColor = .orange
        } else {
            emitter.particleColor = .white
        }
        
        emitter.particleColorBlendFactor = 1.0
        emitter.particleAlphaSequence = SKKeyframeSequence(keyframeValues: [1.0, 0.0], times: [0, 1])
        emitter.particleScaleSequence = SKKeyframeSequence(keyframeValues: [0.2, 0.0], times: [0, 1])
        
        emitter.particleLifetime = 0.5
        emitter.particleSpeed = 400 + CGFloat(level * 30)
        emitter.emissionAngle = (direction == .left) ? 0 : .pi
        emitter.emissionAngleRange = .pi / 6 // A wider cone
        
        addEffect(emitter)
    }
    
    /// Plays an explosion effect for the splash attack.
    func playSplashAttackEffect(at position: CGPoint, level: Int) {
        let emitter = SKEmitterNode()
        emitter.particleTexture = particleTexture
        emitter.position = position
        
        emitter.numParticlesToEmit = Int(CGFloat(50 + (level * 15))) // More particles per level
        emitter.particleBirthRate = 5000 // A very fast burst
        
        emitter.particleColor = .white
        emitter.particleColorBlendFactor = 1.0
        emitter.particleAlphaSequence = SKKeyframeSequence(keyframeValues: [1.0, 0.0], times: [0, 1])
        emitter.particleScaleSequence = SKKeyframeSequence(keyframeValues: [0.3, 0.0], times: [0, 1])
        
        emitter.particleLifetime = 0.8
        emitter.particleSpeed = 150 + CGFloat(level * 20) // Faster explosion per level
        emitter.particleSpeedRange = 100
        emitter.emissionAngleRange = .pi * 2 // A full 360-degree burst
        
        addEffect(emitter)
    }
    
    // In EffectManager.swift

    /// Plays a dust cloud effect for when a boulder is summoned from the ground.
    func playBoulderSummonEffect(at position: CGPoint) {
        let emitter = SKEmitterNode()
        emitter.particleTexture = particleTexture
        
        emitter.position = CGPoint(x: position.x + 25, y: position.y + 30)
        
        // Emitter settings
        emitter.numParticlesToEmit = 30
        emitter.particleBirthRate = 1000 // A quick burst
        
        // Particle appearance (dusty brown color)
        emitter.particleColor = UIColor(red: 0.6, green: 0.4, blue: 0.2, alpha: 1.0)
        emitter.particleColorBlendFactor = 1.0
        emitter.particleAlphaSequence = SKKeyframeSequence(keyframeValues: [0.8, 0.0], times: [0, 1])
        emitter.particleScaleSequence = SKKeyframeSequence(keyframeValues: [0.2, 0.5], times: [0, 1])
        
        // Particle physics (a quick, sharp burst)
        emitter.particleLifetime = 0.4  // Was 1.0
        emitter.particleSpeed = 100     // Was 50
        emitter.particleSpeedRange = 75 // Was 50
        emitter.emissionAngle = .pi / 2 // Straight up
        emitter.emissionAngleRange = .pi / 4 // A wide cone
        
        addEffect(emitter)
    }
    
    // In EffectManager.swift

//    /// Creates and returns a dust cloud emitter node that cleans itself up.
//    func getBoulderSummonEffect() -> SKEmitterNode {
//        let emitter = SKEmitterNode()
//        // ... (all your existing setup code for the emitter's color, speed, etc.)
//        emitter.particleTexture = particleTexture
//        emitter.position = .zero
//        
//        // Emitter settings
//        emitter.numParticlesToEmit = 30
//        emitter.particleBirthRate = 1000 // A quick burst
//        
//        // Particle appearance (dusty brown color)
//        emitter.particleColor = UIColor(red: 0.6, green: 0.4, blue: 0.2, alpha: 1.0)
//        emitter.particleColorBlendFactor = 1.0
//        emitter.particleAlphaSequence = SKKeyframeSequence(keyframeValues: [0.8, 0.0], times: [0, 1])
//        emitter.particleScaleSequence = SKKeyframeSequence(keyframeValues: [0.2, 0.5], times: [0, 1])
//        // This action makes the emitter remove itself after it's finished.
//        let totalDuration = TimeInterval(CGFloat(emitter.numParticlesToEmit) / emitter.particleBirthRate + emitter.particleLifetime)
//        let removeAction = SKAction.sequence([.wait(forDuration: totalDuration), .removeFromParent()])
//        emitter.run(removeAction)
//        
//        return emitter
//    }

    
    /// Plays an impact spark effect for when a boulder hits an enemy.
    func playBoulderImpactEffect(at position: CGPoint, level: Int) {
        let emitter = SKEmitterNode()
        emitter.particleTexture = particleTexture
        emitter.position = position
        
        // --- THE FIX: Make the base effect smaller and scale it with level ---
        emitter.numParticlesToEmit = 10 + (level * 3) // Was 20
        emitter.particleBirthRate = 1000
        
        emitter.particleColor = .white
        emitter.particleColorBlendFactor = 1.0
        emitter.particleAlphaSequence = SKKeyframeSequence(keyframeValues: [1.0, 0.0], times: [0, 1])
        
        let scale = 0.15 + (CGFloat(level) * 0.03) // Was 0.2
        emitter.particleScaleSequence = SKKeyframeSequence(keyframeValues: [scale, 0.0], times: [0, 1])
        
        // A sharp, outward burst
        emitter.particleLifetime = 0.3 // Was 0.4
        emitter.particleSpeed = 200 + CGFloat(level * 15) // Was 250
        emitter.particleSpeedRange = 100
        emitter.emissionAngleRange = .pi * 2 // 360 degrees
        
        addEffect(emitter)
    }
    
    // In EffectManager.swift

    /// Plays a small spark effect for when a rock piece hits an enemy.
    func playRockPieceImpactEffect(at position: CGPoint, level: Int) {
        let emitter = SKEmitterNode()
        emitter.particleTexture = particleTexture
        emitter.position = position

        // --- THE FIX: Scale all properties with level ---
        emitter.numParticlesToEmit = 5 + (level * 2)
        emitter.particleBirthRate = 500
        
        emitter.particleColor = .white
        emitter.particleColorBlendFactor = 1.0
        emitter.particleAlphaSequence = SKKeyframeSequence(keyframeValues: [1.0, 0.0], times: [0, 1])
        let scale = 0.1 + (CGFloat(level) * 0.02)
        emitter.particleScale = scale

        emitter.particleLifetime = 0.2
        emitter.particleSpeed = 200 + CGFloat(level * 15)
        emitter.particleSpeedRange = 50
        emitter.emissionAngleRange = .pi * 2

        addEffect(emitter)
    }
    
    // In EffectManager.swift

    /// Plays a brown, dusty explosion effect for when a pillar is destroyed.
    func playPillarDestroyedEffect(at position: CGPoint) {
        let emitter = SKEmitterNode()
        emitter.particleTexture = particleTexture
        emitter.position = position

        emitter.numParticlesToEmit = 50
        emitter.particleBirthRate = 2000 // A very fast burst

        // A dusty brown color
        emitter.particleColor = UIColor(red: 0.6, green: 0.4, blue: 0.2, alpha: 1.0)
        emitter.particleColorBlendFactor = 1.0
        emitter.particleAlphaSequence = SKKeyframeSequence(keyframeValues: [0.8, 0.0], times: [0, 1])
        emitter.particleScaleSequence = SKKeyframeSequence(keyframeValues: [0.3, 0.1], times: [0, 1])

        // A slower, more billowy explosion
        emitter.particleLifetime = 1.2
        emitter.particleSpeed = 100
        emitter.particleSpeedRange = 80
        emitter.emissionAngleRange = .pi * 2 // 360 degrees

        addEffect(emitter)
    }
    
    /// A helper function to add an emitter to the scene and have it clean itself up.
    private func addEffect(_ emitter: SKEmitterNode) {
        // The total duration is how long the emitter lives plus how long the last particle lives.
        let totalDuration = CGFloat(emitter.numParticlesToEmit) / emitter.particleBirthRate + emitter.particleLifetime
        
        let removeAction = SKAction.sequence([
            SKAction.wait(forDuration: TimeInterval(totalDuration)),
            SKAction.removeFromParent()
        ])
        
        emitter.run(removeAction)
        scene?.worldNode.addChild(emitter)
    }
}
