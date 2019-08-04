//
//  Scene.swift
//  DefusAR
//
//  Created by Kilian Kellermann on 01.08.19.
//  Copyright © 2019 Kilian Kellermann. All rights reserved.
//

import SpriteKit
import ARKit

class Scene: SKScene {
    
    var playing = false
    
    var bombTimer: Timer?
    var score = 0
    
    override func didMove(to view: SKView) {
        displayMenu()
    }
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
    }
    
    func displayMenu() {
        let logoLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
        logoLabel.fontSize = 50.0
        logoLabel.text = "DefusAR"
        logoLabel.verticalAlignmentMode = .center
        logoLabel.horizontalAlignmentMode = .center
        logoLabel.position = CGPoint(x: frame.midX, y: frame.midY + logoLabel.frame.size.height)
        logoLabel.name = "Menu"
        addChild(logoLabel)
        
        let infoLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
        infoLabel.fontSize = 30.0
        infoLabel.text = "Tap to play!"
        infoLabel.verticalAlignmentMode = .center
        infoLabel.horizontalAlignmentMode = .center
        infoLabel.position = CGPoint(x: frame.midX, y: frame.midY - infoLabel.frame.size.height)
        infoLabel.name = "Menu"
        addChild(infoLabel)
        
        let highscoreLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
        highscoreLabel.fontSize = 30.0
        highscoreLabel.text = "Best: \(UserDefaults.standard.integer(forKey: "Highscore"))"
        highscoreLabel.verticalAlignmentMode = .center
        highscoreLabel.horizontalAlignmentMode = .center
        highscoreLabel.position = CGPoint(x: frame.midX, y: infoLabel.position.y - highscoreLabel.frame.size.height * 2)
        highscoreLabel.name = "Menu"
        addChild(highscoreLabel)

    }
    
    func addNewBomb() {
        guard let sceneView = self.view as? ARSKView else {
            return
        }
        
        if let currentFrame = sceneView.session.currentFrame {
            let xOffset = Float(arc4random_uniform(UInt32(30)))/10 - 1.5
            let zOffset = Float(arc4random_uniform(UInt32(10)))/10 + 0.5
            
            var transform = matrix_identity_float4x4
            transform.columns.3.x = currentFrame.camera.transform.columns.3.x - xOffset
            transform.columns.3.z = currentFrame.camera.transform.columns.3.z - zOffset
            transform.columns.3.y = currentFrame.camera.transform.columns.3.y
            
            let anchor = ARAnchor(transform: transform)
            sceneView.session.add(anchor: anchor)
            
            bombTimer = Timer.scheduledTimer(timeInterval: 5.0, target: self, selector: #selector(explode), userInfo: nil, repeats: false)
        }
    }
    
    @objc func explode() {
        bombTimer?.invalidate()
        if UserDefaults.standard.integer(forKey: "Highscore") < score {
            UserDefaults.standard.set(score, forKey: "Highscore")
        }
        for node in children {
            if let node = node as? SKLabelNode, node.name == "Bomb" {
                node.text = "💥"
                node.name = "Menu"
                let scaleExplode = SKAction.scale(to: 50.0, duration: 1.0)
                node.run(scaleExplode, completion: {
                    self.displayMenu()
                })
            }
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if !playing {
            playing = true
            for label in children {
                label.removeFromParent()
            }
            addNewBomb()
        } else {
            guard let location = touches.first?.location(in: self) else {
                return
            }
            
            for node in children {
                if node.contains(location), node.name == "Bomb" {
                    bombTimer?.invalidate()
                    score += 1
                    let fadeOut = SKAction.fadeOut(withDuration: 0.5)
                    node.run(fadeOut, completion: {
                        node.removeFromParent()
                        self.addNewBomb()
                    })
                }
            }
        }
    }
}
