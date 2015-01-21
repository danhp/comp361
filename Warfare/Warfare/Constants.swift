//
//  Constants.swift
//  warfare
//
//  Created by Justin Domingue on 2015-01-21.
//  Copyright (c) 2015 Justin Domingue. All rights reserved.
//

struct Constants {
	struct Tile {
		static let size = 50	// Distance from center to a corner
	}
	
	struct Types {
		 enum Land {
			case Sea, Grass, Tree, Meadow
		}
		
		enum Village {
			case Hovel, Town, Fort
		}
		
		enum Unit {
			case Peasant, Infantry, Soldier, Knight
		}
		
		enum Structure {
			case Tower, Road, Tombstone
		}
	}
}