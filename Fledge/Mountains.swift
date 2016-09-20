//
//  Mountains.swift
//  Lanit
//
//  Created by pasi on 15.7.2016.
//  Copyright © 2016 Pasi Särkilahti & Teemu Salminen. All rights reserved.
//

import Foundation
import SpriteKit

class Mountains : SKSpriteNode {
    
    var TopMountainTexture = SKTexture()
    
    // Screen size detection
    let screenSize: CGRect = UIScreen.main.bounds
    
    init(size:CGSize) {
        super.init(texture: nil, color: UIColor.clear, size: CGSize(width: size.width, height: size.height))
        zPosition = 4
        anchorPoint = CGPoint(x: 0.5, y: 0)
        
        // Access the current screen height
        let screenWidth = self.screenSize.height
        
        if (screenWidth == 667) {
            TopMountainTexture = SKTexture(imageNamed: "TopMountainsIphone6")
        } else {
            TopMountainTexture = SKTexture(imageNamed: "TopMountainsFront")
        }
        
        var i: CGFloat = -1
        while i < 1 + self.frame.size.width / TopMountainTexture.size().width {
            i += 1
            
            let mountainSprite = SKSpriteNode(texture: TopMountainTexture)
            
            // Add to the correct position depending on device height (points)
            switch screenWidth {
            case 0...568:
                // Iphone 5
                mountainSprite.position = CGPoint(x: i * mountainSprite.size.width, y: 535)
            case 569...667:
                // Iphone 6
                mountainSprite.position = CGPoint(x: i * mountainSprite.size.width, y: 575)
            default:
                // Iphone 6 plus
                mountainSprite.position = CGPoint(x: i * mountainSprite.size.width, y: 617)
            }
            addChild(mountainSprite)
        }
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func begin() {
        // Moving the ground at speed
        let moveGroundSprite = SKAction.moveBy(x: -TopMountainTexture.size().width, y: 0, duration: TimeInterval(0.045 * TopMountainTexture.size().width))
        let resetGroundSprite = SKAction.moveBy(x: TopMountainTexture.size().width, y: 0, duration: 0.0)
        let moveSequence = SKAction.sequence([moveGroundSprite, resetGroundSprite])
        run(SKAction.repeatForever(moveSequence))
    } 
}
