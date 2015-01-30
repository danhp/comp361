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
    
    func testNeighbor() {
        let a : [[Tile]] = [
            [Tile(coordinates: (0,0)), Tile(coordinates: (1,0)), Tile(coordinates: (2,0)), Tile(coordinates: (3,0)), Tile(coordinates: (4,0)), Tile(coordinates: (5,0))],
            [Tile(coordinates: (0,1)), Tile(coordinates: (1,1)), Tile(coordinates: (2,1)), Tile(coordinates: (3,1)), Tile(coordinates: (4,1)), Tile(coordinates: (5,1))],
            [Tile(coordinates: (-1,2)), Tile(coordinates: (0,2)), Tile(coordinates: (1,2)), Tile(coordinates: (2,2)), Tile(coordinates: (3,2)), Tile(coordinates: (4,2))],
            [Tile(coordinates: (-1,3)), Tile(coordinates: (0,3)), Tile(coordinates: (1,3)), Tile(coordinates: (2,3)), Tile(coordinates: (3,3)), Tile(coordinates: (4,3))],
            [Tile(coordinates: (-2,4)), Tile(coordinates: (-1,4)), Tile(coordinates: (0,4)), Tile(coordinates: (1,4)), Tile(coordinates: (2,4)), Tile(coordinates: (3,4))],
            [Tile(coordinates: (-2,5)), Tile(coordinates: (-1,5)), Tile(coordinates: (0,5)), Tile(coordinates: (1,5)), Tile(coordinates: (2,5)), Tile(coordinates: (3,5))]]
        
        let map = Map(array: a)
        
        // Looking for neighbors of (1,1)
        let neighborTiles = [(1,0),(2,0), (2,1), (1,2), (0,2), (0,1)]
        let result = map.neighbors(x: 1, y: 1)
        
        var count = 0
        for n in neighborTiles {
            for r in result {
                if r.coordinates.0 == n.0 && r.coordinates.1 == n.1 {
                    count++
                }
            }
        }
        
        XCTAssertEqual(neighborTiles.count, count)
    }
}
