//
//  BottomPlatform.swift
//  Lanit
//
//  Created by Teemu on 9.4.2016.
//  Copyright © 2016 Pasi Särkilahti & Teemu Salminen. All rights reserved.
//

import Foundation
import SpriteKit

class BottomPlatform : SKSpriteNode {
    
    let BottomPlatformTexture = SKTexture(imageNamed: "BottomPlatform")
    
    // Screen size detection
    let screenSize: CGRect = UIScreen.mainScreen().bounds
    
    init(size:CGSize) {
        super.init(texture: nil, color: UIColor.clearColor(), size: CGSizeMake(size.width, size.height))
        position = CGPointMake(0.0, 0.0)
        zPosition = 6
        physicsBody?.affectedByGravity = false
        
        var i: CGFloat = -1
        while i < 2 + self.frame.size.width / BottomPlatformTexture.size().width {
            i += 1
            let bottomPlatformSprite = SKSpriteNode(texture: BottomPlatformTexture)
            
            // Access the current screen width
            let screenWidth = self.screenSize.height
            
            // Add to the correct position depending on device height (points)
            switch screenWidth {
            case 0...480:
                // Iphone 4
                bottomPlatformSprite.position = CGPointMake(i * bottomPlatformSprite.size.width, bottomPlatformSprite.size.height / 2)
            case 481...568:
                // Iphone 5
                bottomPlatformSprite.position = CGPointMake(i * bottomPlatformSprite.size.width, 80)
            case 569...667:
                // Iphone 6
                bottomPlatformSprite.position = CGPointMake(i * bottomPlatformSprite.size.width, 110)
            default:
                // Iphone 6 plus
                bottomPlatformSprite.position = CGPointMake(i * bottomPlatformSprite.size.width, 150)
            }
            addChild(bottomPlatformSprite)
        }
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func begin() {
        // Moving the ground at speed
        let moveGroundSprite = SKAction.moveByX(-BottomPlatformTexture.size().width, y: 0, duration: NSTimeInterval(0.00624 * BottomPlatformTexture.size().width))
        let resetGroundSprite = SKAction.moveByX(BottomPlatformTexture.size().width, y: 0, duration: 0.0)
        let moveSequence = SKAction.sequence([moveGroundSprite, resetGroundSprite])
        runAction(SKAction.repeatActionForever(moveSequence))
    }
    
    func stop() {
        removeAllActions()
    }
    
}