//
//  HexGrid.swift
//  warfare
//
//  Created by Justin Domingue on 2015-01-23.
//  Copyright (c) 2015 Justin Domingue. All rights reserved.
//

import Foundation

class HexGrid {
	var width: Int { return rows[0].count }
	var height: Int { return rows.count }
	var size: Int { return width * 2 }
	var rows: [[Tile]]
	
	subscript(x: Int, y: Int) -> Tile {
		get {
			return self.rows[y][x+y/2]
		}
	}
    
    class func offsetToAxial(#row: Int, col: Int) -> (x: Int, y: Int) {
        return (col - (row-(row&1)) / 2, row)
    }
	
    init() {
        self.rows = []
    }
    
	init(hexGrid grid: HexGrid) {
		self.rows = grid.rows
	}
	
	init(array: [[Tile]]) {
		self.rows = array
	}
}
