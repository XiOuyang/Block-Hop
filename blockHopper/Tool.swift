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

    var tool : SKShapeNode!
    var type : ToolType!
    
    init(type: ToolType) {
        super.init()
        self.type = type
        self.userInteractionEnabled = true

        switch type {
        case .square:
            tool = SKShapeNode(rectOfSize: CGSize(width: 50, height: 50))
            tool.position = CGPoint(x: 50, y: 500)
            tool.fillColor = UIColor.cyanColor()
            addChild(tool)
            tool.physicsBody = SKPhysicsBody(rectangleOfSize: CGSize(width: 100, height: 100))
            break
        case .circle:
            tool = SKShapeNode(circleOfRadius: 30)
            tool.position = CGPoint(x: 50, y: 450)
            tool.fillColor = UIColor.greenColor()
            addChild(tool)
            
            tool.physicsBody = SKPhysicsBody(circleOfRadius: 60)
            break
        case .triangle:
            print("todo create triangle...")
        }
        
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
        
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {

    }
    
}
