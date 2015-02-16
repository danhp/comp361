import Foundation

private let _instance = GameEngine()

class GameEngine {
    var currentPlayer = Player()
    var players = [Player]()
    let map = Map()

    // MARK: Singleton

    class var Instance: GameEngine { return _instance }

    // MARK: - Initializers

    init() {   }

    init(firstPlayer: Int, players: [Player], map: Map) {
        assert(players.count == 3, "A Game should be between exactly 3 players.")

        self.currentPlayer = players[firstPlayer]
        self.players = players
        self.map = map
    }

    // MARK: - Serialization

    func loadMap(#number: String) {
        var e: NSError?
        if let path = NSBundle.mainBundle().pathForResource(number, ofType: "json") {
            if let json = NSString(contentsOfFile:path, encoding:NSUTF8StringEncoding, error:&e) {
                let data = (json as NSString).dataUsingEncoding(NSUTF8StringEncoding)
                var parseError: NSError?
                let parsedObject: AnyObject? = NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.AllowFragments, error: &parseError)

                if let top = parsedObject as? NSDictionary {

                    // PLAYERS
                    if let players = top["players"] as? NSArray {
                        for p in players {
                            self.players.append(Player(dict: p as NSDictionary))
                        }
                    }

                    // NEUTRAL TILES
                    if let neutral = top["neutral"] as? NSArray {
                        for t in neutral {  // t is an NSDictionary
                            let t = Tile(dict: t as NSDictionary, village: nil)
//                            self.map.setTile(at: t.coordinates, to: t)
                        }
                    }
                }
            }
        }
    }

    func serialize() -> NSDictionary {
        var dict = [String: AnyObject]()

        dict["players"] = self.players.map({$0.serialize()})
        dict["neutral"] = ""

        return dict
    }

    func toJSON(dict: NSDictionary) -> String {
        // Make JSON
        var error:NSError?
        var data = NSJSONSerialization.dataWithJSONObject(dict, options:NSJSONWritingOptions(0), error: &error)

        // Return as a String
        return NSString(data: data!, encoding: NSUTF8StringEncoding)!
    }

    // MARK: - Operations

    func beginTurn() {

        for village in currentPlayer.villages {
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
                self.currentPlayer.clearVillages(village)
            }
        }
    }

    // Move a unit and update all affected tiles in path.
    func moveUnit(from: Tile, to: Tile) {
        if from.unit?.currentAction != Constants.Unit.Action.ReadyForOrders { return }

        var path = [Tile]()
        var enemyPlayer: Player?
        var enemyVillage: Village?

        villageLoop: for village in currentPlayer.villages {
            if contains(village.controlledTiles, { $0 === from }) {
                // Knight cannot clear tiles
                if from.unit?.type == Constants.Types.Unit.Knight
                            && (to.land == .Tree || to.structure? == Constants.Types.Structure.Tombstone) { return }

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

                // Gather information if tile is external to controlled region
                if !contains(village.controlledTiles, {$0 === to}) {
                    //Check if tile in unprotected
                    if to.isProtected(from.unit!) { return }
                    for n in map.neighbors(tile: to) {
                        if n.isProtected(from.unit!) && !contains(village.controlledTiles, { $0 === n}) { return }
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
                }

                // Update tiles in path
                path.append(to)
                for tile in path {
                    if from.unit?.type == Constants.Types.Unit.Knight
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

                // Execute if tile is outside controlled region
                if !contains(village.controlledTiles, {$0 === to}) {
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
                        // Invade enemy tile
                        village.addTile(to)
                        enemyVillage?.removeTile(to)

                        let regions = self.map.getRegions((enemyVillage?.controlledTiles)!)

                        // Update destination tile.
                        to.unit = nil
                        to.structure = nil
                        if to.village != nil {
                            village.wood += (to.village?.wood)!
                            village.gold += (to.village?.gold)!
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
                                        enemyPlayer?.removeVillage(t.village!)
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
                                r[0].village = newHovel
                            }
                            
                        }
                    }
                }

                // Move the unit
                from.unit?.currentAction = Constants.Unit.Action.Moved
                to.unit = from.unit
                from.unit = nil

                // Completed operations
                break villageLoop
            }
        }
    }
}
