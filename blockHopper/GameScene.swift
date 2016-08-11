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
        case Setup, Play, Gameover
    }
    
    //holds game state enum type
    var currState: GameState = .Setup {
        /* if currState is set to be these types: */
        didSet {
            switch currState {
            case .Setup:
                //can't move player
                self.player.physicsBody?.dynamic = false
                break
            case .Play:
                /* allows movement for player */
                self.player.physicsBody?.dynamic = true
                break
            case .Gameover:
                player.physicsBody?.dynamic = false
                left.userInteractionEnabled = false
                right.userInteractionEnabled = false
                jump.userInteractionEnabled = false
            }
        }
    }
    
    //keeps track of if you will move or not
    var goLeft: Bool = false
    var goRight: Bool = false
    
    //scene props
    var player: Player!
    var goal: SKSpriteNode!
    var ground: SKSpriteNode!
    var left: MSButtonNode!
    var right: MSButtonNode!
    var jump: MSButtonNode!
    var restart: MSButtonNode!
    var uiLayer: SKNode!
    var level: SKNode!
    var winLabel: SKLabelNode!
    var goaLight: SKEmitterNode!
    var instruction: SKLabelNode?
    var currentLevel = 0
    
    
    
    //initialize objects in game scene
    var platform1 : Tool!
    var platform2 : Tool!
    var box : SKShapeNode!
    var dragObject: Tool?
    
    override func didMoveToView(view: SKView) {
        /* Setup your scene here */
        view.showsPhysics = true
        
        var path:String!
        switch currentLevel {
        case 0:
            path = NSBundle.mainBundle().pathForResource("Tutorial", ofType: "sks")!
            break
        case 1:
            path = NSBundle.mainBundle().pathForResource("level1", ofType: "sks")!
            break
            //        case 2:
        //            path = NSBundle.mainBundle().pathForResource("level2", ofType: "sks")
        default:
            print("blah")
        }
        
        level = SKReferenceNode (URL: NSURL (fileURLWithPath: path)).children[0]
        addChild(level)
        
        //how to add a sks file into a scene
        
        //sets up connections with scene props
        uiLayer = self.childNodeWithName(Constants.hudLayer)!
        player = self.level.childNodeWithName("//" + Constants.player) as! Player
        ground = self.level.childNodeWithName("//" + Constants.ground) as! SKSpriteNode
        left = uiLayer.childNodeWithName(Constants.leftButton) as! MSButtonNode
        right = uiLayer.childNodeWithName(Constants.rightButton) as! MSButtonNode
        jump = uiLayer.childNodeWithName(Constants.jumpButton) as! MSButtonNode
        restart = self.childNodeWithName(Constants.restartButton) as! MSButtonNode
        goal = level.childNodeWithName("//goal") as! SKSpriteNode
        winLabel = level.childNodeWithName("//winLabel") as! SKLabelNode
        instruction = level.childNodeWithName("//instruction") as? SKLabelNode
        
        //sets up boundary so you can't go off-screen
        self.physicsBody = SKPhysicsBody(edgeLoopFromRect: CGRect(x: 0, y: 0, width: self.frame.size.width,
            height: self.frame.size.height))
        self.physicsBody?.affectedByGravity = false
        self.physicsBody?.dynamic = false
        
        restart.state = .Hidden
        
        winLabel.userInteractionEnabled = false
        winLabel.alpha = 0
        
        instruction?.userInteractionEnabled = false
        instruction?.alpha = 0
        
        let delay = SKAction.waitForDuration(5)
        let turnOnInstruction = SKAction.runBlock({
            self.instruction?.alpha = 1
            self.instruction?.zPosition = 10
        })
        let sequence = SKAction.sequence([delay, turnOnInstruction])
        runAction(sequence)
        
        restart.selectionBegan = {
            /* Grab reference to our SpriteKit view */
            let skView = self.view as SKView!
            skView.showsFPS = true
            skView.showsNodeCount = true
            
            /* Load Game scene */
            let scene = GameScene(fileNamed:"GameScene") as GameScene!
            
            /* Ensure correct aspect mode */
            scene.scaleMode = .AspectFill
            
            /* Restart game scene */
            skView.presentScene(scene)
        }
        
        //adds light to middle of player block
        player.createLight()
        
        //generates space for tools to be in
        generateToolSpace()
                
        //generate circle object
        platform1 = Tool(type: Tool.ToolType.platform1, homePos: CGPoint(x: 60, y: 400))
        if currentLevel == 1 {
            platform1.color = UIColor.grayColor()
        }
        level.addChild(platform1)
        
        //generate square object
        if currentLevel == 0 {
        platform2 = Tool(type: Tool.ToolType.platform2, homePos: CGPoint(x: 60, y: 500))
        level.addChild(platform2)
        } else if currentLevel == 1 {
            platform2 = Tool(type: Tool.ToolType.platform3, homePos: CGPoint(x: 60, y: 500))
            level.addChild(platform2)
        }
        
        
        /* Set physics contact delegate */
        physicsWorld.contactDelegate = self
        
        //if buttons are clicked, call movement functions
        left.selectionBegan = leftStarted
        right.selectionBegan = rightStarted
        jump.selectionBegan = jumpStarted
        
        //when not clicking, the movement functions end
        left.selectionEnded = {
            self.goLeft = false
            self.player.lightingBitMask = 0
            self.player.texture = SKTexture(imageNamed: "stationaryRect")
        }
        right.selectionEnded = {
            self.goRight = false
            self.player.lightingBitMask = 0
            self.player.texture = SKTexture(imageNamed: "stationaryRect")
        }
        jump.selectionEnded = {self.player.lightingBitMask = 0}
        
        if currentLevel == 1 {
            burnBabyBurn(CGPoint(x: 490, y: 205),
                         size: CGRect(x: -115, y: -18, width: 230, height: 40),
                         fire: SKEmitterNode(fileNamed: "fire")!,
                         length: CGVector(dx: 270, dy: 5))
            burnBabyBurn(CGPoint(x: 860, y: 205),
                         size: CGRect(x: -135, y: -18, width: 268, height: 40),
                         fire: SKEmitterNode(fileNamed: "fire")!,
                         length: CGVector(dx: 305, dy: 5))
        }
    }
    
    //move functions
    func leftStarted() {
        goLeft = player.moveLeft()
    }
    func rightStarted() {
        goRight = player.moveRight()
    }
    func jumpStarted() {
        player.jump()
    }
    
    func generateToolSpace () {
        //generates space for the objects
        box = SKShapeNode(rect:
            CGRect(x: 0, y: 0, width: 120, height: frame.size.height - ground.size.height)
            , cornerRadius: 30)
        box.position = CGPoint(x: 0, y: ground.size.height)
        box.zPosition = 1
        box.fillColor = UIColor.whiteColor()
        box.physicsBody = SKPhysicsBody(edgeLoopFromRect:
            CGRect(x: 0, y: 0, width: 120, height:
                frame.size.height - ground.size.height))
        box.physicsBody?.collisionBitMask = 2
        level.addChild(box)
    }
    
    func burnBabyBurn(position : CGPoint, size: CGRect, fire: SKEmitterNode, length: CGVector) {
        let fire: SKEmitterNode = fire
        fire.zPosition = 1
        fire.position = position
        fire.physicsBody = SKPhysicsBody(edgeLoopFromRect:
            size)
        fire.physicsBody?.affectedByGravity = false
        fire.physicsBody?.dynamic = false
        fire.physicsBody?.categoryBitMask = 1
        fire.particlePositionRange = length
        level.addChild(fire)
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        
        if currState == .Gameover { return }
        
        /* Called when a touch begins */
        //        print("gamescene touches began")
        
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
                tool.toolAnimationStart()
                tool.physicsBody?.collisionBitMask = 0
                tool.physicsBody?.dynamic = true
                tool.physicsBody?.affectedByGravity = false
                
            }
        }
    }
    
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        
        if currState == .Gameover { return }
        
        for touch in touches {
            let location = touch.locationInNode(self)
            //if you touched a tool
            if let tool = dragObject {
                //tool moves to where you drag
                tool.toolAnimationStart()
                tool.position = location
            }
        }
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        
        if currState == .Gameover { return }
        
        //if you're dragging the tool
        if let tool = dragObject {
            
            //looping through all children of the scene
            for node in level.children {
                if node == tool || node == restart || node.name == "groundRect"
                    || node.name == "flames" || node.name == "background"
                    || node.name == "hill" || node.name == "volcano" {
                    continue
                }
                
                // sets up intersection check
                let intersect : Bool = tool.intersectsNode(node)
                
                //if tool intersects another tool
                
                if  intersect {
                    tool.position = tool.homePos
                    tool.physicsBody?.collisionBitMask = 1
                    tool.physicsBody?.affectedByGravity = false
                    tool.physicsBody?.dynamic = false
                    
                    break
                }
                tool.toolAnimationEnd()
                tool.physicsBody?.collisionBitMask = 1
                tool.physicsBody?.dynamic = false
            }
        }
        //change game state
        if currState == .Setup {
            currState = .Play
        }
        dragObject = nil
    }
    
    
    override func update(currentTime: CFTimeInterval) {
        
        if currState == .Gameover { return }
        
        /* Called before each frame is rendered */
        
        //if buttons clicked, apply force corresponding to desired direction
        if goRight {
            player.physicsBody?.applyForce(CGVector(dx: 200, dy: 0))
        }
        
        if goLeft {
            player.physicsBody?.applyForce(CGVector(dx: -200, dy: 0))
        }
        
        // caps jumping height
        if player.physicsBody?.velocity.dy > 650 {
            player.physicsBody?.velocity.dy = 650
        }
        
        //caps speed
        if player.physicsBody?.velocity.dx > 200 {
            player.physicsBody?.velocity.dx = 200
        } else if player.physicsBody?.velocity.dx < -200 {
            player.physicsBody?.velocity.dx = -200
        }
    }
    
    func didBeginContact(contact: SKPhysicsContact) {
        
        if currState == .Gameover { return }
        
        /* Get references to bodies involved in collision */
        let contactA:SKPhysicsBody = contact.bodyA
        let contactB:SKPhysicsBody = contact.bodyB
        
        /* Get references to the physics body parent nodes */
        let nodeA = contactA.node!
        let nodeB = contactB.node!
        
        //if player is touching goal, cannot jump
        if nodeA.name == Constants.player && nodeB.name == Constants.goal || nodeA.name == Constants.goal
            && nodeB.name == Constants.player {
            
            if currentLevel == 1 {
                
                winLabel.alpha = 1
                restart.state = .Active
                currState = .Gameover

            }
            print("hit goal")
            currentLevel += 1
            print(currentLevel)
            
            if currentLevel == 1 {
                /* Grab reference to our SpriteKit view */
                let skView = self.view as SKView!
                
                /* Load Game scene */
                let scene = GameScene(fileNamed:"GameScene") as GameScene!
                
                scene.currentLevel = currentLevel
                
                /* Ensure correct aspect mode */
                scene.scaleMode = .AspectFill
                
                /* Show debug */
                //skView.showsPhysics = true
                skView.showsDrawCount = true
                skView.showsFPS = true
                
                /* Start game scene */
                skView.presentScene(scene)
            }
            
            //restart.state = .Active
            //currState = .Gameover
        }
        
        if nodeA.name == Constants.player && nodeB.name == Constants.ground
            || nodeA.name == Constants.ground && nodeB.name == Constants.player {
            player.jumpCount = 0
            print(player.position)
        }
        
        //check collision
        if nodeA.name == Constants.player && nodeB.name == "tool"
            || nodeA.name == "tool" && nodeB.name == Constants.player {
            
            if nodeA == platform1 || nodeB == platform1 {
                platform1.bounce(player, circle: platform1)
            }
            
            //is it node A?
            if let tool = nodeA as? Tool {
                if player.position.y - (player.frame.size.height/2) > tool.position.y + (tool.frame.size.height/2) - 3 {
                    player.jumpCount = 0
                }
            }
                //is it node B?
            else if let tool = nodeB as? Tool {
                
                if player.position.y - (player.frame.size.height/2)
                    > tool.position.y + (tool.frame.size.height/2) - 3 {
                    
                    player.jumpCount = 0
                }
            }
        }
        
        if (nodeA.name == "flames" && nodeB.name == "player")
            || (nodeA.name == "player" && nodeB.name == "flames") {
            
            print("game over")
            restart.state = .Active
            currState = .Gameover
        }
    }
    
    func didEndContact(contact: SKPhysicsContact) {
        
        if currState == .Gameover { return }
        
        let contactA:SKPhysicsBody = contact.bodyA
        let contactB:SKPhysicsBody = contact.bodyB
        
        /* Get references to the physics body parent nodes */
        let nodeA = contactA.node!
        let nodeB = contactB.node!
        
        if nodeA.name == "player" && nodeB.name == "tool" || nodeA.name == "tool" && nodeB.name == "player" {
            
            //is it node A?
            if let tool = nodeA as? Tool {
                tool.light()
                
                //is it node B?
            } else if let tool = nodeB as? Tool {
                tool.light()
            }
        }
    }
}


