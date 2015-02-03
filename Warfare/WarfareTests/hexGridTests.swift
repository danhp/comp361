//
//  hexGridTests.swift
//  hexGridTests
//
//  Created by Justin Domingue on 2015-01-21.
//  Copyright (c) 2015 Justin Domingue. All rights reserved.
//

import UIKit
import XCTest

class hexGridTests: XCTestCase {
    var grid = HexGrid()
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        let a : [[Tile]] = [
            [Tile(coordinates: (0,0)), Tile(coordinates: (1,0)), Tile(coordinates: (2,0)), Tile(coordinates: (3,0)), Tile(coordinates: (4,0)), Tile(coordinates: (5,0))],
            [Tile(coordinates: (0,1)), Tile(coordinates: (1,1)), Tile(coordinates: (2,1)), Tile(coordinates: (3,1)), Tile(coordinates: (4,1)), Tile(coordinates: (5,1))],
            [Tile(coordinates: (-1,2)), Tile(coordinates: (0,2)), Tile(coordinates: (1,2)), Tile(coordinates: (2,2)), Tile(coordinates: (3,2)), Tile(coordinates: (4,2))],
            [Tile(coordinates: (-1,3)), Tile(coordinates: (0,3)), Tile(coordinates: (1,3)), Tile(coordinates: (2,3)), Tile(coordinates: (3,3)), Tile(coordinates: (4,3))],
            [Tile(coordinates: (-2,4)), Tile(coordinates: (-1,4)), Tile(coordinates: (0,4)), Tile(coordinates: (1,4)), Tile(coordinates: (2,4)), Tile(coordinates: (3,4))],
            [Tile(coordinates: (-2,5)), Tile(coordinates: (-1,5)), Tile(coordinates: (0,5)), Tile(coordinates: (1,5)), Tile(coordinates: (2,5)), Tile(coordinates: (3,5))]]
        
        grid = HexGrid(array: a)
    }
    
    func testSubscript() {
        var (c1,c2) = grid[0,1]!.coordinates
        XCTAssertEqual(0, c1)
        XCTAssertEqual(1, c2)
        
        (c1,c2) = grid[-1,2]!.coordinates
        XCTAssertEqual(-1, c1)
        XCTAssertEqual(2, c2)
        
        (c1,c2) = grid[4,3]!.coordinates
        XCTAssertEqual(4, c1)
        XCTAssertEqual(3, c2)
        
        (c1,c2) = grid[-2,5]!.coordinates
        XCTAssertEqual(-2, c1)
        XCTAssertEqual(5, c2)
    }
    
    func testArrayToAxialCoordinates() {
        var arrayCoordinates = (row: 4, col: 1)
        var axialCoordinates = Utilities.arrayToAxialCoordinates(row: arrayCoordinates.row, col: arrayCoordinates.col)
        XCTAssertEqual(-1, axialCoordinates.x)
        XCTAssertEqual(4, axialCoordinates.y)
        
        arrayCoordinates = (row: 3, col: 5)
        axialCoordinates = Utilities.arrayToAxialCoordinates(row: arrayCoordinates.row, col: arrayCoordinates.col)
        XCTAssertEqual(4, axialCoordinates.x)
        XCTAssertEqual(3, axialCoordinates.y)
        
        arrayCoordinates = (row: 5, col: 0)
        axialCoordinates = Utilities.arrayToAxialCoordinates(row: arrayCoordinates.row, col: arrayCoordinates.col)
        XCTAssertEqual(-2, axialCoordinates.x)
        XCTAssertEqual(5, axialCoordinates.y)
    }
}
