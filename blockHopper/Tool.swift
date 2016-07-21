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
        case square, triangle, circle
    }
    //holds enum type
    var type : ToolType!
    
    var homePos : CGPoint!
    
    
    
    
    //init to inherit properties from gamescene
    init(type: ToolType, homePos: CGPoint!) {
        self.type = type
        self.homePos = homePos
        
        var texture: SKTexture!
        
        switch type {
        //generates square
        case .square:
            texture = SKTexture(imageNamed: "square")
            super.init(texture: texture, color: UIColor.blueColor(), size: CGSize(width: 80, height: 80))
            //self.path = CGPathCreateWithRect(CGRect(x: 0, y: 0, width: 80, height: 80), nil)
            //fillColor = UIColor.cyanColor()
            
            break
        //generates circle
        case .circle:
            texture = SKTexture(imageNamed: "circle")
            super.init(texture: texture, color: UIColor.cyanColor(), size: CGSize(width: 80, height: 80))
            
            //            self.path = CGPathCreateWithEllipseInRect(CGRect(x: 0, y: 0, width: 80, height: 80), nil)
            //            fillColor = UIColor.greenColor()
            break
        case .triangle:
            super.init(texture: texture, color: UIColor.cyanColor(), size: CGSize(width: 80, height: 80))
            print("todo create triangle...")
        }
        self.position = homePos
        colorBlendFactor = 0.5
        //shadowCastBitMask = 1
        
        //sets properties of tools
        zPosition = 2
        physicsBody = SKPhysicsBody(texture: texture, size: frame.size)
        physicsBody?.collisionBitMask = 1
        physicsBody?.affectedByGravity = false
        physicsBody?.allowsRotation = false
        
        name =  "tool"
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
