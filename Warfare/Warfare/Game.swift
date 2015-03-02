//
//  Game.swift
//  Warfare
//
//  Created by Justin Domingue on 2015-02-28.
//  Copyright (c) 2015 Justin Domingue. All rights reserved.
//

import Foundation
import GameKit

class Game {
    var players = [Player]()
    var playerOrder = [Int]()
    var currentPlayer: Player { return self.players[self.playerOrder[0]] }
    let map = Map()
    
    var isCurrentPlayer: Bool { return GKLocalPlayer.localPlayer().playerID == self.currentPlayer.id }
    
    init(initWithData data: NSData) {
        if let dict = self.decode(data) {
            self.deserialize(dict)
        } else {
            println("Error while decoding match data")
        }
    }
    
    // MARK: - Operations
    
    func beginTurn() {
        
        for village in self.currentPlayer.villages {
            for tile in village.controlledTiles {
                
                // Replace tombstones
                tile.replaceTombstone()
                
                // Produce constructions
                if tile.makeRoadOrMeadow() {
                    // Add a new meadow
                    // TODO
                }
                
                // Add gold value to village.
                village.gold += tile.goldValue()
                
                // Payout wages
                village.gold += tile.wage()
            }
            
            // Delete the Village
            if village.gold <= 0 {
                self.currentPlayer.removeVillages(village)
            }
        }
    }
    
    // Mark: - Encoding
    
    // Encodes the match data in a sendable format
    func encodeMatchData() -> NSData {
        let dict = self.serialize()
        let matchData = NSJSONSerialization.dataWithJSONObject(dict, options: nil, error: nil)
        return matchData!
    }
    
    // Encodes the player order in a sendable format
    func encodePlayerOrder() -> NSArray {
        // TODO check if player outcome is none
        self.playerOrder[0] = self.playerOrder[1]
        self.playerOrder[1] = self.playerOrder[2]
        self.playerOrder[2] = self.playerOrder[0]
        return NSArray(array: self.playerOrder)
    }
    
    // Get relevant message for turn
    func matchTurnMessage() -> String {
        // TODO
        return ""
    }
    
    // Decodes match data into a dictionary
    func decode(data: NSData) -> NSDictionary? {
        var parseError: NSError?
        let parsedObject: AnyObject? = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.AllowFragments, error: &parseError)
        
        return parsedObject as? NSDictionary
    }

    
    // Mark: - Serialization
    
    // Populates the current Game with match data
    func deserialize(dict: NSDictionary) {
        // PLAYERS
        if let players = dict["players"] as? NSArray {
            for p in players {
                self.players.append(Player(dict: p as NSDictionary, turn: 1))
            }
        }
        
        // NEUTRAL TILES
        if let neutral = dict["neutral"] as? NSArray {
            for t in neutral {  // t is an NSDictionary
                let t = Tile(dict: t as NSDictionary, village: nil)
                //                            self.map.setTile(at: t.coordinates, to: t)
            }
        }
    }
    
    // Serializes the current game
    func serialize() -> NSDictionary {
        var dict = [String: AnyObject]()
        
        dict["players"] = self.players.map({$0.serialize()})
        dict["neutral"] = ""
        
        return dict
    }
    
}