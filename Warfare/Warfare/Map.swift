//
//  Map.swift
//  warfare
//
//  Created by Justin Domingue on 2015-01-21.
//  Copyright (c) 2015 Justin Domingue. All rights reserved.
//

import SpriteKit
import Darwin

class Map: SKNode {
	let tiles: HexGrid
	let scroller = SKNode()
	
	override init() {
        
		// Initialize tiles array
		var array = [[Tile]]()
		for row in 0..<Constants.Map.dimension {
			array.append(Array<Tile>())
			for column in 0..<Constants.Map.dimension {
				array[row].append(Tile())
			}
		}
        
		tiles = HexGrid(array: array)
		
		super.init()
		
		// Initialize scroller node
		scroller = SKNode()
		self.addChild(scroller)
	}
	
	func draw() {
		let height = Constants.Tile.size * 2
		let width = sqrt(3)/2.0 * Double(height)
		let vert = height * 3/4
		let horiz = width
		
		// Go row by row
        for (i, row) in enumerate(tiles.rows) {
			let x_offset = i % 2 == 0 ? 0 : width/2
			
			// Add the tiles for the current row.
			for (j, tile) in enumerate(row) {
				
				let tile = tiles.rows[i][j]
				tile.position = CGPointMake(CGFloat(Double(x_offset)+Double(j)*horiz), -CGFloat(i*vert))
                
                let index = HexGrid.offsetToAxial(row: i, col: j)
                let s:String = index.x.description + "," + index.y.description
				let label = SKLabelNode(text: s)
				tile.addChild(label)
				self.scroller.addChild(tile)
			}
		}
	}
	
	func scroll(delta: CGPoint) {
		scroller.position = CGPointMake(scroller.position.x + delta.x, scroller.position.y + delta.y)
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
}
