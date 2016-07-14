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
    
    var player: SKSpriteNode!
    var goal: SKSpriteNode!
    var ground: SKSpriteNode!
    var left: MSButtonNode!
    var right: MSButtonNode!
    var jump: MSButtonNode!
    var leftLabel: SKLabelNode!
    var rightLabel: SKLabelNode!
    var jumpLabel: SKLabelNode!
    
    
    override func didMoveToView(view: SKView) {
        /* Setup your scene here */
        
        player = self.childNodeWithName("player") as! SKSpriteNode
        goal = self.childNodeWithName("goal") as! SKSpriteNode
        ground = self.childNodeWithName("ground") as! SKSpriteNode
        left = self.childNodeWithName("left") as! MSButtonNode
        right = self.childNodeWithName("right") as! MSButtonNode
        jump = self.childNodeWithName("jump") as! MSButtonNode
        leftLabel = left.childNodeWithName("leftLabel") as! SKLabelNode
        rightLabel = right.childNodeWithName("rightLabel") as! SKLabelNode
        jumpLabel = jump.childNodeWithName("jumpLabel") as! SKLabelNode
        
        
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
        print("jump started")
        player.physicsBody?.applyImpulse(CGVectorMake(0, 40))
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
        if player.physicsBody?.velocity.dy > 300 {
            player.physicsBody?.velocity.dy = 300
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
        }
        
    }
}
