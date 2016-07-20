//
//  Tool.swift
//  blockHopper
//
//  Created by Xi Stephen Ouyang on 7/15/16.
//  Copyright © 2016 Make School. All rights reserved.
//

import Foundation
import SpriteKit


class Tool: SKShapeNode {
    
    // types of tools
    enum ToolType {
        case square, triangle, circle
    }
    //holds enum type
    var type : ToolType!
    var homePos : CGPoint!
    
    //init to inherit properties from gamescene
    init(type: ToolType, homePos: CGPoint!) {
        super.init()
        self.type = type
        self.homePos = homePos
        position = homePos
        
        switch type {
        //generates square
        case .square:
            self.path = CGPathCreateWithRect(CGRect(x: 0, y: 0, width: 80, height: 80), nil)
            fillColor = UIColor.cyanColor()
            break
        //generates circle
        case .circle:
            self.path = CGPathCreateWithEllipseInRect(CGRect(x: 0, y: 0, width: 80, height: 80), nil)
            fillColor = UIColor.greenColor()
            
            break
        case .triangle:
            print("todo create triangle...")
        }
        //sets properties of tools
        zPosition = 2
        physicsBody = SKPhysicsBody(edgeChainFromPath: path!)
        physicsBody?.collisionBitMask = 1
        physicsBody?.affectedByGravity = false
        name =  "tool"
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
}
