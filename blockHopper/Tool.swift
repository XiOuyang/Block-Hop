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
    
    enum ToolType {
        case square, triangle, circle
    }
    
    var type : ToolType!
    var isPlay : Bool = false
    
    init(type: ToolType) {
        super.init()
        self.type = type
        
        switch type {
        case .square:
            self.path = CGPathCreateWithRect(CGRect(x: 0, y: 0, width: 50, height: 50), nil)
            fillColor = UIColor.cyanColor()
            break
        case .circle:
            self.path = CGPathCreateWithEllipseInRect(CGRect(x: 0, y: 0, width: 50, height: 50), nil)
            fillColor = UIColor.greenColor()
            
            break
        case .triangle:
            print("todo create triangle...")
        }
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
