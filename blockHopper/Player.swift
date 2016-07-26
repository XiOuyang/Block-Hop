//
//  Player.swift
//  blockHopper
//
//  Created by Xi Stephen Ouyang on 7/26/16.
//  Copyright © 2016 Make School. All rights reserved.
//

import Foundation
import SpriteKit

class Player: SKSpriteNode {
    
    var jumpCount = 0
    
    func jump() {
        if jumpCount < 1 {
            jumpAnimation()
            print("jump started")
            lightingBitMask = 2
            physicsBody?.applyImpulse(CGVectorMake(0, 600))
            jumpCount += 1
        }
    }
    
    func jumpAnimation() {
        let scaleDown = SKAction.scaleTo(0.8, duration: 0.5)
        scaleDown.timingMode = SKActionTimingMode.EaseInEaseOut
        let scaleUp = SKAction.scaleTo(1.2, duration: 0.5)
        scaleUp.timingMode = SKActionTimingMode.EaseInEaseOut
        runAction(SKAction.sequence([scaleDown, scaleUp]))
    }
}
