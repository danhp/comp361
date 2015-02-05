//
//  mapTests.swift
//  Map
//
//  Created by Justin Domingue on 2015-01-27.
//  Copyright (c) 2015 Justin Domingue. All rights reserved.
//

import UIKit
import XCTest

class mapTests: XCTestCase {
	var map = Map(array: [])

	override func setUp() {
		super.setUp()

		let a : [[Tile]] = [
			[Tile(coordinates: (0,0)), Tile(coordinates: (1,0)), Tile(coordinates: (2,0)), Tile(coordinates: (3,0)), Tile(coordinates: (4,0)), Tile(coordinates: (5,0))],
			[Tile(coordinates: (0,1)), Tile(coordinates: (1,1)), Tile(coordinates: (2,1)), Tile(coordinates: (3,1)), Tile(coordinates: (4,1)), Tile(coordinates: (5,1))],
			[Tile(coordinates: (-1,2)), Tile(coordinates: (0,2)), Tile(coordinates: (1,2)), Tile(coordinates: (2,2)), Tile(coordinates: (3,2)), Tile(coordinates: (4,2))],
			[Tile(coordinates: (-1,3)), Tile(coordinates: (0,3)), Tile(coordinates: (1,3)), Tile(coordinates: (2,3)), Tile(coordinates: (3,3)), Tile(coordinates: (4,3))],
			[Tile(coordinates: (-2,4)), Tile(coordinates: (-1,4)), Tile(coordinates: (0,4)), Tile(coordinates: (1,4)), Tile(coordinates: (2,4)), Tile(coordinates: (3,4))],
			[Tile(coordinates: (-2,5)), Tile(coordinates: (-1,5)), Tile(coordinates: (0,5)), Tile(coordinates: (1,5)), Tile(coordinates: (2,5)), Tile(coordinates: (3,5))]]

		map = Map(array: a)
	}

	func testNeighbor() {
		// Looking for neighbors of (1,1)
		var neighborTiles = [(1,0),(2,0), (2,1), (1,2), (0,2), (0,1)]
		var result = map.neighbors(x: 1, y: 1)

		var count = 0
		for n in neighborTiles {
			for r in result {
				if r.coordinates.0 == n.0 && r.coordinates.1 == n.1 {
					count++
				}
			}
		}

		XCTAssertEqual(neighborTiles.count, count)

		// Looking for neighbors of (0,0)
		neighborTiles = [(1,0),(0,1)]
		result = map.neighbors(x: 0, y: 0)

		count = 0
		for n in neighborTiles {
			for r in result {
				if r.coordinates.0 == n.0 && r.coordinates.1 == n.1 {
					count++
				}
			}
		}

		XCTAssertEqual(neighborTiles.count, count)
	}

	func testPathExists() {
		let tiles = map.tiles

		// Add obstacles to grid
		let tiles_with_obstacles = [
			(1,0),(2,0),(3,0),(4,0),(5,0),
			(1,1),(0,2),(0,3),
			(-1,4),(0,4),(1,4),(2,4),(3,4)]

		for t in tiles_with_obstacles {
			tiles[t.0, t.1]!.land = .Tree
		}

		let from = tiles[0,0]!
		let to = tiles[3,5]!

		XCTAssertTrue(map.pathExists(from: from, to: to))

		tiles[2,5]!.land = .Tree

		XCTAssertFalse(map.pathExists(from: from, to: to))

	}
}