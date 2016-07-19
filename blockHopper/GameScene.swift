//
//  GameScene.swift
//  blockHopper
//
//  Created by Xi Stephen Ouyang on 7/13/16.
//  Copyright (c) 2016 Make School. All rights reserved.
//

import SpriteKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    //enum to keep track of game state
    enum GameState {
        case Setup, Play
    }
    
    //holds game state enum type
    var currState: GameState = .Setup
    
    //keeps track of if you will move or not
    var goLeft: Bool = false
    var goRight: Bool = false
    
    //keeps track of jump counter
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
    var background : SKSpriteNode!
    
    //initialize objects in game scene
    var circle : Tool!
    var square : Tool!
    var box : SKShapeNode!
    var dragObject: Tool?
    
    override func didMoveToView(view: SKView) {
        /* Setup your scene here */
        view.showsPhysics = true
        
        //sets up connections with scene props
        player = self.childNodeWithName("player") as! SKSpriteNode
        goal = self.childNodeWithName("goal") as! SKSpriteNode
        ground = self.childNodeWithName("ground") as! SKSpriteNode
        left = self.childNodeWithName("left") as! MSButtonNode
        right = self.childNodeWithName("right") as! MSButtonNode
        jump = self.childNodeWithName("jump") as! MSButtonNode
        leftLabel = left.childNodeWithName("leftLabel") as! SKLabelNode
        rightLabel = right.childNodeWithName("rightLabel") as! SKLabelNode
        jumpLabel = jump.childNodeWithName("jumpLabel") as! SKLabelNode
        background = self.childNodeWithName("background") as! SKSpriteNode
        
        //generates space for the objects
        box = SKShapeNode(rect:
            CGRect(x: 0, y: 0, width: 100, height: frame.size.height - ground.size.height)
            , cornerRadius: 30)
        box.position = CGPoint(x: 0, y: ground.size.height)
        box.zPosition = 1
        box.fillColor = UIColor.whiteColor()
        box.physicsBody = SKPhysicsBody(edgeLoopFromRect: CGRect(x: 0, y: 0, width: 100, height: frame.size.height - ground.size.height))
        box.physicsBody?.collisionBitMask = 2
        addChild(box)
        
        //generate circle object
        circle = Tool(type: Tool.ToolType.circle)
        circle.position = CGPoint(x: 30, y: 400)
        self.addChild(circle)
        
        //generate square object
        square = Tool(type: Tool.ToolType.square)
        square.position = CGPoint(x: 30, y: 500)
        self.addChild(square)
        
        
        /* Set physics contact delegate */
        physicsWorld.contactDelegate = self
        
        //if buttons are clicked, call movement functions
        left.selectionBegan = leftStarted
        right.selectionBegan = rightStarted
        jump.selectionBegan = jumpStarted
        
        //when not clicking, the functions end
        left.selectionEnded = {
            self.goLeft = false
        }
        right.selectionEnded = {
            self.goRight = false
        }
        jump.selectionEnded = {}
        
    }
    
    //move functions
    func leftStarted() {
        print("left started")
        goLeft = true
        
    }
    func rightStarted() {
        print("right started")
        goRight = true
        
    }
    func jumpStarted() {
        //limits jumps to only 1
        if jumpCt < 1 {
            print("jump started")
            player.physicsBody?.applyImpulse(CGVectorMake(0, 500))
            jumpCt += 1
        }
        
    }
    
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        /* Called when a touch begins */
        print("gamescene touches began")
        
        //for all your touches on screen
        for touch in touches {
            
            //location is where you touched
            let location = touch.locationInNode(self)
            
            //touched node is whatever node you touched
            let touchedNode = nodeAtPoint(location)
            
            //if node touched is a 'tool'
            if let tool = touchedNode as? Tool {
                
                //state set to setup
                currState = .Setup
                //object you are dragging is the tool
                dragObject = tool
            }
        }
    }
    
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        
        for touch in touches {
            let location = touch.locationInNode(self)
            if let tool = dragObject {
                tool.position = location
            }
            
        }
        
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        
        if let tool = dragObject {

            var touchedNode = nodesAtPoint(tool.position)
            if touchedNode[1].name == "background" {
                dragObject = nil
                print("on background")
                if currState == .Setup {
                    currState = .Play
                }
            } else {
                if dragObject?.type == Tool.ToolType.circle {
                dragObject?.position = CGPoint(x: 30, y: 400)
                dragObject = nil
                } else if dragObject?.type == Tool.ToolType.square {
                    dragObject?.position = CGPoint(x: 30, y: 500)
                    dragObject = nil
                }
                
            }
            
//            if touchedNode.name == "background" {
//                print("on background")
//            }
        }
//        if dragObject?.position.y >= ground.position.y {
//            dragObject = nil
//            if currState == .Setup {
//                currState = .Play
//            }
//        } else {
//            dragObject?.position = CGPoint(x: 30, y: 400)
//            dragObject = nil
//            if currState == .Setup {
//                currState = .Play
//            }
//        }
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
        
        if currState == .Setup {
            self.player.position = CGPoint(x: 150, y: 226)
            self.player.physicsBody?.dynamic = false
        } else {
            self.player.physicsBody?.dynamic = true
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
        
    }
    
}
