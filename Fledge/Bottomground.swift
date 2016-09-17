//
//  Bottomground.swift
//  Lanit
//
//  Created by pasi on 1.8.2016.
//  Copyright © 2016 Pasi Särkilahti. All rights reserved.
//

import Foundation
import SpriteKit

class Bottomground : SKSpriteNode {
    
    let bottomGroundTexture = SKTexture(imageNamed: "BottomGround")
    
    // Screen size detection
    let screenSize: CGRect = UIScreen.main.bounds
    
    init(size:CGSize) {
        super.init(texture: nil, color: UIColor.clear, size: CGSize(width: size.width, height: size.height))
        zPosition = 3
        anchorPoint = CGPoint(x: 0.5, y: 1)
        
        var i: CGFloat = -1
        while i < 1 + self.frame.size.width / bottomGroundTexture.size().width {
            i += 1
            let bottomGroundSprite = SKSpriteNode(texture: bottomGroundTexture)
            
            // Access the current screen width
            let screenWidth = self.screenSize.height
            
            // Add to the correct position depending on device height (points)
            switch screenWidth {
            case 0...568:
                // Iphone 5
                bottomGroundSprite.position = CGPoint(x: i * bottomGroundSprite.size.width, y: -40)
            case 569...667:
                // Iphone 6
                bottomGroundSprite.position = CGPoint(x: i * bottomGroundSprite.size.width, y: -10)
            default:
                // Iphone 6 plus
                bottomGroundSprite.position = CGPoint(x: i * bottomGroundSprite.size.width, y: 30)
            }
            addChild(bottomGroundSprite)
        }
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func begin() {
        // Moving the ground at speed
        let moveGroundSprite = SKAction.moveBy(x: -bottomGroundTexture.size().width, y: 0, duration: TimeInterval(0.00624 * bottomGroundTexture.size().width))
        let resetGroundSprite = SKAction.moveBy(x: bottomGroundTexture.size().width, y: 0, duration: 0.0)
        let moveSequence = SKAction.sequence([moveGroundSprite, resetGroundSprite])
        run(SKAction.repeatForever(moveSequence))
    }
    
    func stop() {
        self.removeAllActions()
        self.removeFromParent()
    }
    
}
