//
//  File.swift
//  Fledge
//
//  Created by Teemu on 18.9.2016.
//  Copyright © 2016 pasi. All rights reserved.
//

import Foundation
import SpriteKit

class TunnelMidground : SKSpriteNode {
    
    var TunnelMidgroundTexture = SKTexture()
    
    // Screen size detection
    let screenSize: CGRect = UIScreen.main.bounds
    
    init(size:CGSize) {
        super.init(texture: nil, color: UIColor.clear, size: CGSize(width: size.width, height: size.height))
        zPosition = 0
        anchorPoint = CGPoint(x: 0.5, y: 0)
        
        // Access the current screen height
        let screenWidth = self.screenSize.height
        
        if (screenWidth == 667) {
            TunnelMidgroundTexture = SKTexture(imageNamed: "TopMountainsIphone6")
        } else {
            TunnelMidgroundTexture = SKTexture(imageNamed: "TunnelMidground")
        }
        
        var i: CGFloat = -1
        while i < 1 + self.frame.size.width / TunnelMidgroundTexture.size().width {
            i += 1
            
            let tunnelMidgroundSprite = SKSpriteNode(texture: TunnelMidgroundTexture)
            
            // Add to the correct position depending on device height (points)
            switch screenWidth {
            case 0...568:
                // Iphone 5
                tunnelMidgroundSprite.position = CGPoint(x: i * tunnelMidgroundSprite.size.width, y: 260)
            case 569...667:
                // Iphone 6
                tunnelMidgroundSprite.position = CGPoint(x: i * tunnelMidgroundSprite.size.width, y: 260)
            default:
                // Iphone 6 plus
                tunnelMidgroundSprite.position = CGPoint(x: i * tunnelMidgroundSprite.size.width, y: 617)
            }
            addChild(tunnelMidgroundSprite)
        }
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func begin() {
        // Moving the ground at speed
        let moveGroundSprite = SKAction.moveBy(x: -TunnelMidgroundTexture.size().width, y: 0, duration: TimeInterval(0.045 * TunnelMidgroundTexture.size().width)) // TimeInterval 0.045
        let resetGroundSprite = SKAction.moveBy(x: TunnelMidgroundTexture.size().width, y: 0, duration: 0.0)
        let moveSequence = SKAction.sequence([moveGroundSprite, resetGroundSprite])
        run(SKAction.repeatForever(moveSequence))
    }
    
    func stop() {
        self.removeAllActions()
        self.removeFromParent()
    }
    
}
