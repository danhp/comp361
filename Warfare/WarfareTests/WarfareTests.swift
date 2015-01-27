//
//  warfareTests.swift
//  warfareTests
//
//  Created by Justin Domingue on 2015-01-21.
//  Copyright (c) 2015 Justin Domingue. All rights reserved.
//

import UIKit
import XCTest

class warfareTests: XCTestCase {
    var grid = HexGrid()
    
    class TileWithIndices : Tile {
        let indices : [Int]
        
        init(_ i: Int, _ j: Int) {
            self.indices = [i,j]
            
            super.init()
        }
        
        required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        let a : [[Tile]] = [
            [TileWithIndices(0,0), TileWithIndices(0,1), TileWithIndices(2,0), TileWithIndices(3,0), TileWithIndices(4,0), TileWithIndices(5,0)],
            [TileWithIndices(0,1), TileWithIndices(1,1), TileWithIndices(2,1), TileWithIndices(3,1), TileWithIndices(4,1), TileWithIndices(5,1)],
            [TileWithIndices(-1,2), TileWithIndices(0,2), TileWithIndices(1,2), TileWithIndices(2,2), TileWithIndices(3,2), TileWithIndices(4,2)],
            [TileWithIndices(-1,3), TileWithIndices(0,3), TileWithIndices(1,3), TileWithIndices(2,3), TileWithIndices(3,3), TileWithIndices(4,3)],
            [TileWithIndices(-2,4), TileWithIndices(-1,4), TileWithIndices(0,4), TileWithIndices(1,4), TileWithIndices(2,4), TileWithIndices(3,4)],
            [TileWithIndices(-2,5), TileWithIndices(-1,5), TileWithIndices(0,5), TileWithIndices(1,5), TileWithIndices(2,5), TileWithIndices(3,5)]]
        
        grid = HexGrid(array: a)
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testSubscript() {
        XCTAssertEqual([0,1], (grid[0,1] as TileWithIndices).indices)
        XCTAssertEqual([-1,2], (grid[-1,2] as TileWithIndices).indices)
    }
    
    func testOffsetToAxial() {
        let offsetCoordinate = (row: 4, col: 1)
        XCTAssertEqual(-1, HexGrid.offsetToAxial(row: offsetCoordinate.row, col: offsetCoordinate.col).x)
        XCTAssertEqual(4, HexGrid.offsetToAxial(row: offsetCoordinate.row, col: offsetCoordinate.col).y)
    }
}
