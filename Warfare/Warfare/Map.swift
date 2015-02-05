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

	init(array: [[Tile]]) {
		tiles = HexGrid(array: array)

		super.init()

		// Initialize scroller node
		scroller = SKNode()
		self.addChild(scroller)
	}

	func neighbors(#tile: Tile) -> [Tile] {
		return neighbors(x: tile.coordinates.0, y: tile.coordinates.1)
	}

	func neighbors(#x: Int, y: Int) -> [Tile] {
		var neighbors = [Tile]()

		let directions: [[Int]] = [
			[+1,  0], [+1, -1], [ 0, -1],
			[-1,  0], [-1, +1], [ 0, +1]
		]

		for i in 0..<directions.count {
			let d = directions[i]

			if let t = self.tiles[x+d[1],y+d[0]] {
				neighbors.append(t)
			}
		}

		return neighbors
	}

	func pathExists(#from: Tile, to: Tile) -> Bool {
		var queue = [Tile]()
		var seen = [Tile]()

		// Conditions to walk on a tile:
		//      1 - Tile is owned by Village
		//      2 - Tile is empty

		queue.append(from)
		seen.append(from)

		while !queue.isEmpty {
			let tile = queue.removeLast()

			// Visit the tile
			if tile.coordinates.0 == to.coordinates.0 && tile.coordinates.1 == to.coordinates.1 {
				return true
			}

			// Add unvisited neighbors to the queue
			for t in neighbors(tile: tile) {
				if t.isWalkable() && !contains(seen, {$0 === t}) {
					queue += [t]
				}
				seen += [t]
			}
		}

		return false
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

				let coord = Utilities.arrayToAxialCoordinates(row: i, col: j)
				let tile = tiles[coord.x, coord.y]!
				tile.position = CGPointMake(CGFloat(Double(x_offset)+Double(j)*horiz), -CGFloat(i*vert))

				let s:String = coord.x.description + "," + coord.y.description
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