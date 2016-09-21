//
//  Player.swift
//  Lanit
//
//  Created by Teemu on 25.2.2016.
//  Copyright © 2016 Pasi Särkilahti & Teemu Salminen. All rights reserved.
//

import Foundation
import SpriteKit

class Player: SKSpriteNode {
    
    init(size: CGSize) {
        super.init(texture: PlayerTexture1, color: UIColor.clear, size: CGSize(width: size.width, height: size.height))
        zPosition = 7
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // Animation normal
    func startFlying() {
        let fledgeAtlas = SKTextureAtlas(named: "fledge")
        var fledgeFrames = [SKTexture]()

        for image in 1...6 {
            let fledgeTextureName = "Fledge\(image).png"
            fledgeFrames.append(fledgeAtlas.textureNamed(fledgeTextureName))
        }
        
        let animation = SKAction.animate(with: fledgeFrames, timePerFrame: 0.12, resize: false, restore: true)
        run(SKAction.repeatForever(animation))
    }
    
    func hasHitObstacle() {
        // Rotate player in a anticlockwise direction
        let rotate = SKAction.rotate(byAngle: CGFloat(M_PI), duration: 0.5)
        // Stop flying animation & start rotate animation
        self.removeAllActions()
        run(rotate, withKey: "rotate")
    }
    
    func resetSprite() {
        // Rotate player in a anticlockwise direction
        let rotate = SKAction.rotate(byAngle: CGFloat(-M_PI), duration: 0.0)
        // Stop flying animation & start rotate animation
        self.removeAllActions()
        run(rotate, withKey: "resetSprite")
    }
    
    func stop() {
        self.removeAllActions()
    }
}
