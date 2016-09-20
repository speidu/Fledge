//
//  TunnelForeground.swift
//  Fledge
//
//  Created by Teemu on 18.9.2016.
//  Copyright © 2016 pasi. All rights reserved.
//

import Foundation
import SpriteKit

class TunnelForeground : SKSpriteNode {
    
    var TunnelForegroundTexture = SKTexture()
    
    // Screen size detection
    let screenSize: CGRect = UIScreen.main.bounds
    
    init(size:CGSize) {
        super.init(texture: nil, color: UIColor.clear, size: CGSize(width: size.width, height: size.height))
        zPosition = 1
        anchorPoint = CGPoint(x: 0.5, y: 0)
        
        // Access the current screen height
        let screenWidth = self.screenSize.height
        
        if (screenWidth == 667) {
            TunnelForegroundTexture = SKTexture(imageNamed: "TunnelForeground")
        } else {
            TunnelForegroundTexture = SKTexture(imageNamed: "TunnelForeground")
        }
        
        var i: CGFloat = -1
        while i < 1 + self.frame.size.width / TunnelForegroundTexture.size().width {
            i += 1
            
            let tunnelForegroundSprite = SKSpriteNode(texture: TunnelForegroundTexture)
            
            // Add to the correct position depending on device height (points)
            switch screenWidth {
            case 0...568:
                // Iphone 5
                tunnelForegroundSprite.position = CGPoint(x: i * tunnelForegroundSprite.size.width, y: 260)
            case 569...667:
                // Iphone 6
                tunnelForegroundSprite.position = CGPoint(x: i * tunnelForegroundSprite.size.width, y: 285)
            default:
                // Iphone 6 plus
                tunnelForegroundSprite.position = CGPoint(x: i * tunnelForegroundSprite.size.width, y: 325)
            }
            addChild(tunnelForegroundSprite)
        }
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func begin() {
        // Moving the ground at speed
        let moveGroundSprite = SKAction.moveBy(x: -TunnelForegroundTexture.size().width, y: 0, duration: TimeInterval(0.01 * TunnelForegroundTexture.size().width)) // TimeInterval 0.045
        let resetGroundSprite = SKAction.moveBy(x: TunnelForegroundTexture.size().width, y: 0, duration: 0.0)
        let moveSequence = SKAction.sequence([moveGroundSprite, resetGroundSprite])
        run(SKAction.repeatForever(moveSequence))
    }
}
