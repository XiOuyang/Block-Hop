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
    var currState: GameState = .Setup{
        didSet {
            switch currState {
            case .Setup:
                
                //return player to start position
                self.player.position = CGPoint(x: 200, y: 240)
                //can't move player
                self.player.physicsBody?.dynamic = false
                break
            case .Play:
                self.player.physicsBody?.dynamic = true
                
                break
            }
        }
    }
    
    //keeps track of if you will move or not
    var goLeft: Bool = false
    var goRight: Bool = false
    
    //keeps track of jump counter
    var jumpCt = 0
    
    //scene props
    var player: SKSpriteNode!
    var goal: SKSpriteNode!
    var ground: SKSpriteNode!
    var left: MSButtonNode!
    var right: MSButtonNode!
    var jump: MSButtonNode!
    var leftLabel: SKLabelNode!
    var rightLabel: SKLabelNode!
    var jumpLabel: SKLabelNode!
    var uiLayer: SKNode!
    var light: SKLightNode!
    var lightOn : Bool = false
    
    //initialize objects in game scene
    var circle : Tool!
    var square : Tool!
    var box : SKShapeNode!
    var dragObject: Tool?
    
    override func didMoveToView(view: SKView) {
        /* Setup your scene here */
        view.showsPhysics = true
        
        //sets up connections with scene props
        uiLayer = self.childNodeWithName("hudLayer")!
        player = self.childNodeWithName("player") as! SKSpriteNode
        goal = self.childNodeWithName("goal") as! SKSpriteNode
        ground = self.childNodeWithName("ground") as! SKSpriteNode
        left = uiLayer.childNodeWithName("left") as! MSButtonNode
        right = uiLayer.childNodeWithName("right") as! MSButtonNode
        jump = uiLayer.childNodeWithName("jump") as! MSButtonNode
        leftLabel = left.childNodeWithName("leftLabel") as! SKLabelNode
        rightLabel = right.childNodeWithName("rightLabel") as! SKLabelNode
        jumpLabel = jump.childNodeWithName("jumpLabel") as! SKLabelNode
        light = self.childNodeWithName("light") as! SKLightNode
        
        //sets up boundary so you can't go off-screen
        self.physicsBody = SKPhysicsBody(edgeLoopFromRect: CGRect(x: 0, y: 0, width: self.frame.size.width,
            height: self.frame.size.height))
        self.physicsBody?.affectedByGravity = false
        self.physicsBody?.dynamic = false
        
        lightUp()
        
        
        //generates space for the objects
        box = SKShapeNode(rect:
            CGRect(x: 0, y: 0, width: 120, height: frame.size.height - ground.size.height)
            , cornerRadius: 30)
        box.position = CGPoint(x: 0, y: ground.size.height)
        box.zPosition = 1
        box.fillColor = UIColor.whiteColor()
        box.physicsBody = SKPhysicsBody(edgeLoopFromRect: CGRect(x: 0, y: 0, width: 120, height: frame.size.height - ground.size.height))
        box.physicsBody?.collisionBitMask = 2
        addChild(box)
        
        //generate circle object
        circle = Tool(type: Tool.ToolType.circle, homePos: CGPoint(x: 20, y: 400))
        self.addChild(circle)
        
        //generate square object
        square = Tool(type: Tool.ToolType.square, homePos: CGPoint(x: 20, y: 500))
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
            self.player.lightingBitMask = 0
        }
        right.selectionEnded = {
            self.goRight = false
            self.player.lightingBitMask = 0
        }
        jump.selectionEnded = {self.player.lightingBitMask = 0}
    }
    
    //move functions
    func leftStarted() {
        print("left started")
        //particleEff()
        self.player.lightingBitMask = 2
        goLeft = true
        
    }
    func rightStarted() {
        print("right started")
        //particleEff()
        self.player.lightingBitMask = 2
        goRight = true
        
    }
    func jumpStarted() {
        //limits jumps to only 1
        if jumpCt < 1 {
            print("jump started")
            //particleEff()
            self.player.lightingBitMask = 2
            player.physicsBody?.applyImpulse(CGVectorMake(0, 600))
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
                tool.physicsBody?.collisionBitMask = 0
            }
        }
    }
    
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        
        for touch in touches {
            let location = touch.locationInNode(self)
            //if you touched a tool
            if let tool = dragObject {
                //tool moves to where you drag
                tool.position = location
            }
        }
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        //if you're dragging the tool
        if let tool = dragObject {
            
            //looping through all children of the scene
            for node in self.children {
                if node == tool {
                    continue
                }
                // sets up intersection check
                let intersect : Bool = tool.intersectsNode(node)
                
                //if tool intersects another tool
                if  intersect {
                    tool.position = tool.homePos
                    tool.physicsBody?.collisionBitMask = 1
                    break
                }
            }
        }
        //change game state
        if currState == .Setup {
            currState = .Play
        }
        dragObject = nil
    }
    
    
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
        
        //if buttons clicked, apply force corresponding to desired direction
        if goRight {
            player.physicsBody?.applyForce(CGVector(dx: 130, dy: 0))
        } else if goLeft {
            player.physicsBody?.applyForce(CGVector(dx: -130, dy: 0))
        }
        
        // caps jumping height
        if player.physicsBody?.velocity.dy > 530 {
            player.physicsBody?.velocity.dy = 530
        }
        
        //caps speed
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
        
        //if player is touching goal, cannot jump
        if nodeA.name == "player" && nodeB.name == "goal" || nodeA.name == "goal" && nodeB.name == "player" {
            print("hit goal")
            jumpCt = 2
        } else {
            jumpCt = 0
        }
        //check collision
        if nodeA.name == "player" && nodeB.name == "tool" || nodeA.name == "tool" && nodeB.name == "player" {
           
            //is it node A?
            if let tool = nodeA as? Tool {
                // let c = UIColor(red: 222/255, green: 187/255, blue: 12/255, alpha: 1)
                
                 particleEff(tool.position, tool: tool, light: light)
                light.shadowColor = UIColor(white: 0, alpha: 0.6)
                tool.shadow()
                //    //is it node B?
            } else if let tool = nodeB as? Tool {
                particleEff(tool.position, tool: tool, light: light)
                light.shadowColor = UIColor(white: 0, alpha: 0.6)
                
                tool.shadow()
            }
        }
    }
    
    func didEndContact(contact: SKPhysicsContact) {
        
        let contactA:SKPhysicsBody = contact.bodyA
        let contactB:SKPhysicsBody = contact.bodyB
        
        /* Get references to the physics body parent nodes */
        let nodeA = contactA.node!
        let nodeB = contactB.node!
        
        if nodeA.name == "player" && nodeB.name == "tool" || nodeA.name == "tool" && nodeB.name == "player" {
            //is it node A?
            if let tool = nodeA as? Tool {
                
                tool.light()
                //    //is it node B?
            } else if let tool = nodeB as? Tool {
                tool.light()
            }
        }
    }
    
    func particleEff(position: CGPoint, tool: SKSpriteNode, light: SKLightNode) {
        let particle = SKEmitterNode(fileNamed: "FireFly")
        particle?.position = position
        particle?.zPosition = 11
        particle?.numParticlesToEmit = 55
        
        let xPos = light.position.x - tool.position.x
        let yPos = light.position.y - tool.position.y
        let desiredAng = atan2(yPos, xPos)
        particle?.emissionAngle = desiredAng
        
        addChild(particle!)
    }
    
    func lightUp() {
        let light = SKLightNode()
        light.categoryBitMask = 2
        light.zPosition = -10
        light.ambientColor = UIColor.blackColor()
        light.falloff = 1
        light.position = CGPoint(x: 0, y: 0)
        light.lightColor = UIColor.whiteColor()
        player.addChild(light)
    }
    
    }

