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
    var currentPlayer: Player { return self.players[MatchHelper.sharedInstance().currentParticipantIndex()] }
    var localPlayer: Player { return self.players[MatchHelper.sharedInstance().localParticipantIndex()] }

    let map = Map()
    var neutralTiles = [Tile]()

    var localIsCurrentPlayer: Bool { return GKLocalPlayer.localPlayer().playerID == MatchHelper.sharedInstance().myMatch?.currentParticipant.playerID}

    var currentPlayerGold: Int { return self.currentPlayer.gold }
    var currentPlayerWood: Int { return self.currentPlayer.wood }

    init(players: [Player], map: Map) {
        self.players = players
        self.map = map
    }

    init() { }

    func importDictionary(dict: NSDictionary) {
        self.deserialize(dict)
    }

    // MARK: - Encoding

    // Encodes the match data in a sendable format
    func encodeMatchData() -> NSData {
        let dict = self.serialize()
        var error:NSError?
        let matchData = NSJSONSerialization.dataWithJSONObject(dict, options:NSJSONWritingOptions(0), error: &error)
        return matchData!
    }

    // Get relevant message for turn
    func matchTurnMessage() -> String {
        // TODO
        return ""
    }

    // MARK: - Serialization

    // Populates the current Game with match data
    func deserialize(dict: NSDictionary) {
        // PLAYERS
        if let players = dict["players"] as? NSArray {
            for p in players {
                let p = Player(dict: p as NSDictionary)
                self.players.append(p)
            }
        }

        // NEUTRAL TILES
        if let neutral = dict["neutral"] as? NSArray {
            for t in neutral {  // t is an NSDictionary
                let t = Tile(dict: t as NSDictionary)
                self.map.setTile(at: t.coordinates, to: t)
                self.neutralTiles.append(t)
            }
        }
    }

    // Serializes the current game
    func serialize() -> NSDictionary {
        var dict = [String: AnyObject]()

        dict["players"] = self.players.map({$0.serialize()})
        dict["neutral"] = self.neutralTiles.map({$0.serialize()})

        return dict
    }

    func toJSON(dict: NSDictionary) -> String {
        // Make JSON
        var error:NSError?
        var data = NSJSONSerialization.dataWithJSONObject(dict, options:NSJSONWritingOptions(0), error: &error)

        // Return as a String
        return NSString(data: data!, encoding: NSUTF8StringEncoding)!
    }

}
