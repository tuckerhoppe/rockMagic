//
//  HighScoreScene.swift
//  RockMagic
//
//  Created by Tucker Hoppe on 8/15/25.
//

import SpriteKit

// In GameViewController.swift

protocol HighScoreSceneDelegate: AnyObject {
    func highScoreSceneDidRequestMainMenu(_ scene: HighScoreScene)
}
class HighScoreScene: SKScene {
    weak var highScoreDelegate: HighScoreSceneDelegate?


    override func didMove(to view: SKView) {
        backgroundColor = .darkGray
        
        let loadingLabel = SKLabelNode(fontNamed: "Menlo-Regular")
        loadingLabel.text = "Loading Scores..."
        loadingLabel.position = CGPoint(x: self.size.width / 2, y: self.size.height / 2)
        addChild(loadingLabel)
        
        CloudKitManager.shared.fetchHighScores { (scores, error) in
            loadingLabel.removeFromParent()
            
            if let scores = scores, !scores.isEmpty {
                self.displayScores(scores)
            } else {
                let noScoresLabel = SKLabelNode(fontNamed: "Menlo-Regular")
                noScoresLabel.text = "No scores yet!"
                noScoresLabel.position = CGPoint(x: self.size.width / 2, y: self.size.height / 2)
                self.addChild(noScoresLabel)
            }
        }
        
        addBackButton()
    }
    
    private func displayScores(_ scores: [HighScore]) {
        let title = SKLabelNode(fontNamed: "Menlo-Bold")
        title.text = "High Scores"
        title.fontSize = 48
        title.position = CGPoint(x: self.size.width / 2, y: self.size.height * 0.85)
        addChild(title)
        
        for (index, score) in scores.prefix(5).enumerated() { // Show top 10
            let yPos = self.size.height * 0.7 - CGFloat(index * 50)
            
            let nameLabel = SKLabelNode(fontNamed: "Menlo-Regular")
            nameLabel.text = "\(index + 1). \(score.playerName)"
            nameLabel.horizontalAlignmentMode = .left
            nameLabel.position = CGPoint(x: self.size.width * 0.2, y: yPos)
            addChild(nameLabel)
            
            let scoreLabel = SKLabelNode(fontNamed: "Menlo-Bold")
            scoreLabel.text = "\(score.score)"
            scoreLabel.horizontalAlignmentMode = .right
            scoreLabel.position = CGPoint(x: self.size.width * 0.8, y: yPos)
            addChild(scoreLabel)
        }
    }
    
    private func addBackButton() {
        let backButton = SKLabelNode(fontNamed: "Menlo-Bold")
        backButton.text = "Back to Menu"
        backButton.name = "backButton"
        backButton.position = CGPoint(x: self.size.width / 2, y: self.size.height * 0.1)
        addChild(backButton)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first, let tappedNode = atPoint(touch.location(in: self)) as? SKLabelNode, tappedNode.name == "backButton" {
            
//            let mainMenu = MainMenuScene(size: self.size)
//            mainMenu.scaleMode = .aspectFill
//            self.view?.presentScene(mainMenu, transition: .fade(withDuration: 0.5))
            highScoreDelegate?.highScoreSceneDidRequestMainMenu(self)


        }
    }
}
