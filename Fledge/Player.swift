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
    
    let PlayerTexture1 = SKTexture(imageNamed: "Player")
    let PlayerTexture2 = SKTexture(imageNamed: "Player2")
    let playerUp = SKTexture(imageNamed: "PlayerUp")
    let playerUp2 = SKTexture(imageNamed: "PlayerUp2")
    let playerDown = SKTexture(imageNamed: "PlayerDown")
    let playerDown2 = SKTexture(imageNamed: "PlayerDown2")
    
    init(size: CGSize) {
        super.init(texture: PlayerTexture1, color: UIColor.clearColor(), size: CGSizeMake(size.width, size.height))
        zPosition = 7
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // Animation normal
    func startFlying() {
        self.removeAllActions()
        let animation = SKAction.animateWithTextures([PlayerTexture1, PlayerTexture2], timePerFrame: 0.2)
        runAction(SKAction.repeatActionForever(animation))
    }
    
    func startFlyingUp() {
        self.removeAllActions()
        let upAnimation = SKAction.animateWithTextures([playerUp, playerUp2], timePerFrame: 0.2)
        runAction(SKAction.repeatActionForever(upAnimation))
    }
    
    func startFlyingDown() {
        self.removeAllActions()
        let downAnimation = SKAction.animateWithTextures([playerDown, playerDown2], timePerFrame: 0.2)
        runAction(SKAction.repeatActionForever(downAnimation))
    }
    
    func hasHitObstacle() {
        // Rotate player in a anticlockwise direction
        let rotate = SKAction.rotateByAngle(CGFloat(M_PI), duration: 0.5)
        // Stop flying animation & start rotate animation
        self.removeAllActions()
        runAction(rotate, withKey: "rotate")
    }
    
    func stop() {
        self.removeAllActions()
        self.removeFromParent()
    }
}
