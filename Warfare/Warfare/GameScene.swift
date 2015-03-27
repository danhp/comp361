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
            m.removeFromParent()
            self.addChild(m)
        }

		Hud.Instance.update()
        Hud.Instance.removeFromParent()
        self.addChild(Hud.Instance)
    }
    
    func resetMap() {
        // TODO remember position as well
        self.map?.removeFromParent()
        self.map = GameEngine.Instance.map
        self.map?.draw()
        self.map?.position = CGPoint(x: -Constants.Map.dimension * Constants.Tile.size / 2, y: Constants.Map.dimension * Constants.Tile.size / 2)
        self.addChild(self.map!)
        
        Hud.Instance.update()
    }
    
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        /* Called when a touch begins */
        
        let touch = touches.anyObject() as UITouch
        let touchLocation = touch.locationInNode(self)
        
        if let touchedTile = nodeAtPoint(touchLocation) as? Tile {
            self.map?.selected = touchedTile
            self.newSelection()
        } else if let touchedNode = nodeAtPoint(touchLocation) as? SKSpriteNode {
            if let tile = touchedNode.parent as? Tile {
                self.map?.selected = tile
                self.newSelection()
            }
        }
    }
    
    private func newSelection() {
        if let map = self.map? {
            if map.selected?.owner != nil {
                Hud.Instance.displayRegionalData(map.selected!)
            } else {
                Hud.Instance.update()
            }
            
            // Debugger uncomment to run 
            Hud.Instance.displayUnitDebugger(map.selected!)
            
            self.centerAroundSelected(map.selected!)
        }
    }
    
    func centerAroundSelected(centerAround: Tile) {
        if let map = self.map? {
            let positionInScene = convertPoint(centerAround.position, fromNode: map.scroller)
            let centerInScene = CGPoint(x: self.size.width/2, y: self.size.height/2)
            let delta = CGVector(dx:  -positionInScene.x , dy:  -positionInScene.y )
            map.scroll(delta)
        }
    }
	
	override func touchesMoved(touches: NSSet, withEvent event: UIEvent) {
        let touch = touches.anyObject()! as UITouch
        let current = touch.locationInNode(self)
        let prev = touch.previousLocationInNode(self)
        
        let translation = CGVector(dx: current.x - prev.x, dy: current.y - prev.y)
        
        map?.scroll(translation)
	}
   
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
    }
}
