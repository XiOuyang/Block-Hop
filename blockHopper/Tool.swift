//
//  Tool.swift
//  blockHopper
//
//  Created by Xi Stephen Ouyang on 7/15/16.
//  Copyright © 2016 Make School. All rights reserved.
//

import Foundation
import SpriteKit


class Tool: SKSpriteNode {
    
    // types of tools
    enum ToolType {
        case platform1, platform2, platform3
    }
    //holds enum type
    var type : ToolType!
    var homePos : CGPoint!
    var currentLevel = 0
    
    //init to inherit properties from gamescene
    init(type: ToolType, homePos: CGPoint!) {
        self.type = type
        self.homePos = homePos
        
        var texture: SKTexture!
        
        switch type {
        //generates square
        case .platform2:
            texture = SKTexture(imageNamed: "grassGround")
            super.init(texture: texture, color: UIColor.yellowColor(), size: CGSize(width: 70, height: 50))
            break
        //generates circle
        case .platform1:
            texture = SKTexture(imageNamed: "cloud3")
            super.init(texture: texture, color: UIColor.whiteColor(), size: CGSize(width: 70, height: 70))
            break
            
        case .platform3:
            texture = SKTexture(imageNamed: "castleGround")
            super.init(texture: texture, color: UIColor.grayColor(), size: CGSize(width: 70, height: 50))
        }
        
        self.position = homePos
        colorBlendFactor = 0.5
        
        //sets properties of tools
        zPosition = 2
        physicsBody = SKPhysicsBody(texture: texture, size: frame.size)
        physicsBody?.categoryBitMask = 1
        physicsBody?.affectedByGravity = false
        physicsBody?.allowsRotation = false
        name =  "tool"
    }
    
//    func fireflyEffect(light: SKLightNode) {
//        let particle = SKEmitterNode(fileNamed: "FireFly")!
//        particle.position = CGPoint(x: 0, y: 0)
//        particle.zPosition = 11
//        particle.numParticlesToEmit = 55
//        
//        addChild(particle)
//        
//        let xPos = light.position.x - position.x
//        let yPos = light.position.y - position.y
//        let desiredAng = atan2(yPos, xPos)
//        particle.emissionAngle = desiredAng
//        
//        let delay = SKAction.waitForDuration(2)
//        let delete = SKAction.runBlock {
//            particle.removeFromParent()
//        }
//        
//        runAction(SKAction.sequence([delay, delete]))
//    }
    
    func bounce(player: SKSpriteNode, circle: Tool) {
        let toolMid = circle.position.x
        let playerBottom = player.position.y - (player.frame.size.height/2)
        let toolTop = (circle.position.y + circle.frame.size.height/2 - 2)
        
        let scaleDown = SKAction.scaleTo(0.8, duration: 0.1)
        scaleDown.timingMode = SKActionTimingMode.EaseInEaseOut
        let scaleUp = SKAction.scaleTo(1, duration: 0.1)
        scaleUp.timingMode = SKActionTimingMode.EaseInEaseOut
        runAction(SKAction.sequence([scaleDown, scaleUp]))
        
        if playerBottom > toolTop {
            player.physicsBody?.applyImpulse(CGVectorMake(0, 100))
        } else {
            if player.position.x > toolMid {
                player.physicsBody?.applyImpulse(CGVectorMake(100, 0))
            } else if player.position.x < toolMid {
                player.physicsBody?.applyImpulse(CGVectorMake(-100, 0))
            } else if player.position.x == toolMid {
                player.physicsBody?.applyImpulse(CGVectorMake(0, -100))
            }
        }
    }
    
        
    func toolAnimationStart() {
        runAction(SKAction.scaleTo(1.5, duration: 0.4))
    }
    func toolAnimationEnd() {
        runAction(SKAction.scaleTo(1, duration: 0.4))
    }
    
    func addLevel() {
        currentLevel += 1
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func shadow() {
        shadowCastBitMask = 1
    }
    
    func light() {
        shadowCastBitMask = 0
    }
    
    
}
