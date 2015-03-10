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
    var playerOrder: [Int]
    var currentPlayer: Player { return self.players[self.playerOrder[0]] }
  
    let map = Map()
    var neutralTiles = [Tile]()
    
    var isCurrentPlayer: Bool { return GKLocalPlayer.localPlayer().playerID == MatchHelper.sharedInstance().myMatch?.currentParticipant.playerID}

    var currentPlayerGold: Int { return self.currentPlayer.gold }
    var currentPlayerWood: Int { return self.currentPlayer.wood }

    init(players: [Player], playerOrder: [Int], map: Map) {
        self.players = players
        self.playerOrder = playerOrder
        self.map = map
    }

    init() {
        self.playerOrder = [Int](count: 3, repeatedValue: 0)
    }
    
    func importData(data: NSData) {
        if let dict = self.decode(data) {
            self.deserialize(dict)
        } else {
            println("Error while decoding match data")
        }
    }

    // MARK: - Operations

    // Set up the gameState after which the player can start giving out orders
    func beginTurn() {
        for village in currentPlayer.villages {
            for tile in village.controlledTiles {

                // Replace tombstones
                tile.replaceTombstone()

                // Produce constructions and set unit actions.
                // ReadyForOrders for all except first phase cultivation
                if tile.unit?.currentAction == Constants.Unit.Action.StartCultivating {
                    tile.unit?.currentAction = Constants.Unit.Action.FinishCultivating
                } else {
                    if tile.unit?.currentAction == Constants.Unit.Action.FinishCultivating {
                        tile.land = .Meadow
                    } else if tile.unit?.currentAction == Constants.Unit.Action.BuildingRoad {
                        tile.structure = .Road
                    }
                    tile.unit?.currentAction = Constants.Unit.Action.ReadyForOrders
                }

                // Add gold value to village.
                village.gold += tile.goldValue()

                // Payout wages
                village.gold += tile.wage()
            }

            // Delete the Village
            if village.gold <= 0 {
                self.currentPlayer.clearVillages(village)
            }
        }
    }

    // Set the turn to the next player.
    func endTurn() {
        // TODO check if player outcome is none
        let tmp = self.playerOrder[0]
        self.playerOrder[0] = self.playerOrder[1]
        self.playerOrder[1] = self.playerOrder[2]
        self.playerOrder[2] = tmp
    }

    // Move a unit and update all affected tiles in path.
    func moveUnit(from: Tile, to: Tile) {
        if from.unit?.currentAction != Constants.Unit.Action.ReadyForOrders { return }

        var path = [Tile]()
        var enemyPlayer: Player?
        var enemyVillage: Village?

        for village in currentPlayer.villages {
            if contains(village.controlledTiles, { $0 === from }) {
                // Knight cannot clear tiles
                if (from.unit?.type)! == Constants.Types.Unit.Knight
                    && (to.land! == .Tree || to.structure? == Constants.Types.Structure.Tombstone) { return }

                // Check if path exists.
                // If to is in controlledTiles, find path normally
                // Else find path to one of its neighbours that must be a controlledTile
                if contains(village.controlledTiles, { $0 === to }) {
                    path = map.getPath(from: from, to: to, accessible: village.controlledTiles)

                    // Cannot destroy onject within controlled region.
                    if to.unit != nil || to.village != nil || to.structure == .Tower { return }
                } else {
                    for n in map.neighbors(tile: to) {
                        if contains(village.controlledTiles, { $0 === n }) {
                            path = map.getPath(from: from, to: n, accessible: village.controlledTiles)
                            if !path.isEmpty { break }
                        }
                    }
                }
                if path.isEmpty { return }

                // Execute if tile is outside controlled region
                if !contains(village.controlledTiles, {$0 === to}) {
                    //Check if tile in unprotected
                    if to.isProtected(from.unit!) { return }
                    for n in map.neighbors(tile: to) {
                        // TODO: hackish temp fix
                        var a: Bool = false
                        for v in self.currentPlayer.villages {
                            if contains(v.controlledTiles, {$0 === n}) {
                                a = true
                                break
                            }
                        }

                        if !a && n.isProtected(from.unit!) { return }
                    }

                    // Find player and village for to tile.
                    // nil if tile is neutral
                    for p in self.players {
                        if p === self.currentPlayer { continue }
                        for v in p.villages {
                            if contains(v.controlledTiles, { $0 === to }) {
                                // Peasant can only invade neutral
                                if from.unit?.type == Constants.Types.Unit.Peasant { return }

                                enemyPlayer = p
                                enemyVillage = v
                                break
                            }
                        }
                    }

                    if enemyPlayer == nil {
                        // TakeOver neutral tile
                        village.addTile(to)

                        // Check if regions join.
                        var mainVillage: Village = village
                        var mergedVillage: Village = Village()

                        for n in self.map.neighbors(tile: to) {
                            for v in self.currentPlayer.villages {
                                if v === mainVillage || v === village { continue }
                                if contains(v.controlledTiles, {$0 === n}) {
                                    if mainVillage.compareTo(v) {
                                        mergedVillage = v
                                    } else {
                                        mergedVillage = mainVillage
                                        mainVillage = v
                                    }

                                    mainVillage.wood += mergedVillage.wood
                                    mainVillage.gold += mergedVillage.gold

                                    for t in mergedVillage.controlledTiles {
                                        mainVillage.addTile(t)
                                        t.village = nil
                                    }
                                    self.currentPlayer.removeVillage(mergedVillage)
                                }
                            }
                        }
                    } else {
                        // Peasant and infantry cannot invade a village
                        // Soldiers cannot invade a fort.
                        if to.village != nil && from.unit?.type.rawValue < 3
                            || from.unit?.type.rawValue == 3 && to.village?.rawValue == 3 { return }


                        // Invade enemy tile
                        village.addTile(to)
                        enemyVillage?.removeTile(to)

                        let regions = self.map.getRegions((enemyVillage?.controlledTiles)!)

                        // Update destination tile.
                        to.unit = nil
                        to.structure = nil
                        if to.village != nil {
                            village.wood += (to.owner?.wood)!
                            village.gold += (to.owner?.gold)!
                            to.village = nil
                            enemyPlayer?.removeVillage(enemyVillage!)
                        }


                        for r in regions {
                            // Region is too small
                            if r.count < 3 {
                                for t in r {
                                    t.structure = nil
                                    if t.unit != nil {
                                        t.structure = Constants.Types.Structure.Tombstone
                                    }
                                    t.unit = nil
                                    enemyVillage?.removeTile(t)
                                    if t.village != nil {
                                        enemyPlayer?.removeVillage(t.owner!)
                                        t.village = nil
                                    }
                                }
                                continue
                            }

                            // Region can still support a village.
                            if map.getVillage(r) == nil {
                                let newHovel = Village()
                                for t in r {
                                    newHovel.addTile(t)
                                    enemyVillage?.removeTile(t)
                                }

                                enemyPlayer?.addVillage(newHovel)

                                // TODO: Actually place it somewhere legal.
                                r[0].land = .Grass
                                r[0].unit = nil
                                r[0].structure = nil
                                r[0].owner = newHovel
                            }

                        }
                    }
                }

                // Update tiles in path
                path.append(to)
                for tile in path {
                    if (from.unit?.type == Constants.Types.Unit.Knight || from.unit?.type == Constants.Types.Unit.Soldier)
                        && tile.land == .Meadow
                        && tile.structure != .Road {
                            tile.land = .Grass
                    }
                }

                // Update destination tile.
                if to.structure? == Constants.Types.Structure.Tombstone {
                    to.structure = nil
                }
                if to.land == .Tree {
                    to.land = .Grass
                    village.wood += 1
                }

                // Move the unit
                //from.unit?.currentAction = Constants.Unit.Action.Moved
                to.unit = from.unit
                from.unit = nil
                from.update()
                to.update()

                // Completed operations
                return
            }
        }
    }

    func upgradeVillage(village: Village) {
        if !contains(self.currentPlayer.villages, {$0 === village}) { return }

        village.upgradeVillage()
    }

    func upgradeUnit(unit: Unit, newLevel: Constants.Types.Unit) {
        for village in self.currentPlayer.villages {
            if village.containsUnit(unit) {
                village.upgradeUnit(unit, newType: newLevel)
                return
            }
        }
    }

    func combineUnit(tileA: Tile, tileB: Tile) {
        for village in self.currentPlayer.villages {
            if contains(village.controlledTiles, {$0 === tileA}) { return }
            if contains(village.controlledTiles, {$0 === tileB}) { return }

            tileA.unit?.combine(tileB.unit!)
            tileB.unit = nil
        }
    }

    func recruitUnit(village: Village, type: Constants.Types.Unit, tile: Tile) {
        if !contains(self.currentPlayer.villages, {$0 === village}) { return }

        // Hovel can only recruit peasants and infantry (rawVaue: 1 & 2)
        // Town can also recruit soldiers (rawValue: 3)
        // Fort can also recruit knight (rawValue: 4)
        if type.rawValue > village.type.rawValue + 1 { return }

        let cost = type.rawValue * Constants.Cost.Upgrade.Unit.rawValue
        if village.gold < cost || !tile.isWalkable() { return }

        village.gold -= cost

        var newUnit = Unit(type: type)
        newUnit.currentAction = .Moved
        tile.unit = newUnit
    }

    func buildTower(village: Village, on: Tile) {
        // Hovels cannot build Towers.
        if village.type == .Hovel { return }
        if !contains(self.currentPlayer.villages, {$0 === village}) { return }

        let tower = Constants.Types.Structure.Tower
        if village.wood < tower.cost() || !on.isBuildable() { return }

        village.wood -= tower.cost()
        on.structure = tower
    }

    // Moves unit from -> on, instruct unit to start building road.
    func buildRoad(on: Tile, from: Tile) {
        // TODO: Change with implementation of tile (loop)
        for village in self.currentPlayer.villages {
            // Check tiles are both in the same region and connected
            let path = self.map.getPath(from: from, to: on, accessible: village.controlledTiles)
            if path.isEmpty { continue }

            let road = Constants.Types.Structure.Road
            if village.wood < road.cost()
                || !on.isBuildable()
                || from.unit?.currentAction != Constants.Unit.Action.ReadyForOrders
                || from.unit?.type != Constants.Types.Unit.Peasant{ return }

            village.wood -= road.cost()
            on.unit = from.unit
            from.unit = nil
            on.unit?.currentAction = Constants.Unit.Action.BuildingRoad

            return
        }
    }

    // Moves unit from -> on, instruct unit to start creating meadow for 2 turns
    func startCultivating(on: Tile, from: Tile) {
        for village in self.currentPlayer.villages {
            // Check tiles are both in the same region and connected
            let path = self.map.getPath(from: from, to: on, accessible: village.controlledTiles)
            if path.isEmpty { continue }

            let cost = Constants.Types.Land.Meadow.cost()
            if village.wood < cost
                || !on.isBuildable()
                || from.unit?.currentAction != Constants.Unit.Action.ReadyForOrders
                || from.unit?.type != Constants.Types.Unit.Peasant{ return }

            village.wood -= cost
            on.unit = from.unit
            from.unit = nil
            on.unit?.currentAction = Constants.Unit.Action.StartCultivating

            return
        }
    }
    
    // MARK: - Encoding
    
    // Encodes the match data in a sendable format
    func encodeMatchData() -> NSData {
        let dict = self.serialize()
        var error:NSError?
        let matchData = NSJSONSerialization.dataWithJSONObject(dict, options:NSJSONWritingOptions(0), error: &error)
        return matchData!
    }

    // Encodes the player order in a sendable format
    func encodePlayerOrder() -> NSArray {
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

    // MARK: - Serialization
    
    // Populates the current Game with match data
    func deserialize(dict: NSDictionary) {
        // PLAYERS
        if let players = dict["players"] as? NSArray {
            for p in players {
                let p = Player(dict: p as NSDictionary)

                self.players.append(p)
                self.playerOrder.append(p.order)
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
