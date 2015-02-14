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
	
	subscript(x: Int, y: Int) -> Tile? {
		get {
            let j = x+y/2
            if y >= 0 && y < self.width && j >= 0 && j < self.height {
                return self.rows[y][j]
            } else {
                return nil
            }
		}
        set {
            self.rows[y][x+y/2] = newValue!
        }
	}
	
    init() {
        var array = [[Tile]]()
        for row in 0..<Constants.Map.dimension {
            array.append(Array<Tile>())
            for column in 0..<Constants.Map.dimension {
                array[row].append(Tile(coordinates: Utilities.arrayToAxialCoordinates(row: row, col: column), landType: Constants.Types.Land.Grass))
            }
        }
        
        self.rows = array
    }
    
	init(hexGrid grid: HexGrid) {
		self.rows = grid.rows
	}
	
	init(array: [[Tile]]) {
		self.rows = array
	}
}
