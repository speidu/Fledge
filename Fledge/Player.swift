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
        super.init(texture: PlayerTexture1, color: UIColor.clear, size: CGSize(width: size.width, height: size.height))
        zPosition = 7
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // Animation normal
    func startFlying() {
        self.removeAllActions()
        let animation = SKAction.animate(with: [PlayerTexture1, PlayerTexture2], timePerFrame: 0.2)
        run(SKAction.repeatForever(animation))
    }
    
    func startFlyingUp() {
        self.removeAllActions()
        let upAnimation = SKAction.animate(with: [playerUp, playerUp2], timePerFrame: 0.2)
        run(SKAction.repeatForever(upAnimation))
    }
    
    func startFlyingDown() {
        self.removeAllActions()
        let downAnimation = SKAction.animate(with: [playerDown, playerDown2], timePerFrame: 0.2)
        run(SKAction.repeatForever(downAnimation))
    }
    
    func hasHitObstacle() {
        // Rotate player in a anticlockwise direction
        let rotate = SKAction.rotate(byAngle: CGFloat(M_PI), duration: 0.5)
        // Stop flying animation & start rotate animation
        self.removeAllActions()
        run(rotate, withKey: "rotate")
    }
    
    func stop() {
        self.removeAllActions()
        self.removeFromParent()
    }
}
