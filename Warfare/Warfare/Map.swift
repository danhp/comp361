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
    
    var selected: Tile? {
        willSet {
            // Deselect previous tile
            self.selected?.selected = false
            
            // Select new tile
            newValue?.selected = true
        }
    }

    override init() {
        self.tiles = HexGrid()
        
        super.init()
        
        initalizeScroller()
    }
    
    init(array: [[Tile]]) {
		self.tiles = HexGrid(array: array)

        super.init()
        
        initalizeScroller()
	}
    
    func initalizeScroller() {
        self.addChild(scroller)
    }
    
    
    // Helper for deserialization
    func setTile(#at: (Int, Int), to: Tile) {
        self.tiles[at.0, at.1] = to
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

    // Get the set of tiles in the shortest path
    // @return [Tile] if path exists, else return empty set.
    func getPath(#from: Tile, to: Tile, accessible: [Tile]) -> [Tile] {
        var queue = [Tile]()
        var seen = [Tile]()
        var cameFrom = [Tile: Tile]()

        // Conditions to walk on a tile:
        //      1 - Tile is owned by Village
        //      2 - Tile is empty

        queue.append(from)
        seen.append(from)

        while !queue.isEmpty {
            let tile = queue.removeLast()

            // Visit the tile
            if tile == to {
                var current = to
                var finalPath = [Tile]()
                finalPath.append(current)

                while current != from {
                    current = cameFrom[current]!
                    finalPath.append(current)
                }

                return finalPath
            }

            // Add unvisited neighbors to the queue
            for t in neighbors(tile: tile) {
                if t.isWalkable() && contains(accessible, { $0 === t }) && !contains(seen, {$0 === t})
                            || (t === to  && t.land != .Sea) {
                    queue += [t]
                    cameFrom[t] = tile
                }
                seen += [t]
            }
        }

        var empty = [Tile]()
        return empty
    }

    // Split a set of unconnected regions into sets of connected regions
    // @returns [[Tile]] made up of at most 3 sets of connected regions.
    func getRegions(tileSet: [Tile]) -> [[Tile]] {
        var tileSetCopy = tileSet
        var seen = [Tile]()
        var queue = [Tile]()

        var regions = [[Tile]]()
        var group = [Tile]()

        while !tileSetCopy.isEmpty {
            var seed = tileSetCopy.removeLast()
            seen.append(seed)
            queue.append(seed)

            while !queue.isEmpty {
                let tile = queue.removeLast()

                // Visit the tile
                group.append(tile)
                tileSetCopy = tileSetCopy.filter({$0 !== tile})

                // Visit the neighbours
                for t in neighbors(tile: tile) {
                    if contains(tileSet, {$0 === t}) && !contains(seen, {$0 === t}) {
                        queue.append(t)
                    }
                    seen.append(t)
                }
            }
            regions.append(group)
            group = [Tile]()
        }
        return regions
    }

    func getVillage(region: [Tile]) -> Village? {
        for tile in region {
            if tile.owner != nil {
                return tile.owner
            }
        }
        return nil
    }

	func draw() {
		let height = Constants.Tile.size * 2
		let width = sqrt(3)/2.0 * Double(height)
		let vert = height * 3/4
		let horiz = width

        self.scroller.removeAllChildren()
        
		// Go row by row
		for (i, row) in enumerate(self.tiles.rows) {
			let x_offset = i % 2 == 0 ? 0 : width/2

			// Add the tiles for the current row.
			for (j, tile) in enumerate(row) {

				let coord = Utilities.arrayToAxialCoordinates(row: i, col: j)
				let tile = tiles[coord.x, coord.y]!
				tile.draw()
				tile.position = CGPointMake(CGFloat(Double(x_offset)+Double(j)*horiz), -CGFloat(i*vert))

//				let s:String = coord.x.description + "," + coord.y.description
//				let label = SKLabelNode(text: s)
//				tile.addChild(label)
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