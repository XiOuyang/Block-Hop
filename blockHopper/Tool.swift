//
//  Tool.swift
//  blockHopper
//
//  Created by Xi Stephen Ouyang on 7/15/16.
//  Copyright © 2016 Make School. All rights reserved.
//

import Foundation
import SpriteKit


class Tool: SKNode {
    
    enum ToolType {
        case square, triangle, circle
    }
    
    var tool : SKShapeNode!
    var type : ToolType!
    
    init(type: ToolType) {
        super.init()
        self.type = type
        self.userInteractionEnabled = true
        
        switch type {
        case .square:
            tool = SKShapeNode(rectOfSize: CGSize(width: 50, height: 50))
            tool.position = CGPoint(x: 0, y: 0)
            tool.fillColor = UIColor.cyanColor()
            tool.name = "square"
            addChild(tool)
            tool.physicsBody = SKPhysicsBody(rectangleOfSize: tool.frame.size)
            tool.physicsBody?.collisionBitMask = 1
            break
        case .circle:
            let radius : CGFloat = 30
            tool = SKShapeNode(circleOfRadius: radius)
            tool.position = CGPoint(x: 0, y: 0)
            tool.fillColor = UIColor.greenColor()
            tool.name = "circle"
            tool.physicsBody?.contactTestBitMask = 1
            tool.physicsBody?.collisionBitMask = 1
            addChild(tool)
            
            tool.physicsBody = SKPhysicsBody(circleOfRadius: radius)
            break
        case .triangle:
            print("todo create triangle...")
        }
        zPosition = 2
        tool.physicsBody?.affectedByGravity = false
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // MARK: - Touch handling
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        print("touched \(type)")
    }
    
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        
        for touch in touches{
            self.tool.position = touch.locationInNode(self)
        }
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        
    }
}
