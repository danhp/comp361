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
		static let size = 30	// Distance from center to a corner
	}
	
	struct Types {
		 enum LandType {
			case Sea, Grass, Tree, Meadow
		}
		
		enum VillageType {
			case Hovel, Town, Fort
		}
		
		enum UnitType {
			case Peasant, Infantry, Soldier, Knight
		}
		
		enum StructureType {
			case Tower, Road, Tombstone
		}
	}
}