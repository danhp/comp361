//
//  HexGrid.swift
//  warfare
//
//  Created by Justin Domingue on 2015-01-23.
//  Copyright (c) 2015 Justin Domingue. All rights reserved.
//

import Foundation

class HexGrid<T> {
	var width: Int { return rows[0].count }
	var height: Int { return rows.count }
	var size: Int { return width * 2 }
	var rows: [[T]]
	
	subscript(x: Int, y: Int) -> T {
		get {
			return rows[y][x+y/2]
		}
		set {
			rows[y][x+y/2] = newValue
		}
	}
	
	init() {
		rows = []
	}
	
	init(hexGrid: HexGrid<T>) {
		rows = hexGrid.rows
	}
	
	init(array: Array<Array<T>>) {
		rows = array
	}
}
