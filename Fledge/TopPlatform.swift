//
//  TopPlatform.swift
//  Lanit
//
//  Created by Teemu on 10.4.2016.
//  Copyright © 2016 Pasi Särkilahti & Teemu Salminen. All rights reserved.
//

import Foundation
import SpriteKit

class TopPlatform : SKSpriteNode {
    
    let TopPlatformTexture = SKTexture(imageNamed: "TopPlatform")
    
    // Screen size detection
    let screenSize: CGRect = UIScreen.mainScreen().bounds
    
    init(size:CGSize) {
        super.init(texture: nil, color: UIColor.clearColor(), size: CGSizeMake(size.width, size.height))
        position = CGPointMake(0.0, 0.0)
        zPosition = 6
        physicsBody?.affectedByGravity = false
        
        var i: CGFloat = -1
        while i < 2 + self.frame.size.width / TopPlatformTexture.size().width {
            i += 1
            let topPlatformSprite = SKSpriteNode(texture: TopPlatformTexture)
            
            // Access the current screen width
            let screenWidth = self.screenSize.height
            
            // Add to the correct position depending on device height (points)
            switch screenWidth {
            case 0...480:
                // Iphone 4
                topPlatformSprite.position = CGPointMake(i * topPlatformSprite.size.width, 358)
            case 481...568:
                // Iphone 5
                topPlatformSprite.position = CGPointMake(i * topPlatformSprite.size.width, 438)
            case 569...667:
                // Iphone 6
                topPlatformSprite.position = CGPointMake(i * topPlatformSprite.size.width, 468)
            default:
                // Iphone 6 plus
                topPlatformSprite.position = CGPointMake(i * topPlatformSprite.size.width, 508)
            }
            addChild(topPlatformSprite)
        }
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func begin() {
        // Moving the ground at speed
        let moveGroundSprite = SKAction.moveByX(-TopPlatformTexture.size().width, y: 0, duration: NSTimeInterval(0.00624 * TopPlatformTexture.size().width))
        let resetGroundSprite = SKAction.moveByX(TopPlatformTexture.size().width, y: 0, duration: 0.0)
        let moveSequence = SKAction.sequence([moveGroundSprite, resetGroundSprite])
        runAction(SKAction.repeatActionForever(moveSequence))
    }
    
    func stop() {
        self.removeAllActions()
        self.removeFromParent()
    }
    
}
