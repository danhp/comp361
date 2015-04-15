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
    var moved: Bool = false

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
        let position = self.map?.scroller.position // remember map position
        self.map?.removeFromParent()

        // new map
        self.map = GameEngine.Instance.map
        self.map?.draw()
        self.map?.position = CGPoint(x: 0, y: 0)
        self.addChild(self.map!)
        self.map?.scroller.position = position ?? CGPoint(x: 0, y: 0)

        GameEngine.Instance.updateInfoPanel()
    }

    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        self.moved = false
    }

    override func touchesEnded(touches: Set<NSObject>, withEvent event: UIEvent) {
        if self.moved { return }

        let touch = touches.first as! UITouch
        let touchLocation = touch.locationInNode(self)
        let touchedNode = nodeAtPoint(touchLocation)

        if let touchedTile = touchedNode as? Tile {
            self.map?.selected = touchedTile
            self.newSelection()
        } else if let tile = touchedNode.parent as? Tile {
            self.map?.selected = tile
            self.newSelection()
        } else if let tile = touchedNode.parent?.parent as? Tile {
            self.map?.selected = tile
            self.newSelection()
        }
    }

    private func newSelection() {
        if let map = self.map {
            GameEngine.Instance.updateInfoPanel()
            GameEngine.Instance.playUnitSound(map.selected!)
        }
    }

    override func touchesMoved(touches: Set<NSObject>, withEvent event: UIEvent) {
        self.moved = true
        let touch = touches.first as! UITouch
        let current = touch.locationInNode(self)
        let prev = touch.previousLocationInNode(self)

        let translation = CGPoint(x: current.x - prev.x, y: current.y - prev.y)

        map?.scroll(translation)
    }

    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
    }
}
