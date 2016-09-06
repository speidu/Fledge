//
//  HowToPlayScene.swift
//  Lanit
//
//  Created by Teemu on 23.7.2016.
//  Copyright © 2016 Pasi Särkilahti. All rights reserved.
//

import Foundation
import UIKit
import SpriteKit

class HowToPlayScene: SKScene {
    
    var skyColor = UIColor(red: 133.0/255.0, green: 197.0/255.0, blue: 207.0/255.0, alpha: 1.0)
    var backButton = UIButton()
    var backButtonImage = UIImage(named: "BackButton") as UIImage!
    var nextButton = UIButton()
    var nextButtonImage = UIImage(named: "NextButton") as UIImage!
    var imageView: UIImageView!
    var background = SKSpriteNode()
    
    let userSettingsDefaults: NSUserDefaults = NSUserDefaults.standardUserDefaults()
    
    var notFirstTime = Bool()
    
    
    override func didMoveToView(view: SKView) {
        backgroundColor = skyColor
        
        background.position = CGPointMake(self.frame.size.width / 2, self.frame.size.height / 2)
        background.size = view.bounds.size
        background.texture = SKTexture(imageNamed: "HowToPlay1")
        background.zPosition = 2
        self.addChild(background)
        
        backButton = UIButton(type: UIButtonType.Custom) as UIButton!
        backButton.setImage(backButtonImage, forState: .Normal)
        backButton.frame = CGRectMake(self.frame.size.width * 0.2, self.frame.size.height * 0.9, 80, 80)
        backButton.layer.anchorPoint = CGPointMake(1.0, 1.0)
        backButton.layer.zPosition = 5
        //Make the playButton perform an action when pressed
        backButton.addTarget(self, action: #selector(HowToPlayScene.backButtonAction(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        view.addSubview(self.backButton)
        
        nextButton = UIButton(type: UIButtonType.Custom) as UIButton!
        nextButton.setImage(nextButtonImage, forState: .Normal)
        nextButton.frame = CGRectMake(self.frame.size.width * 0.8, self.frame.size.height * 0.9, 80, 80)
        nextButton.layer.anchorPoint = CGPointMake(1.0, 1.0)
        nextButton.layer.zPosition = 5
        //Make the playButton perform an action when pressed
        nextButton.addTarget(self, action: #selector(HowToPlayScene.nextButtonAction(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        view.addSubview(self.nextButton)
        
    }
    
    func delay(delay: Double, closure: ()->()) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(delay * Double(NSEC_PER_SEC))), dispatch_get_main_queue(), closure)
    }
    
    func backButtonAction(sender: UIButton!) {
        delay(0.2) {
            //Return to main menu
            self.transitionToScene("back")
        }
    }
    
    func nextButtonAction(sender: UIButton!) {
        delay(0.2) {
            //Transition to game scene
            self.transitionToScene("next")
            self.notFirstTime = true
            self.userSettingsDefaults.setBool(self.notFirstTime, forKey: "NotFirstTime")
            
        }
    }
    
    func transitionToScene(toScene: String) {
        //Remove label and buttons
        nextButton.removeFromSuperview()
        backButton.removeFromSuperview()
        background.removeFromParent()
        
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
        if toScene == "back" {
            scene = MainMenuScene(size: skView.bounds.size)
            scene.scaleMode = .AspectFill
        } else if toScene == "next" {
            scene = GameScene(size: skView.bounds.size)
            scene.scaleMode = .AspectFill
        }
        
        //Present new scene with transition effect
        skView.presentScene(scene, transition: transition)
        
    }
}