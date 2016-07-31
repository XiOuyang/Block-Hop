//
//  Tutorial.swift
//  blockHopper
//
//  Created by Xi Stephen Ouyang on 7/29/16.
//  Copyright © 2016 Make School. All rights reserved.
//

import Foundation
import SpriteKit

class Tutorial: SKScene, SKPhysicsContactDelegate {
    
    //keeps track of if you will move or not
    var goLeft: Bool = false
    var goRight: Bool = false

    var uiLayer: SKNode!
    var player: Player!
    var ground: SKSpriteNode!
    var leftButton: MSButtonNode!
    var rightButton: MSButtonNode!
    var jumpButton: MSButtonNode!
    var groundLight: SKLightNode!
    var goal: SKEmitterNode!
    
    override func didMoveToView(view: SKView) {
        
        uiLayer = self.childNodeWithName("hudLayer")!
        player = self.childNodeWithName("Player") as! Player
        ground = self.childNodeWithName("ground") as! SKSpriteNode
        leftButton = uiLayer.childNodeWithName("leftButton") as! MSButtonNode
        rightButton = uiLayer.childNodeWithName("rightButton") as! MSButtonNode
        jumpButton = uiLayer.childNodeWithName("jumpButton") as! MSButtonNode
        groundLight = self.childNodeWithName("groundLight") as! SKLightNode
        
        /* sets up boundary so you can't go off-screen */
        self.physicsBody =                                      //sets up scene as it's own physics body
            SKPhysicsBody(edgeLoopFromRect: CGRect(x: 0, y: 0,
                width: self.frame.size.width,
                height: self.frame.size.height))
        
        self.physicsBody?.affectedByGravity = false
        self.physicsBody?.dynamic = false
        
        //adds light to middle of player block
        player.createLight()
        
        //generates the goal object
        generateGoal()
        
        /* Set physics contact delegate */
        physicsWorld.contactDelegate = self
        
        //if buttons are clicked, call movement functions
        leftButton.selectionBegan = leftStarted
        rightButton.selectionBegan = rightStarted
        jumpButton.selectionBegan = jumpStarted
        
        //when not clicking, the movement functions end
        leftButton.selectionEnded = {
            self.goLeft = false
            self.player.lightingBitMask = 0
            self.player.texture = SKTexture(imageNamed: "stationaryRect")
        }
        rightButton.selectionEnded = {
            self.goRight = false
            self.player.lightingBitMask = 0
            self.player.texture = SKTexture(imageNamed: "stationaryRect")
        }
        
        jumpButton.selectionEnded = {self.player.lightingBitMask = 0}
        
    }
    
    override func update(currentTime: CFTimeInterval) {
        
        //if currState == .Gameover { return }
        
        /* Called before each frame is rendered */
        
        //if buttons clicked, apply force corresponding to desired direction
        if goRight {
            player.physicsBody?.applyForce(CGVector(dx: 200, dy: 0))
        } else if goLeft {
            player.physicsBody?.applyForce(CGVector(dx: -200, dy: 0))
        }
        
        // caps jumping height
        if player.physicsBody?.velocity.dy > 575 {
            player.physicsBody?.velocity.dy = 575
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
        
        
        
        

    }

    func generateGoal() {
        goal = SKEmitterNode(fileNamed: "goal")
        goal.position = CGPoint(x: 1050, y: 500)
        goal.physicsBody = SKPhysicsBody(circleOfRadius: 20)
        goal.physicsBody?.affectedByGravity = false
        goal.physicsBody?.dynamic = false
        addChild(goal)
    }
    
    func leftStarted() {
        goLeft = player.moveLeft()
    }
    func rightStarted() {
        goRight = player.moveRight()
    }
    func jumpStarted() {
        player.jump()
    }

}


