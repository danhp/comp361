//
//  Player.swift
//  Warfare
//
//  Created by Justin Domingue on 2015-02-07.
//  Copyright (c) 2015 Justin Domingue. All rights reserved.
//

import Foundation

class Player {
    var villages = [Village]()
    
    init() { }
    
    init(dict: NSDictionary) {
        self.deserialize(dict)
    }
    
    /// Removes village v from the list of villages
    /// and removes the unit or structures from the
    /// region controlled by that village
    func removeVillages(to_delete: Village) {
        to_delete.clearRegion()
        
        // Find object in array
        for (i, village) in enumerate(self.villages) {
            if to_delete.position == village.position {
                self.villages.removeAtIndex(i)
                break
            }
        }
    }
    
    // MARK - Serialization
    
    func serialize() -> NSDictionary {
        return ["villages":self.villages.map({$0.serialize()})]
    }
    
    func deserialize(dict: NSDictionary) {
        if let name = dict["name"] as? String {
            // Do something with the name
        }
        
        // VILLAGES
        if let villages = dict["villages"] as? NSArray {
            for v in villages { // v is NSDictionary
                self.villages.append(Village(dict: v as NSDictionary))
            }
        }
    }
}