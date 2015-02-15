//
//  Player.swift
//  Warfare
//
//  Created by Justin Domingue on 2015-02-07.
//  Copyright (c) 2015 Justin Domingue. All rights reserved.
//

import Foundation

class Player {
    var id: Int?
    
    var villages = [Village]()
    var gold: Int { return self.villages.reduce(0) {$0 + $1.gold} }
    var wood: Int { return self.villages.reduce(0) {$0 + $1.wood} }
    
    init() {}
    
    init(dict: NSDictionary) {
        self.deserialize(dict)
    }
    
    // MARK: - Actions
    
    /// Removes village v from the list of villages
    /// and removes the unit or structures from the
    /// region controlled by that village
    func clearVillages(to_delete: Village) {
        to_delete.clearRegion()
        
        // Find object in array
        for (i, village) in enumerate(self.villages) {
            if to_delete === village {
                self.villages.removeAtIndex(i)
                break
            }
        }
    }

	func addVillage(toAdd: Village) {
		toAdd.player = self
		self.villages.append(toAdd)
	}

	func removeVillage(toRemove: Village) {
		self.villages.filter({$0 !== toRemove})
	}
    
    // MARK - Serialization
    
    func serialize() -> NSDictionary {
        return ["id":self.id!, "villages":self.villages.map({$0.serialize()})]
    }
    
    func deserialize(dict: NSDictionary) {
        self.id = dict["id"] as? Int
        
        // VILLAGES
        if let villages = dict["villages"] as? NSArray {
            for v in villages { // v is NSDictionary
                self.villages.append(Village(dict: v as NSDictionary, owner: self))
            }
        }
    }
}