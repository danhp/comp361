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
    var roundCount = 0
    var currentPlayer: Player { return self.players[MatchHelper.sharedInstance().currentParticipantIndex()] }
    var localPlayer: Player { return self.players[MatchHelper.sharedInstance().localParticipantIndex()] }

    let map = Map()
    var neutralTiles = [Tile]()

    var localIsCurrentPlayer: Bool {
        if !GameEngine.Instance.matchEnded {
            return GKLocalPlayer.localPlayer().playerID == MatchHelper.sharedInstance().myMatch?.currentParticipant.playerID
        } else {
            return false
        }
    }

    var nameOfActivePlayer: String {
        return GameEngine.Instance.matchEnded ? "Match Ended" : self.localIsCurrentPlayer ? "My turn" : ("Player " + String(MatchHelper.sharedInstance().currentParticipantIndex()) + "'s turn")
    }

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

       self.roundCount = dict["roundCount"] as? Int ?? 0
    }

    // Serializes the current game
    func serialize() -> NSDictionary {
        var dict = [String: AnyObject]()

        dict["roundCount"] = self.roundCount
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
