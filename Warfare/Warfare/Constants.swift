//
//  Constants.swift
//  warfare
//
//  Created by Justin Domingue on 2015-01-21.
//  Copyright (c) 2015 Justin Domingue. All rights reserved.
//

import Darwin

struct Constants {
	
	struct Map {
		static let dimension = 18	// 18x18 maps
	}
	
	struct Tile {
		static let size = 50	// Distance from center to a corner
	}
	
	struct Types {
		 enum Land {
			case Grass, Tree, Meadow, Sea
            
            static func random() -> Land {
                switch arc4random_uniform(14) {
                case 0...2:
                    return .Tree
                case 3...4:
                    return .Meadow
                case 5: Sea
                    return .Sea
                default:
                    return .Grass
                }
            }
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

	struct Cost {
		enum Upgrade: Int {
			case Village = 8, Unit = 10
		}
	}
}