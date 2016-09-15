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
    let screenSize: CGRect = UIScreen.main.bounds
    
    init(size:CGSize) {
        super.init(texture: nil, color: UIColor.clear, size: CGSize(width: size.width, height: size.height))
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
            case 0...568:
                // Iphone 5
                mountainSprite.position = CGPoint(x: i * mountainSprite.size.width, y: 607)
            case 569...667:
                // Iphone 6
                mountainSprite.position = CGPoint(x: i * mountainSprite.size.width, y: 630)
            default:
                // Iphone 6 plus
                mountainSprite.position = CGPoint(x: i * mountainSprite.size.width, y: 685)
            }
            addChild(mountainSprite)
        }
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func begin() {
        // Moving the ground at speed
        let moveGroundSprite = SKAction.moveBy(x: -TopMountainBackgroundTexture.size().width, y: 0, duration: TimeInterval(0.065 * TopMountainBackgroundTexture.size().width))
        let resetGroundSprite = SKAction.moveBy(x: TopMountainBackgroundTexture.size().width, y: 0, duration: 0.0)
        let moveSequence = SKAction.sequence([moveGroundSprite, resetGroundSprite])
        run(SKAction.repeatForever(moveSequence))
    }
    
    func stop() {
        self.removeAllActions()
        self.removeFromParent()
    }
    
}
