//
//  ImageGalleryNode.swift
//  RockMagic
//
//  Created by Tucker Hoppe on 7/29/25.
//

// In ImageGalleryNode.swift


import SpriteKit

class ImageGalleryNode: SKNode {

    // --- Properties ---
    private var imageSprite: SKSpriteNode!
    private var nextButton: SKLabelNode!
    private var prevButton: SKLabelNode!
    
    private var imageTextures: [SKTexture] = []
    private var currentIndex = 0

    // In ImageGalleryNode.swift

    init(size: CGSize, imageNames: [String]) {
        super.init()
        
//        let background = SKSpriteNode(color: .red, size: size)
//        background.position = .zero
//            background.zPosition = 0// Place it behind all other content
//            addChild(background)
        
        // 1. Load all the image textures
        for name in imageNames {
            imageTextures.append(SKTexture(imageNamed: name))
        }
        
        // 2. Create the main sprite node
        imageSprite = SKSpriteNode(texture: imageTextures.first)
        
        // --- THE FIX: Scale the image proportionally ---
        if let texture = imageSprite.texture {
            let textureSize = texture.size()
            // Calculate how much to scale the width and height
            let scaleX = size.width / textureSize.width
            let scaleY = size.height / textureSize.height
            // Use the smaller of the two scales to ensure the image fits completely
            let scale = min(scaleX, scaleY)
            imageSprite.setScale(scale)
        }
        // ---------------------------------------------
        
        imageSprite.position = .zero
        imageSprite.zPosition = 0 // The image is the base layer
        addChild(imageSprite)
        
        let buttonYPosition = -size.height / 2 + 50
        
        // 3. Create the navigation buttons (this part is the same)
        prevButton = SKLabelNode(fontNamed: "Menlo-Bold")
        prevButton.text = "< Prev"
        prevButton.fontSize = 24
        prevButton.fontColor = .cyan
        prevButton.position = CGPoint(x: -size.width/2 + 50, y: buttonYPosition)
        prevButton.name = "prevButton"
        prevButton.zPosition = 5 // Draw the button in front of the image
        addChild(prevButton)
        
        nextButton = SKLabelNode(fontNamed: "Menlo-Bold")
        nextButton.text = "Next >"
        nextButton.fontSize = 24
        nextButton.fontColor = .cyan
        nextButton.position = CGPoint(x: size.width/2 - 50, y: buttonYPosition)
        nextButton.name = "nextButton"
        nextButton.zPosition = 5 // Draw the button in front of the image
        addChild(nextButton)
        
        updateButtonVisibility()
        
        isUserInteractionEnabled = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // --- Touch Handling ---
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        let tappedNode = atPoint(location)
        
        if tappedNode.name == "nextButton" {
            showNextImage()
        } else if tappedNode.name == "prevButton" {
            showPreviousImage()
        }
    }
    
    // --- Gallery Logic ---
    private func showNextImage() {
        if currentIndex < imageTextures.count - 1 {
            currentIndex += 1
            imageSprite.texture = imageTextures[currentIndex]
            updateButtonVisibility()
        }
    }
    
    private func showPreviousImage() {
        if currentIndex > 0 {
            currentIndex -= 1
            imageSprite.texture = imageTextures[currentIndex]
            updateButtonVisibility()
        }
    }
    
    private func updateButtonVisibility() {
        // Hide "Prev" on the first image, hide "Next" on the last image
        prevButton.isHidden = (currentIndex == 0)
        nextButton.isHidden = (currentIndex == imageTextures.count - 1)
    }
}
