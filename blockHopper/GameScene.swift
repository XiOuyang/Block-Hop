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
                //return player to start position
                self.player.position = CGPoint(x: 200, y: 240)
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
    var goal: SKEmitterNode!
    var ground: SKSpriteNode!
    var left: MSButtonNode!
    var right: MSButtonNode!
    var jump: MSButtonNode!
    var restart: MSButtonNode!
    var leftLabel: SKLabelNode!
    var rightLabel: SKLabelNode!
    var jumpLabel: SKLabelNode!
    var uiLayer: SKNode!
    var light: SKLightNode!
    var level: SKReferenceNode!
    var currentLevel = 0
    
   
    
    //initialize objects in game scene
    var circle : Tool!
    var square : Tool!
    var box : SKShapeNode!
    var dragObject: Tool?
    
    override func didMoveToView(view: SKView) {
        /* Setup your scene here */
        //        view.showsPhysics = true
        
        var path:String!
        switch currentLevel {
        case 0:
             path = NSBundle.mainBundle().pathForResource("Tutorial", ofType: "sks")!
            break
        case 1:
            path = NSBundle.mainBundle().pathForResource("level1", ofType: "sks")!
            break
        default:
            print("blah")
        }
        
        level = SKReferenceNode (URL: NSURL (fileURLWithPath: path))
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
        leftLabel = left.childNodeWithName(Constants.leftLabel) as! SKLabelNode
        rightLabel = right.childNodeWithName(Constants.rightLabel) as! SKLabelNode
        jumpLabel = jump.childNodeWithName(Constants.jumpLabel) as! SKLabelNode
        light = level.childNodeWithName("//groundLight") as! SKLightNode
        
        //sets up boundary so you can't go off-screen
        self.physicsBody = SKPhysicsBody(edgeLoopFromRect: CGRect(x: 0, y: 0, width: self.frame.size.width,
            height: self.frame.size.height))
        self.physicsBody?.affectedByGravity = false
        self.physicsBody?.dynamic = false
        
        restart.state = .Hidden
        
        restart.selectionBegan = {
            /* Grab reference to our SpriteKit view */
            let skView = self.view as SKView!
            
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
        
        //generates the goal object
        generateGoal()
        
        //generate circle object
        circle = Tool(type: Tool.ToolType.circle, homePos: CGPoint(x: 60, y: 400))
        level.addChild(circle)
        
        //generate square object
        square = Tool(type: Tool.ToolType.square, homePos: CGPoint(x: 60, y: 500))
        level.addChild(square)
        
        
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
    
    func generateGoal() {
        goal = SKEmitterNode(fileNamed: "goal")
        
        let currentGoal = currentLevel
        print(currentGoal)
        
        switch currentGoal {
        case 0:
             goal.position = CGPoint(x: 1050, y: 220)
            break
        case 1:
            goal.position = CGPoint(x: 1050, y: 500)
            break
        default:
            print("blah")
        }
        
        goal.physicsBody = SKPhysicsBody(circleOfRadius: 20)
        goal.physicsBody?.affectedByGravity = false
        goal.physicsBody?.dynamic = false
        level.addChild(goal)
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
                tool.position = location
            }
        }
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        
        if currState == .Gameover { return }
        
        //if you're dragging the tool
        if let tool = dragObject {
            
            //looping through all children of the scene
            for node in
                level.children[0].children {
                if node == tool || node == restart {
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
        } else if goLeft {
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
            print("hit goal")
            currentLevel += 1
            print(currentLevel)
            
            /* Grab reference to our SpriteKit view */
            let skView = self.view as SKView!
            
            /* Load Game scene */
            let scene = GameScene(fileNamed:"GameScene") as GameScene!
            
            scene.currentLevel = currentLevel
            
            /* Ensure correct aspect mode */
            scene.scaleMode = .AspectFill
            
            /* Show debug */
            skView.showsPhysics = true
            skView.showsDrawCount = true
            skView.showsFPS = true
            
            /* Start game scene */
            skView.presentScene(scene)

            //restart.state = .Active
            //currState = .Gameover
        }
        
        
        if nodeA.name == Constants.player && nodeB.name == Constants.ground || nodeA.name == Constants.ground
            && nodeB.name == Constants.player {
            player.jumpCount = 0
        }
        //check collision
        if nodeA.name == Constants.player && nodeB.name == "tool" || nodeA.name == "tool" && nodeB.name == Constants.player {
            
            if nodeA == circle || nodeB == circle {
                circle.bounce(player, circle: circle)
            }
            
            //is it node A?
            if let tool = nodeA as? Tool {
                if nodeA == square {
                    //apply firefly particle effect on tool
                    tool.fireflyEffect(light)
                    //sets shade of the shadow from tool
                    light.shadowColor = UIColor(white: 0, alpha: 0.6)
                    //apply shadow effect
                    tool.shadow()
                }
                print(player.position.y - (player.frame.size.height/2))
                print(tool.position.y + (tool.frame.size.height/2) - 1)
                
                if player.position.y - (player.frame.size.height/2) > tool.position.y + (tool.frame.size.height/2) - 3 {
                    tool.delayGravity(tool)
                    player.jumpCount = 0
                }
                //is it node B?
            } else if let tool = nodeB as? Tool {
                if nodeB == square {
                    tool.fireflyEffect(light)
                    light.shadowColor = UIColor(white: 0, alpha: 0.6)
                    tool.shadow()
                }
                print(player.position.y - (player.frame.size.height/2))
                print(tool.position.y + (tool.frame.size.height/2) - 1)
                
                if player.position.y - (player.frame.size.height/2) > tool.position.y + (tool.frame.size.height/2) - 3 {
                    tool.delayGravity(tool)
                    player.jumpCount = 0
                }
            }
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
        
        if nodeA.name == "player" && nodeB.name == "goal" || nodeA.name == "goal" && nodeB.name == "player" {
            player.jumpCount = 0
        }
    }
}

// let c = UIColor(red: 222/255, green: 187/255, blue: 12/255, alpha: 1)
