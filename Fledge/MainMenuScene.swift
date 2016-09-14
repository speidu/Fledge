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
    var skyColor = UIColor(red: 133.0/255.0, green: 197.0/255.0, blue: 207.0/255.0, alpha: 1.0)
    let userSettingsDefaults: UserDefaults = UserDefaults.standard
    var highscore = Int()
    var notFirstTime = Bool()
    var muted = Bool()
    
    // Screen size detection
    let screenSize: CGRect = UIScreen.main.bounds
    
    override func didMove(to view: SKView) {
        //Background color
        backgroundColor = skyColor
        
        //Gametitle
        let myLabel = SKLabelNode(fontNamed:"Avenir Next")
        myLabel.text = "Best Game EU"
        myLabel.fontSize = 45
        myLabel.position = CGPoint(x:self.frame.midX, y:CGFloat(self.frame.size.height * 0.8))
        self.addChild(myLabel)
        
        //PlayButton Setup
        playButton = UIButton(type: UIButtonType.custom) as UIButton!
        playButton.setImage(playButtonImage, for: .normal)
        playButton.frame = CGRect(x: self.frame.size.width / 2, y: self.frame.size.height * 0.5, width: 80, height: 80)
        playButton.layer.anchorPoint = CGPoint(x: 1.0, y: 1.0)
        playButton.layer.zPosition = 5
        //Make the playButton perform an action when pressed
        playButton.addTarget(self, action: #selector(MainMenuScene.playAgainButtonAction(_:)), for: UIControlEvents.touchUpInside)
        
        notFirstTime = userSettingsDefaults.bool(forKey: "NotFirstTime")
        muted = userSettingsDefaults.bool(forKey: "Muted")
        
        //muteButton Setup
        muteButton = UIButton(type: UIButtonType.custom) as UIButton!
        if (muted == false) {
            muteButton.setImage(unmutedImage, for: .normal)
        } else {
            muteButton.setImage(mutedImage, for: .normal)
        }
        //muteButton,frame = CGRectMake(self.frame.size.width / 2, self.frame.size.height * 0.65, 80, 80)
        muteButton.layer.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        muteButton.layer.zPosition = 5
        muteButton.addTarget(self, action: #selector(MainMenuScene.muteAudio(_:)), for: UIControlEvents.touchUpInside)
        
        //HighScoreButton Setup
        highscore = userSettingsDefaults.integer(forKey: "Highscore")
        let highscoreLabel = SKLabelNode(fontNamed:"Avenir Next")
        highscoreLabel.text = "Highscore: \(highscore)"
        highscoreLabel.fontSize = 40
        
        // Access the current screen width
        let screenWidth = self.screenSize.height
        
        // ADD EVERYTHING DEFINED ABOVE TO THE CORRECT POSITION DEPENDING ON DEVICE HEIGHT (POINTS)
        switch screenWidth {
        case 0...480:
            // Iphone 4
            playButton.frame = CGRect(x: self.frame.size.width / 2.7, y: self.frame.size.height * 0.35, width: 80, height: 80)
            muteButton.frame = CGRect(x: self.frame.size.width / 2.7, y: self.frame.size.height * 0.60, width: 80, height: 80)
            highscoreLabel.position = CGPoint(x:self.frame.midX, y:CGFloat(self.frame.size.height * 0.1))
        case 481...568:
            // Iphone 5
            playButton.frame = CGRect(x: self.frame.width / 2.7, y: self.frame.size.height * 0.35, width: 80, height: 80)
            muteButton.frame = CGRect(x: self.frame.size.width / 2.7, y: self.frame.size.height * 0.60, width: 80, height: 80)
            highscoreLabel.position = CGPoint(x:self.frame.midX, y:CGFloat(self.frame.size.height * 0.1))
        case 569...667:
            // Iphone 6
            playButton.frame = CGRect(x: self.frame.size.width / 2.6, y: self.frame.size.height * 0.37, width: 80, height: 80)
            muteButton.frame = CGRect(x: self.frame.size.width / 2.6, y: self.frame.size.height * 0.60, width: 80, height: 80)
            highscoreLabel.position = CGPoint(x:self.frame.midX, y:CGFloat(self.frame.size.height * 0.1))
        default:
            // Iphone 6 plus
            playButton.frame = CGRect(x: self.frame.size.width / 2.5, y: self.frame.size.height * 0.37, width: 80, height: 80)
            muteButton.frame = CGRect(x: self.frame.size.width / 2.5, y: self.frame.size.height * 0.60, width: 80, height: 80)
            highscoreLabel.position = CGPoint(x:self.frame.midX, y:CGFloat(self.frame.size.height * 0.1))
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
            if self.notFirstTime == true {
                //Play the game
                self.transitionToScene("play")
            } else {
                self.transitionToScene("howToPlay")
            }
        }
    }
    
    func howToPlayButtonAction(_ sender: UIButton!) {
        delay(0.2) {
            self.transitionToScene("howToPlay")
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
        } else if toScene == "howToPlay" {
            scene = HowToPlayScene(size: skView.bounds.size)
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
