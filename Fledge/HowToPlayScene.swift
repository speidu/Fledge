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
    
    let userSettingsDefaults: UserDefaults = UserDefaults.standard
    
    var notFirstTime = Bool()
    
    
    override func didMove(to view: SKView) {
        backgroundColor = skyColor
        
        background.position = CGPoint(x: self.frame.size.width / 2, y: self.frame.size.height / 2)
        background.size = view.bounds.size
        background.texture = SKTexture(imageNamed: "HowToPlay1")
        background.zPosition = 2
        self.addChild(background)
        
        backButton = UIButton(type: UIButtonType.custom) as UIButton!
        backButton.setImage(backButtonImage, for: .normal)
        backButton.frame = CGRect(x: self.frame.size.width * 0.2, y: self.frame.size.height * 0.9, width: 80, height: 80)
        backButton.layer.anchorPoint = CGPoint(x: 1.0, y: 1.0)
        backButton.layer.zPosition = 5
        //Make the playButton perform an action when pressed
        backButton.addTarget(self, action: #selector(HowToPlayScene.backButtonAction(_:)), for: UIControlEvents.touchUpInside)
        view.addSubview(self.backButton)
        
        nextButton = UIButton(type: UIButtonType.custom) as UIButton!
        nextButton.setImage(nextButtonImage, for: .normal)
        nextButton.frame = CGRect(x: self.frame.size.width * 0.8, y: self.frame.size.height * 0.9, width: 80, height: 80)
        nextButton.layer.anchorPoint = CGPoint(x: 1.0, y: 1.0)
        nextButton.layer.zPosition = 5
        //Make the playButton perform an action when pressed
        nextButton.addTarget(self, action: #selector(HowToPlayScene.nextButtonAction(_:)), for: UIControlEvents.touchUpInside)
        view.addSubview(self.nextButton)
        
    }
    
    func delay(_ delay: Double, closure: @escaping ()->()) {
        //dispatch_after(dispatch_time(dispatch_time_t(DISPATCH_TIME_NOW), Int64(delay * Double(NSEC_PER_SEC))), dispatch_get_main_queue(), closure)
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
            closure()
        }
    }
    
    func backButtonAction(_ sender: UIButton!) {
        delay(0.2) {
            //Return to main menu
            self.transitionToScene("back")
        }
    }
    
    func nextButtonAction(_ sender: UIButton!) {
        delay(0.2) {
            //Transition to game scene
            self.transitionToScene("next")
            self.notFirstTime = true
            self.userSettingsDefaults.set(self.notFirstTime, forKey: "NotFirstTime")
            
        }
    }
    
    func transitionToScene(_ toScene: String) {
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
        let transition = SKTransition.fade(with: skyColor, duration: 1.0)
        transition.pausesOutgoingScene = false
        
        //scene
        var scene: SKScene!
        if toScene == "back" {
            scene = MainMenuScene(size: skView.bounds.size)
            scene.scaleMode = .aspectFill
        } else if toScene == "next" {
            scene = GameScene(size: skView.bounds.size)
            scene.scaleMode = .aspectFill
        }
        
        //Present new scene with transition effect
        skView.presentScene(scene, transition: transition)
        
    }
}
