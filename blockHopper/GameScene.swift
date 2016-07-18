//
//  GameScene.swift
//  blockHopper
//
//  Created by Xi Stephen Ouyang on 7/13/16.
//  Copyright (c) 2016 Make School. All rights reserved.
//

import SpriteKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    var goLeft: Bool = false
    var goRight: Bool = false
    var jumpCt = 0
    
    var player: SKSpriteNode!
    var goal: SKSpriteNode!
    var ground: SKSpriteNode!
    var left: MSButtonNode!
    var right: MSButtonNode!
    var jump: MSButtonNode!
    var leftLabel: SKLabelNode!
    var rightLabel: SKLabelNode!
    var jumpLabel: SKLabelNode!
    
    var circle : Tool!
    var square : Tool!
    var box : SKShapeNode!
    
    
    override func didMoveToView(view: SKView) {
        /* Setup your scene here */
        view.showsPhysics = true
        
        player = self.childNodeWithName("player") as! SKSpriteNode
        goal = self.childNodeWithName("goal") as! SKSpriteNode
        ground = self.childNodeWithName("ground") as! SKSpriteNode
        left = self.childNodeWithName("left") as! MSButtonNode
        right = self.childNodeWithName("right") as! MSButtonNode
        jump = self.childNodeWithName("jump") as! MSButtonNode
        leftLabel = left.childNodeWithName("leftLabel") as! SKLabelNode
        rightLabel = right.childNodeWithName("rightLabel") as! SKLabelNode
        jumpLabel = jump.childNodeWithName("jumpLabel") as! SKLabelNode
        
        box = SKShapeNode(rect:
            CGRect(x: 0, y: 0, width: 100, height: frame.size.height - ground.size.height)
            , cornerRadius: 30)
        box.position = CGPoint(x: 0, y: ground.size.height)
        box.zPosition = 1
        box.fillColor = UIColor.whiteColor()
        box.physicsBody = SKPhysicsBody(edgeLoopFromRect: CGRect(x: 0, y: 0, width: 100, height: frame.size.height - ground.size.height))
        box.physicsBody?.collisionBitMask = 2
        addChild(box)
        
        circle = Tool(type: Tool.ToolType.circle)
        circle.position = CGPoint(x: 50, y: 100)
        circle.tool.physicsBody?.affectedByGravity = false
        box.addChild(circle)
        
        square = Tool(type: Tool.ToolType.square)
        square.position = CGPoint(x: 50, y: 200)
        square.tool.physicsBody?.affectedByGravity = false
        square.tool.physicsBody?.dynamic = false
        box.addChild(square)
        
        
        /* Set physics contact delegate */
        physicsWorld.contactDelegate = self
        
        left.selectionBegan = leftStarted
        right.selectionBegan = rightStarted
        jump.selectionBegan = jumpStarted
        
        left.selectionEnded = {
            self.goLeft = false
        }
        right.selectionEnded = {
            self.goRight = false
        }
        jump.selectionEnded = {}
        
    }
    
    
    func leftStarted() {
        print("left started")
        goLeft = true
        
    }
    func rightStarted() {
        print("right started")
        goRight = true
        
    }
    func jumpStarted() {
        if jumpCt < 1 {
            print("jump started")
            player.physicsBody?.applyImpulse(CGVectorMake(0, 500))
            jumpCt += 1
        }
        
    }
    
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        /* Called when a touch begins */
        
    }
    
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
        if goRight {
            player.physicsBody?.applyForce(CGVector(dx: 100, dy: 0))
        } else if goLeft {
            player.physicsBody?.applyForce(CGVector(dx: -100, dy: 0))
        }
        if player.physicsBody?.velocity.dy > 530 {
            player.physicsBody?.velocity.dy = 530
        }
        
        if player.physicsBody?.velocity.dx > 200 {
            player.physicsBody?.velocity.dx = 200
        } else if player.physicsBody?.velocity.dx < -200 {
            player.physicsBody?.velocity.dx = -200
        }
        
        
    }
    
    func didBeginContact(contact: SKPhysicsContact) {
        
        /* Get references to bodies involved in collision */
        let contactA:SKPhysicsBody = contact.bodyA
        let contactB:SKPhysicsBody = contact.bodyB
        
        /* Get references to the physics body parent nodes */
        let nodeA = contactA.node!
        let nodeB = contactB.node!
        
        //        print(nodeA.name!)
        //        print(nodeB.name!)
        
        if nodeA.name == "player" && nodeB.name == "goal" || nodeA.name == "goal" && nodeB.name == "player" {
            print("hit goal")
            jumpCt = 2
        } else {
            jumpCt = 0

        }
        if nodeA.name == "player" && nodeB.name == "circle" || nodeA.name == "circle" && nodeB.name == "player" {
            circle.tool.physicsBody?.affectedByGravity = true
        } else {
            print("nil")
        }
            }
    
}
