//
//  TitlePage.swift
//  blockHopper
//
//  Created by Xi Stephen Ouyang on 7/28/16.
//  Copyright © 2016 Make School. All rights reserved.
//

import Foundation
import SpriteKit

class TitlePage: SKScene {
    /* UI Connections */
    var startButton: MSButtonNode!
    var settingsButton: MSButtonNode!
    
    override func didMoveToView(view: SKView) {
        /* Setup your scene here */
        
        /* Set UI connections */
        startButton = self.childNodeWithName("startButton") as! MSButtonNode
        settingsButton = self.childNodeWithName("SettingsButton") as! MSButtonNode
        
        settingsButton.state = .Hidden
        
        /* Setup restart button selection handler */
        startButton.selectionBegan = {
            
            /* Grab reference to our SpriteKit view */
            let skView = self.view as SKView!
            
            /* Load Game scene */
            let scene = GameScene(fileNamed:"GameScene") as GameScene!
            /* Ensure correct aspect mode */
            scene.scaleMode = .AspectFit
            
            /* Show debug */
            skView.showsPhysics = false
            skView.showsDrawCount = false
            skView.showsFPS = false
            skView.showsNodeCount = false
            
            /* Start game scene */
            skView.presentScene(scene)
        }
    }
}
