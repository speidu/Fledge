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
    let userSettingsDefaults: NSUserDefaults = NSUserDefaults.standardUserDefaults()
    var highscore = Int()
    var notFirstTime = Bool()
    var muted = Bool()
    
    // Screen size detection
    let screenSize: CGRect = UIScreen.mainScreen().bounds
    
    override func didMoveToView(view: SKView) {
        //Background color
        backgroundColor = skyColor
        
        //Gametitle
        let myLabel = SKLabelNode(fontNamed:"Avenir Next")
        myLabel.text = "Best Game EU"
        myLabel.fontSize = 45
        myLabel.position = CGPoint(x:CGRectGetMidX(self.frame), y:CGFloat(self.frame.size.height * 0.8))
        self.addChild(myLabel)
        
        //PlayButton Setup
        playButton = UIButton(type: UIButtonType.Custom) as UIButton!
        playButton.setImage(playButtonImage, forState: .Normal)
        playButton.frame = CGRectMake(self.frame.size.width / 2, self.frame.size.height * 0.5, 80, 80)
        playButton.layer.anchorPoint = CGPointMake(1.0, 1.0)
        playButton.layer.zPosition = 5
        //Make the playButton perform an action when pressed
        playButton.addTarget(self, action: #selector(MainMenuScene.playAgainButtonAction(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        
        notFirstTime = userSettingsDefaults.boolForKey("NotFirstTime")
        muted = userSettingsDefaults.boolForKey("Muted")
        
        //muteButton Setup
        muteButton = UIButton(type: UIButtonType.Custom) as UIButton!
        if (muted == false) {
            muteButton.setImage(unmutedImage, forState: .Normal)
        } else {
            muteButton.setImage(mutedImage, forState: .Normal)
        }
        //muteButton,frame = CGRectMake(self.frame.size.width / 2, self.frame.size.height * 0.65, 80, 80)
        muteButton.layer.anchorPoint = CGPointMake(0.5, 0.5)
        muteButton.layer.zPosition = 5
        muteButton.addTarget(self, action: #selector(MainMenuScene.muteAudio(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        
        //HighScoreButton Setup
        highscore = userSettingsDefaults.integerForKey("Highscore")
        let highscoreLabel = SKLabelNode(fontNamed:"Avenir Next")
        highscoreLabel.text = "Highscore: \(highscore)"
        highscoreLabel.fontSize = 40
        
        // Access the current screen width
        let screenWidth = self.screenSize.height
        
        // ADD EVERYTHING DEFINED ABOVE TO THE CORRECT POSITION DEPENDING ON DEVICE HEIGHT (POINTS)
        switch screenWidth {
        case 0...480:
            // Iphone 4
            playButton.frame = CGRectMake(self.frame.size.width / 2.7, self.frame.size.height * 0.35, 80, 80)
            muteButton.frame = CGRectMake(self.frame.size.width / 2.7, self.frame.size.height * 0.60, 80, 80)
            highscoreLabel.position = CGPoint(x:CGRectGetMidX(self.frame), y:CGFloat(self.frame.size.height * 0.1))
        case 481...568:
            // Iphone 5
            playButton.frame = CGRectMake(self.frame.width / 2.7, self.frame.size.height * 0.35, 80, 80)
            muteButton.frame = CGRectMake(self.frame.size.width / 2.7, self.frame.size.height * 0.60, 80, 80)
            highscoreLabel.position = CGPoint(x:CGRectGetMidX(self.frame), y:CGFloat(self.frame.size.height * 0.1))
        case 569...667:
            // Iphone 6
            playButton.frame = CGRectMake(self.frame.size.width / 2.6, self.frame.size.height * 0.37, 80, 80)
            muteButton.frame = CGRectMake(self.frame.size.width / 2.6, self.frame.size.height * 0.60, 80, 80)
            highscoreLabel.position = CGPoint(x:CGRectGetMidX(self.frame), y:CGFloat(self.frame.size.height * 0.1))
        default:
            // Iphone 6 plus
            playButton.frame = CGRectMake(self.frame.size.width / 2.5, self.frame.size.height * 0.37, 80, 80)
            muteButton.frame = CGRectMake(self.frame.size.width / 2.5, self.frame.size.height * 0.60, 80, 80)
            highscoreLabel.position = CGPoint(x:CGRectGetMidX(self.frame), y:CGFloat(self.frame.size.height * 0.1))
        }
        
        view.addSubview(self.playButton)
        view.addSubview(self.muteButton)
        self.addChild(highscoreLabel)
        
    }
    
    func delay(delay: Double, closure: ()->()) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(delay * Double(NSEC_PER_SEC))), dispatch_get_main_queue(), closure)
    }
    
    func playAgainButtonAction(sender: UIButton!) {
        delay(0.2) {
            if self.notFirstTime == true {
                //Play the game
                self.transitionToScene("play")
            } else {
                self.transitionToScene("howToPlay")
            }
        }
    }
    
    func howToPlayButtonAction(sender: UIButton!) {
        delay(0.2) {
            self.transitionToScene("howToPlay")
        }
    }
    
    func muteAudio(sender: UIButton!) {
        if (muted == false) {
            muted = true
            userSettingsDefaults.setBool(muted, forKey: "Muted")
            muteButton.setImage(mutedImage, forState: .Normal)
        } else {
            muted = false
            userSettingsDefaults.setBool(muted, forKey: "Muted")
            muteButton.setImage(unmutedImage, forState: .Normal)
        }
    }
    
    func transitionToScene(toScene: String) {
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
        let transition = SKTransition.fadeWithColor(skyColor, duration: 1.0)
        transition.pausesOutgoingScene = false
        
        //scene
        var scene: SKScene!
        if toScene == "play" {
            scene = GameScene(size: skView.bounds.size)
            scene.scaleMode = .AspectFill
        } else if toScene == "howToPlay" {
            scene = HowToPlayScene(size: skView.bounds.size)
            scene.scaleMode = .AspectFill
        }
        
        //Present new scene with transition effect
        skView.presentScene(scene, transition: transition)
        
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        /* Called when a touch begins */
    }
    
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
    }
    
}
