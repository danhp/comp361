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
   let tiles = [[Tile]]()
	
	override init() {
		super.init()
		
		let d = Constants.Map.dimension

		tiles = Array<Array<Tile>>()
		for column in 0..<d {
			tiles.append(Array<Tile>())
			for row in 0..<d {
				tiles[column].append(Tile(landType: Constants.Types.LandType.Grass))
			}
		}
	}
	
	func draw() {
		let height = Constants.Tile.size * 2
		let width = sqrt(3)/2.0 * Double(height)
		
		let vert = height * 3/4
		let horiz = width
		
		// Go column by column
		for (j, column) in enumerate(tiles) {
			let x_offset = j % 2 == 0 ? 0 : width/2

			// Add the tiles for the current row.
			for (i, tile) in enumerate(column) {
				
				let tile = tiles[i][j]
				tile.position = CGPointMake(CGFloat(Double(x_offset)+Double(i)*horiz), CGFloat(j*vert))
				
				self.addChild(tile)
			}
		}
	}

	required init?(coder aDecoder: NSCoder) {
	    fatalError("init(coder:) has not been implemented")
	}
}
