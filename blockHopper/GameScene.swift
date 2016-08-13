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
    var crabInverse: Bool = false
    
    //scene props
    var player: Player!
    var background: SKSpriteNode!
    var goal: SKSpriteNode!
    var ground: SKSpriteNode!
    var crab: SKSpriteNode!
    var crabTexture: SKTexture!
    var left: MSButtonNode!
    var right: MSButtonNode!
    var jump: MSButtonNode!
    var restart: MSButtonNode!
    var uiLayer: SKNode!
    var level: SKNode!
    var winLabel: SKLabelNode!
    var loseLabel: SKLabelNode!
    var goUp: SKLabelNode?
    var goaLight: SKEmitterNode!
    var instruction: SKLabelNode?
    var currentLevel = 0
    
    
    //initialize objects in game scene
    var platform1 : Tool!
    var platform2 : Tool!
    var box : SKShapeNode!
    var dragObject: Tool?
    
    var meteor1: SKEmitterNode!
    var meteor2: SKEmitterNode!
    var meteor3: SKEmitterNode!
    
    var meteorHome1 = CGPoint(x: 400, y: 1500)
    var meteorHome2 = CGPoint(x: 600, y: 1500)
    var meteorHome3 = CGPoint(x: 800, y: 1500)
    
    override func didMoveToView(view: SKView) {
        /* Setup your scene here */
        view.showsPhysics = false
        currentLevel = NSUserDefaults.standardUserDefaults().integerForKey("currentLevel")
        
        var path:String!
        switch currentLevel {
        case 0:
            path = NSBundle.mainBundle().pathForResource("Tutorial", ofType: "sks")!
            break
        case 1:
            path = NSBundle.mainBundle().pathForResource("level1", ofType: "sks")!
            break
        case 2:
            path = NSBundle.mainBundle().pathForResource("level2", ofType: "sks")!
        default:
            print("blah")
        }
        
        level = SKReferenceNode (URL: NSURL (fileURLWithPath: path)).children[0]
        addChild(level)
        
        //how to add a sks file into a scene
        
        //sets up connections with scene props
        uiLayer = camera!.childNodeWithName(Constants.hudLayer)!
        player = level.childNodeWithName("//" + Constants.player) as! Player
        ground = level.childNodeWithName("//" + Constants.ground) as! SKSpriteNode
        //crab = level.childNodeWithName("//crab1") as? SKSpriteNode
        left = uiLayer.childNodeWithName(Constants.leftButton) as! MSButtonNode
        right = uiLayer.childNodeWithName(Constants.rightButton) as! MSButtonNode
        jump = uiLayer.childNodeWithName(Constants.jumpButton) as! MSButtonNode
        restart = camera!.childNodeWithName(Constants.restartButton) as! MSButtonNode
        goal = level.childNodeWithName("//goal") as! SKSpriteNode
        winLabel = level.childNodeWithName("//winLabel") as! SKLabelNode
        loseLabel = level.childNodeWithName("//loseLabel") as! SKLabelNode
        instruction = level.childNodeWithName("//instruction") as? SKLabelNode
        goUp = level.childNodeWithName("//goUp") as? SKLabelNode
        background = level.childNodeWithName("//background") as! SKSpriteNode
        
        //sets up boundary so you can't go off-screen
        self.physicsBody = SKPhysicsBody(edgeLoopFromRect: CGRect(x: 0, y: 0,
            width: background.frame.size.width,
            height: background.frame.size.height))
        self.physicsBody?.affectedByGravity = false
        self.physicsBody?.dynamic = false
        
        restart.state = .Active
        
        winLabel.userInteractionEnabled = false
        winLabel.alpha = 0
        loseLabel.userInteractionEnabled = false
        loseLabel.alpha = 0
        goUp?.alpha = 1
        
        instruction?.userInteractionEnabled = false
        instruction?.alpha = 0
        
        let delay = SKAction.waitForDuration(5)
        let turnOnInstruction = SKAction.runBlock({
            self.instruction?.alpha = 1
            self.instruction?.zPosition = 10
        })
        let sequence = SKAction.sequence([delay, turnOnInstruction])
        runAction(sequence)
        
        restart.selectionBegan = clickRestart
        
        //adds light to middle of player block
        player.createLight()
        if currentLevel == 2 {
            meteor1 = createMeteors( meteorHome1)
            meteor2 = createMeteors( meteorHome2)
            meteor3 = createMeteors( meteorHome3)
        }
        
        if currentLevel == 2 {
            makeCrab(CGPoint(x: 618, y: 150), size: CGSize(width: 500, height: 350))
        }
        
        //generate platform1 object
        if currentLevel <= 1 {
            platform1 = Tool(type: Tool.ToolType.platform1, homePos: CGPoint(x: 60, y: 400))
            if currentLevel == 1 {
                platform1.color = UIColor.grayColor()
            }
        }
        else if currentLevel == 2 {
            platform1 = Tool(type: Tool.ToolType.platform4, homePos: CGPoint(x: 60, y: 400))
        }
        level.addChild(platform1)
        
        //generate platform2 object
        if currentLevel == 0 {
            platform2 = Tool(type: Tool.ToolType.platform2, homePos: CGPoint(x: 60, y: 500))
            level.addChild(platform2)
        }
        else if currentLevel == 1 {
            platform2 = Tool(type: Tool.ToolType.platform3, homePos: CGPoint(x: 60, y: 500))
            level.addChild(platform2)
        }
        else if currentLevel == 2 {
            platform2 = Tool(type: Tool.ToolType.platform4, homePos: CGPoint(x: 60, y: 500))
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
    
    func clickRestart() {
        let delayRestart = SKAction.waitForDuration(0.7)
        let restartScene = SKAction.runBlock ({
            
            /* Grab reference to our SpriteKit view */
            let skView = self.view as SKView!
            //
            //            skView.showsFPS = true
            //            skView.showsNodeCount = true
            skView.showsPhysics = false
            
            /* Load Game scene */
            let scene = GameScene(fileNamed:"GameScene") as GameScene!
            
            /* Ensure correct aspect mode */
            scene.scaleMode = .AspectFit
            
            /* Restart game scene */
            skView.presentScene(scene)
        })
        
        let restartSequence = SKAction.sequence([delayRestart, restartScene])
        self.runAction(restartSequence)
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
    
    func makeCrab(position: CGPoint, size: CGSize) {
        crab = SKSpriteNode(imageNamed: "crab")
        crabTexture = SKTexture(imageNamed: "crab")
        crab.physicsBody = SKPhysicsBody(texture: crabTexture, size: size)
        crab.size = size
        crab.zPosition = 1
        crab.position = position
        crab.physicsBody?.affectedByGravity = true
        crab.physicsBody?.allowsRotation = false
        crab.physicsBody?.categoryBitMask = 2
        crab.physicsBody?.collisionBitMask = 9
        crab.physicsBody?.contactTestBitMask = 9
        crab.name = "crab"
        level.addChild(crab)
    }
    
    func createMeteors(position: CGPoint) -> SKEmitterNode {
        var meteor = SKEmitterNode(fileNamed: "meteor")!
        meteor.zPosition = 0
        meteor.position = position
        meteor.physicsBody = SKPhysicsBody(circleOfRadius: 25)
        meteor.physicsBody?.affectedByGravity = false
        meteor.physicsBody?.categoryBitMask = 0
        meteor.physicsBody?.contactTestBitMask = 1
        meteor.physicsBody?.collisionBitMask = 0
        meteor.physicsBody?.velocity.dy = -400
        level.addChild(meteor)
        return meteor
    }
    
    func checkMeteorPosition(meteor: SKEmitterNode, position: CGPoint) {
        if meteor.position.y < scene?.position.y {
            meteor.position = position
            
            
            let delay = SKAction.waitForDuration(Double(arc4random_uniform(10)))
            let fall = SKAction.runBlock({
                meteor.physicsBody?.velocity.dy = -400
            })
            let moveMeteor = SKAction.sequence([delay, fall])
            runAction(moveMeteor)
        }
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
                
                //if tool intersects another tool
                if (node != dragObject && node is Tool) ||
                    node.name == Constants.ground ||
                    node.name == Constants.goal ||
                    node.name == Constants.player ||
                    node.name == "water" {
                    
                    // sets up intersection check
                    let intersect : Bool = tool.intersectsNode(node)
                    
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
        playerMovement()
        
        if currentLevel == 2 {
            crabMovement()
            
            checkMeteorPosition(meteor1, position: meteorHome1)
            checkMeteorPosition(meteor2, position: meteorHome2)
            checkMeteorPosition(meteor3, position: meteorHome3)
        }
        if player.position.x > self.frame.size.width/2
            && player.position.x < self.frame.size.width/2 {
            camera!.position.x = player.position.x
        }
        if player.position.y > frame.size.height/2
            && player.position.y < background.frame.size.height - frame.height/2 {
            camera!.position.y = player.position.y
        }
    }
    
    func crabMovement() {
        
        if crabInverse == false {
            crab.physicsBody?.applyForce(CGVector(dx: 1000, dy: 0))
            
        } else if crabInverse == true {
            crab.physicsBody?.applyForce(CGVector(dx: -1000, dy: 0))
            
        }
    }
    
    func playerMovement() {
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
    
    func hitGoal() {
        if currentLevel == 2 {
            winLabel.alpha = 1
            currState = .Gameover
        }
        
        print("hit goal")
        currentLevel += 1
        if currentLevel == 3 {
            currentLevel = 0
        }
        
        NSUserDefaults.standardUserDefaults().setInteger(currentLevel, forKey: "currentLevel")
        print(currentLevel)
        
        if currentLevel < 3 {
            /* Grab reference to our SpriteKit view */
            let skView = self.view as SKView!
            
            /* Load Game scene */
            let scene = GameScene(fileNamed:"GameScene") as GameScene!
            
            scene.currentLevel = currentLevel
            
            /* Ensure correct aspect mode */
            scene.scaleMode = .AspectFit
            
            /* Show debug */
            skView.showsPhysics = false
            skView.showsNodeCount = false
            //            skView.showsDrawCount = true
            //            skView.showsFPS = true
            
            /* Start game scene */
            skView.presentScene(scene)
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
        
        //check collision
        
        checkCollision(nodeA, nodeB: nodeB)
        checkCollision(nodeB, nodeB: nodeA)
        
    }
    
    
    func checkCollision(nodeA: SKNode, nodeB: SKNode) {
        
        if nodeA is Player {
            //if player is touching goal
            if nodeB.name == Constants.goal {
                hitGoal()
            }
            else if nodeB.name == Constants.ground {
                player.jumpCount = 0
            }
            else if let tool = nodeB as? Tool {
                
                if tool.type == Tool.ToolType.platform1 {
                    platform1.bounce(player, circle: platform1)
                }
                
                if player.position.y - (player.frame.size.height/2)
                    > tool.position.y + (tool.frame.size.height/2) - 3 {
                    
                    player.jumpCount = 0
                }
            }
            else if nodeB.name == "flames" {
                
                loseLabel.alpha = 1
                currState = .Gameover
                
            }
            else if nodeB.name == "crab" {
                
                loseLabel.alpha = 1
                currState = .Gameover
            }
            else if nodeB.name == "meteor" {
                
                loseLabel.alpha = 1
                currState = .Gameover
            }
        }
        if (nodeA.name == "crab" && nodeB.name == Constants.ground)
            || (nodeA.name == "crab" && nodeB.name == "scene") {
            crabInverse = !crabInverse
        }
    }
}


