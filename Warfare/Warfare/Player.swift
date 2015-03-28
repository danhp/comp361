//
//  Player.swift
//  Warfare
//
//  Created by Justin Domingue on 2015-02-07.
//  Copyright (c) 2015 Justin Domingue. All rights reserved.
//

import Foundation
import GameKit

class Player {
    var order: Int!

    var villages: [Village] = [Village]() {
        didSet {
            if self.villages.count == 0 {
                MatchHelper.sharedInstance().removeParticipant(self.order)
            }
        }
    }
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
        self.villages = self.villages.filter({$0 !== toRemove})
    }

    // MARK - Serialization

    func serialize() -> NSDictionary {
        return ["order":self.order, "villages":self.villages.map({$0.serialize()})]
    }

    func deserialize(dict: NSDictionary) {
        self.order = dict["order"] as? Int ?? 0

        // VILLAGES
        if let villages = dict["villages"] as? NSArray {
            for v in villages { // v is NSDictionary
                self.villages.append(Village(dict: v as NSDictionary, owner: self))
            }
        }
    }
}
