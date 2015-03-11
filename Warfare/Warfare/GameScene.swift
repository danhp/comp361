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
            m.position = CGPoint(x: -Constants.Map.dimension * Constants.Tile.size / 2, y: Constants.Map.dimension * Constants.Tile.size / 2)
            self.addChild(m)
        }
        
		Hud.Instance.update()
		self.addChild(Hud.Instance)

    }
    
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        /* Called when a touch begins */
        
        let touch = touches.anyObject() as UITouch
        let touchLocation = touch.locationInNode(self)
        
        if let touchedNode = nodeAtPoint(touchLocation) as? Tile {
            self.map?.selected = touchedNode
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
}
