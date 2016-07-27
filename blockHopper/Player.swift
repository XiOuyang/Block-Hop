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
    
    //keeps track of if you will move or not
    var goLeft: Bool = false
    var goRight: Bool = false
    
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
    
    func moveLeft() -> Bool {
        print("left started")
        lightingBitMask = 2
        goLeft = true
        texture = SKTexture(imageNamed: "leftRect")
        
        
        return goLeft
    }
    
    func moveRight() -> Bool {
        print("right started")
        lightingBitMask = 2
        goRight = true
        texture = SKTexture(imageNamed: "rightRect")
        
        return goRight
    }
    
    func jumpAnimation() {
        let scaleDown = SKAction.scaleTo(0.8, duration: 0.5)
        scaleDown.timingMode = SKActionTimingMode.EaseInEaseOut
        let scaleUp = SKAction.scaleTo(1.2, duration: 0.5)
        scaleUp.timingMode = SKActionTimingMode.EaseInEaseOut
        runAction(SKAction.sequence([scaleDown, scaleUp]))
    }
    
    func lightUp() {
        let light = SKLightNode()
        light.categoryBitMask = 2
        light.zPosition = -10
        light.ambientColor = UIColor.blackColor()
        light.falloff = 1
        light.position = CGPoint(x: 0, y: 0)
        light.lightColor = UIColor.whiteColor()
        addChild(light)
    }

    
    
}
