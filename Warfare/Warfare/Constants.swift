//
//  Constants.swift
//  warfare
//
//  Created by Justin Domingue on 2015-01-21.
//  Copyright (c) 2015 Justin Domingue. All rights reserved.
//

struct Constants {
	
	struct Map {
		static let dimension = 18	// 18x18 maps
	}
	
	struct Tile {
		static let size = 50	// Distance from center to a corner
	}
	
	struct Types {
		 enum Land {
			case Sea, Grass, Tree, Meadow
		}
		
		enum Village: Int {
			case Hovel = 1, Town, Fort
		}
		
		enum Unit: Int {
			case Peasant = 1, Infantry, Soldier, Knight
		}
		
		enum Structure {
			case Tower, Road, Tombstone
		}
    }
    
    struct Unit {
        enum Action { case Idle }
    }
}