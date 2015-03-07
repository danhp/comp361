//
//  GameScene.swift
//  warfare
//
//  Created by Justin Domingue on 2015-01-21.
//  Copyright (c) 2015 Justin Domingue. All rights reserved.
//

import UIKit
import SpriteKit

class GameScene: SKScene {
    var map: Map?
	
    override func didMoveToView(view: SKView) {
		self.anchorPoint = CGPointMake(0.5, 0.5)

        self.map = GameEngine.Instance.map

        if let m = self.map {
            m.draw()
            self.addChild(m)
        }
        
        setupHud()
    }
    
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        /* Called when a touch begins */
        
        let touch = touches.anyObject() as UITouch
        let touchLocation = touch.locationInNode(self)
        
        if let touchedNode = nodeAtPoint(touchLocation) as? Tile {
            self.map?.selected = touchedNode
        } else if let touchedNode = nodeAtPoint(touchLocation) as? SKLabelNode {
            MatchHelper.sharedInstance().joinMatch()
        }
        
    }
	
	override func touchesMoved(touches: NSSet, withEvent event: UIEvent) {
        let touch = touches.anyObject()! as UITouch
        let current = touch.locationInNode(self)
        let prev = touch.previousLocationInNode(self)
        
        let translation = CGPointMake(current.x - prev.x, current.y - prev.y)
        
        map?.scroll(translation)
	}
   
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
    }
    
    func setupHud() {
        
        //create gold label
        let goldLabel = SKLabelNode(fontNamed: "Courier")
        goldLabel.name = kGoldHudName
        goldLabel.fontSize = 25
        
        goldLabel.fontColor = SKColor.blackColor()
        goldLabel.text = "Gold: " + String((GameEngine.Instance.game?.currentPlayerGold)!)
        
        println(size.height)
        //Note need to position relative and scalable - not hard coded
        goldLabel.position = CGPoint(x: -430, y: 250 )
        addChild(goldLabel)
        
        //create wood label
        let woodLabel = SKLabelNode(fontNamed: "Courier")
        woodLabel.name = kWoodHudName
        woodLabel.fontSize   = 25
        
        woodLabel.fontColor = SKColor.redColor()
        //Note need to poisiton relative and scalable - not hard coded
        woodLabel.text = NSString(format: "Wood: %02u", 100.0)
        
        woodLabel.position = CGPoint(x: -250, y: 250)
        woodLabel.text = "Wood: " + String((GameEngine.Instance.game?.currentPlayerWood)!)
        addChild(woodLabel)
        
    }
    
    let kGoldHudName = "Gold"
    let kWoodHudName = "Wood"
}
