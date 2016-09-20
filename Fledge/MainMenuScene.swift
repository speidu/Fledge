//
//  MainMenuScene.swift
//  Lanit
//
//  Created by Pasi Särkilahti on 13.2.2016.
//  Copyright © 2016 Pasi Särkilahti & Teemu Salminen All rights reserved.
//

import Foundation
import UIKit
import SpriteKit

class MainMenuScene: SKScene{
    
    var playButton = UIButton()
    var playButtonImage = UIImage(named: "playButtonImage") as UIImage!
    var muteButton = UIButton()
    var unmutedImage = UIImage(named: "Unmuted") as UIImage!
    var mutedImage = UIImage(named: "Muted") as UIImage!
    let userSettingsDefaults: UserDefaults = UserDefaults.standard
    var highscore = Int()
    var muted = Bool()
    
    // Screen size detection
    let screenSize: CGRect = UIScreen.main.bounds
    
    override func didMove(to view: SKView) {
        // Access the current screen width
        let screenWidth = self.screenSize.height
        
        var background = SKSpriteNode()
        
        switch screenWidth {
        case 569...667:
            background = SKSpriteNode(imageNamed: "iPhone6Background")
        default:
            background = SKSpriteNode(imageNamed: "MenuBackground")
        }
        background.position = CGPoint(x:self.frame.width / 2, y: self.frame.height / 2)
        self.addChild(background)
        
        //PlayButton Setup
        playButton = UIButton(type: UIButtonType.custom) as UIButton!
        playButton.setImage(playButtonImage, for: .normal)
        playButton.frame = CGRect(x: self.frame.size.width / 2, y: self.frame.size.height * 0.5, width: 80, height: 80)
        playButton.layer.anchorPoint = CGPoint(x: 1.0, y: 1.0)
        playButton.layer.zPosition = 5
        //Make the playButton perform an action when pressed
        playButton.addTarget(self, action: #selector(MainMenuScene.playAgainButtonAction(_:)), for: UIControlEvents.touchUpInside)
        
        muted = userSettingsDefaults.bool(forKey: "Muted")
        
        //muteButton Setup
        muteButton = UIButton(type: UIButtonType.custom) as UIButton!
        if (muted == false) {
            muteButton.setImage(unmutedImage, for: .normal)
        } else {
            muteButton.setImage(mutedImage, for: .normal)
        }

        muteButton.layer.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        muteButton.layer.zPosition = 5
        muteButton.addTarget(self, action: #selector(MainMenuScene.muteAudio(_:)), for: UIControlEvents.touchUpInside)
        
        //HighScoreButton Setup
        highscore = userSettingsDefaults.integer(forKey: "Highscore")
        let highscoreLabel = SKLabelNode(fontNamed:"VCROSDMono")
        highscoreLabel.text = "HIGHSCORE: \(highscore)"
        highscoreLabel.fontSize = 35
        highscoreLabel.zPosition = 6
        
        // ADD EVERYTHING DEFINED ABOVE TO THE CORRECT POSITION DEPENDING ON DEVICE HEIGHT (POINTS)
        switch screenWidth {
        case 0...568:
            // Iphone 5
            playButton.frame = CGRect(x: self.frame.width / 2.7, y: self.frame.size.height * 0.30, width: 80, height: 80)
            muteButton.frame = CGRect(x: self.frame.size.width / 2.38, y: self.frame.size.height * 0.55, width: 50, height: 50)
            highscoreLabel.position = CGPoint(x:self.frame.midX, y:CGFloat(self.frame.size.height * 0.25))
        case 569...667:
            // Iphone 6
            playButton.frame = CGRect(x: self.frame.size.width / 2.6, y: self.frame.size.height * 0.33, width: 80, height: 80)
            muteButton.frame = CGRect(x: self.frame.size.width / 2.34, y: self.frame.size.height * 0.55, width: 50, height: 50)
            highscoreLabel.position = CGPoint(x:self.frame.midX, y:CGFloat(self.frame.size.height * 0.25))
        default:
            // Iphone 6 plus
            playButton.frame = CGRect(x: self.frame.size.width / 2.5, y: self.frame.size.height * 0.32, width: 80, height: 80)
            muteButton.frame = CGRect(x: self.frame.size.width / 2.27, y: self.frame.size.height * 0.55, width: 50, height: 50)
            highscoreLabel.position = CGPoint(x:self.frame.midX, y:CGFloat(self.frame.size.height * 0.27))
            highscoreLabel.fontSize = 40
        }
        
        view.addSubview(self.playButton)
        view.addSubview(self.muteButton)
        self.addChild(highscoreLabel)
    }
    
    func delay(_ delay: Double, closure: @escaping ()->()) {
        //dispatch_after(dispatch_time(dispatch_time_t(DISPATCH_TIME_NOW), Int64(delay * Double(NSEC_PER_SEC))), dispatch_get_main_queue(), closure)
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
            closure()
        }
    }
    
    func playAgainButtonAction(_ sender: UIButton!) {
        delay(0.2) {
                //Play the game
                self.transitionToScene("play")
        }
    }
    
    func muteAudio(_ sender: UIButton!) {
        if (muted == false) {
            muted = true
            userSettingsDefaults.set(muted, forKey: "Muted")
            muteButton.setImage(mutedImage, for: .normal)
        } else {
            muted = false
            userSettingsDefaults.set(muted, forKey: "Muted")
            muteButton.setImage(unmutedImage, for: .normal)
        }
    }
    
    func transitionToScene(_ toScene: String) {
        //Remove label and buttons
        playButton.removeFromSuperview()
        muteButton.removeFromSuperview()
        self.removeAllChildren()
        
        //Setup transition to GameScene
        let skView = self.view! as SKView
        skView.ignoresSiblingOrder = true
        
        //Remove current scene before transitioning
        self.scene?.removeFromParent()
        
        //Transition effect
        let transition = SKTransition.fade(with: skyColor, duration: 1.0)
        transition.pausesOutgoingScene = false
        
        //scene
        var scene: SKScene!
        if toScene == "play" {
            scene = GameScene(size: skView.bounds.size)
            scene.scaleMode = .aspectFill
        }
        //Present new scene with transition effect
        skView.presentScene(scene, transition: transition)
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        /* Called when a touch begins */
    }
    
    override func update(_ currentTime: TimeInterval) {
        /* Called before each frame is rendered */
    }
    
}
