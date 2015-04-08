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
            m.position = CGPoint(x:0,y:0)
            m.centerAround((self.map?.tiles[2,2])!)
            m.removeFromParent()
            self.addChild(m)
        }

        GameEngine.Instance.updateInfoPanel()
    }

    func resetMap() {
        // remove
        self.map?.removeFromParent()
        let position = self.map?.position // remember map position

        // new map
        self.map = GameEngine.Instance.map
        self.map?.draw()
        self.map?.position = position ?? CGPoint(x: -Constants.Map.dimension * Constants.Tile.size / 2, y: Constants.Map.dimension * Constants.Tile.size / 2)
        self.addChild(self.map!)

        GameEngine.Instance.updateInfoPanel()
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
            } else if let tile = touchedNode.parent?.parent as? Tile {
                self.map?.selected = tile
                self.newSelection()
            }
        }
    }

    private func newSelection() {
        if let map = self.map? {
            GameEngine.Instance.updateInfoPanel()
        }
    }

    override func touchesMoved(touches: NSSet, withEvent event: UIEvent) {
        let touch = touches.anyObject()! as UITouch
        let current = touch.locationInNode(self)
        let prev = touch.previousLocationInNode(self)

        let translation = CGPoint(x: current.x - prev.x, y: current.y - prev.y)

        map?.scroll(translation)
    }

    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
    }
}
