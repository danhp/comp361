//
//  GameScene.swift
//  warfare
//
//  Created by Justin Domingue on 2015-01-21.
//  Copyright (c) 2015 Justin Domingue. All rights reserved.
//

import SpriteKit

class GameScene: SKScene {
    var map: Map?
	
    override func didMoveToView(view: SKView) {
		self.anchorPoint = CGPointMake(0.5, 0.5)

        // Initialize tiles array
        var array = [[Tile]]()
        for row in 0..<Constants.Map.dimension {
            array.append(Array<Tile>())
            for column in 0..<Constants.Map.dimension {
                array[row].append(Tile(coordinates: (column, row)))
            }
        }
        
        map = Map(array: array)
		map?.draw()
		self.addChild(map!)
    }
    
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        /* Called when a touch begins */
        
        for touch: AnyObject in touches {
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
