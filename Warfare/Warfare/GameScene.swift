//
//  GameScene.swift
//  warfare
//
//  Created by Justin Domingue on 2015-01-21.
//  Copyright (c) 2015 Justin Domingue. All rights reserved.
//

import SpriteKit

class GameScene: SKScene {
	let map = Map()
	
    override func didMoveToView(view: SKView) {
		self.anchorPoint = CGPointMake(0.5, 0.5)

		map.draw()
		self.addChild(map)
    }
    
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        /* Called when a touch begins */
        
        for touch: AnyObject in touches {
        }
    }
	
	override func touchesMoved(touches: NSSet, withEvent event: UIEvent) {
		for touch: AnyObject in touches {
			let current = touch.locationInNode(self)
			let prev = touch.previousLocationInNode(self)
			
			let translation = CGPointMake(current.x - prev.x, current.y - prev.y)
			
			map.scroll(translation)
		}
	}
   
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
    }
}
