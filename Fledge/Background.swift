//
//  Background.swift
//  Lanit
//
//  Created by pasi on 15.7.2016.
//  Copyright © 2016 Pasi Särkilahti & Teemu Salminen. All rights reserved.
//

import Foundation
import SpriteKit

class Background : SKSpriteNode {
    
    var deviceBackgroundTexture = SKTexture()
    
    // Screen size detection
    let screenSize: CGRect = UIScreen.mainScreen().bounds
    
    init(size:CGSize) {
        super.init(texture: nil, color: UIColor.clearColor(), size: CGSizeMake(size.width, size.height))
        zPosition = 5
        anchorPoint = CGPoint(x: 0.5, y: 0)
        
        // Access the current screen height
        let screenWidth = self.screenSize.height
        
        if (screenWidth == 667) {
            deviceBackgroundTexture = SKTexture(imageNamed: "BackgroundIphone6")
        } else {
            deviceBackgroundTexture = SKTexture(imageNamed: "Background")
        }
        
        var i: CGFloat = -1
        while i < 2 + self.frame.size.width / deviceBackgroundTexture.size().width {
            i += 1
            
            let platformsprite = SKSpriteNode(texture: deviceBackgroundTexture)
            
            // Add to the correct position depending on device height (points)
            switch screenWidth {
            case 0...480:
                // Iphone 4
                platformsprite.position = CGPointMake(i * platformsprite.size.width, 406)
            case 481...568:
                // Iphone 5
                platformsprite.position = CGPointMake(i * platformsprite.size.width, 486)
            case 569...667:
                // Iphone 6
                platformsprite.position = CGPointMake(i * platformsprite.size.width, 524)
            default:
                // Iphone 6 plus
                platformsprite.position = CGPointMake(i * platformsprite.size.width, 565)
            }
            addChild(platformsprite)
        }
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func begin() {
        // Moving the ground at speed
        let moveGroundSprite = SKAction.moveByX(-deviceBackgroundTexture.size().width, y: 0, duration: NSTimeInterval(0.01 * deviceBackgroundTexture.size().width))
        let resetGroundSprite = SKAction.moveByX(deviceBackgroundTexture.size().width, y: 0, duration: 0.0)
        let moveSequence = SKAction.sequence([moveGroundSprite, resetGroundSprite])
        runAction(SKAction.repeatActionForever(moveSequence))
    }
    
    func stop() {
        self.removeAllActions()
        self.removeFromParent()
    }
    
}