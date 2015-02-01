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
    
    func neighbords(#tile: Tile) -> [Tile] {
        return neighbors(x: tile.coordinates.0, y: tile.coordinates.1)
    }
    
    func neighbors(#x: Int, y: Int) -> [Tile] {
        var neighbors = [Tile]()
        
        let directions: [[Int]] = [
            [+1,  0], [+1, -1], [ 0, -1],
            [-1,  0], [-1, +1], [ 0, +1]
        ]
        
        for i in 0...5 {
            let d = directions[i]
            neighbors.append(self.tiles[y+d[0],x+d[1]])
        }
        
        return neighbors
    }
    
//    func path(from: Tile, to: Tile) -> [Tile] {
//        class Path {
//            var total: Int!
//            var destination: Vertex
//            var previous: Path!
//            
//            init() { destination = Tile() }
//        }
//            
//        var path = [Tile]()
//        
//        var queue = [Tile]()
//        var dist = [from: 0]
//        
//        // Conditions to walk on a tile:
//        //      1 - Tile is owned by Village
//        //      2 - Tile is empty
//        
//        queue.append(from)
//        
//        while !queue.isEmpty {
//            var tile = queue.removeLast()
//            
//            // Add unvisited neighbors to the queue
//            for n in neighbors(tile: n) {
//                if n.
//            }
//        }
//        
//        return path
//    }
	
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
                let tile = tiles[coord.x, coord.y]
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
