//
//  MountainsBackground.swift
//  Lanit
//
//  Created by pasi on 26.7.2016.
//  Copyright © 2016 Pasi Särkilahti. All rights reserved.
//

import Foundation
import SpriteKit

class MountainsBackground : SKSpriteNode {
    
    var TopMountainBackgroundTexture = SKTexture()
    
    // Screen size detection
    let screenSize: CGRect = UIScreen.mainScreen().bounds
    
    init(size:CGSize) {
        super.init(texture: nil, color: UIColor.clearColor(), size: CGSizeMake(size.width, size.height))
        zPosition = 3
        anchorPoint = CGPoint(x: 0.5, y: 0)
        
        // Access the current screen height
        let screenWidth = self.screenSize.height
        
        if (screenWidth == 667) {
            TopMountainBackgroundTexture = SKTexture(imageNamed: "TopMountainsBackgroundIphone6")
        } else {
            TopMountainBackgroundTexture = SKTexture(imageNamed: "TopMountainsBackground")
        }
        
        var i: CGFloat = -1
        while i < 2 + self.frame.size.width / TopMountainBackgroundTexture.size().width {
            i += 1
            let mountainSprite = SKSpriteNode(texture: TopMountainBackgroundTexture)
            
            // Access the current screen width
            let screenWidth = self.screenSize.height
            
            // Add to the correct position depending on device height (points)
            switch screenWidth {
            case 0...480:
                // Iphone 4
                mountainSprite.position = CGPointMake(i * mountainSprite.size.width, 527)
            case 481...568:
                // Iphone 5
                mountainSprite.position = CGPointMake(i * mountainSprite.size.width, 607)
            case 569...667:
                // Iphone 6
                mountainSprite.position = CGPointMake(i * mountainSprite.size.width, 630)
            default:
                // Iphone 6 plus
                mountainSprite.position = CGPointMake(i * mountainSprite.size.width, 685)
            }
            addChild(mountainSprite)
        }
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func begin() {
        // Moving the ground at speed
        let moveGroundSprite = SKAction.moveByX(-TopMountainBackgroundTexture.size().width, y: 0, duration: NSTimeInterval(0.065 * TopMountainBackgroundTexture.size().width))
        let resetGroundSprite = SKAction.moveByX(TopMountainBackgroundTexture.size().width, y: 0, duration: 0.0)
        let moveSequence = SKAction.sequence([moveGroundSprite, resetGroundSprite])
        runAction(SKAction.repeatActionForever(moveSequence))
    }
    
    func stop() {
        self.removeAllActions()
        self.removeFromParent()
    }
    
}