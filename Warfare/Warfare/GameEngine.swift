import Foundation
import GameKit
import SpriteKit

private let _instance = GameEngine()

class GameEngine {
    class var Instance: GameEngine { return _instance }

    var game: Game!
    var map: Map { return self.game.map }
    var scene: GameScene?
    
    init() { }
    
    func newGame() {
        self.loadMap(number: "1")
    }

    // MARK: - Operations


    // Set up the gameState after which the player can start giving out orders
    func beginTurn() {
        for village in self.game.currentPlayer.villages {
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
                village.gold -= tile.wage()
            }

            // Delete the Village
            if village.gold <= 0 {
                self.killVillage(village)
            }
        }
    }

    private func killVillage(village: Village) {
        for tile in village.controlledTiles {
            tile.structure = nil
            if tile.unit != nil {
                tile.unit = nil
                tile.structure = .Tombstone
            }
            tile.village = nil
            tile.owner.removeTile(tile)
            self.game.neutralTiles.append(tile)
        }
        self.game.currentPlayer.removeVillage(village)
    }

    func moveUnit(from: Tile, to: Tile) {
        if from.owner.player !== self.game.currentPlayer { return }

        var path = [Tile]()
        var village = from.owner

        // Simple move rules
        if from.unit == nil { return }
        if from.unit?.currentAction != Constants.Unit.Action.ReadyForOrders { return }
        if (from.unit?.type)! == Constants.Types.Unit.Knight
                    && (to.land! == .Tree || to.structure? == Constants.Types.Structure.Tombstone) { return }
        if to.land == .Sea { return }

        // Check if path exists.
        if to.owner === village {
            // Cannot destroy object within controlled region
            if to.unit != nil || to.village != nil || to.structure == .Tower { return }

            path = self.map.getPath(from: from, to: to, accessible: village.controlledTiles)
        } else {
            for n in self.map.neighbors(tile: to) {
                if n.owner === village && n.isWalkable() {
                    path = self.map.getPath(from: from, to: n, accessible: village.controlledTiles)
                    if !path.isEmpty { break }
                }
            }
        }
        if path.isEmpty { return }

        //===== UPDATE THE GAME STATE =====

        // To tile is outside the controlled region.
        if to.owner !== village {
            // Check offensive rules
            if to.isProtected(from.unit!) { return }
            for n in self.map.neighbors(tile: to) {
                if n.owner.player !== self.game.currentPlayer {
                    if n.isProtected(from.unit!) { return }
                }
            }

            if to.owner == nil {
                self.invadeNeutral(village, unit: from.unit!, to: to)
            } else {
                self.invadeEnemy(village, unit: from.unit!, to: to)
            }
        }

        // Update tiles in the path
        path.append(to)
        for t in path {
            if (from.unit?.type == Constants.Types.Unit.Knight || from.unit?.type == Constants.Types.Unit.Soldier)
                        && t.land == .Meadow
                        && t.structure != .Road {
                t.land = .Grass
            }
        }

        // Update the destination tile
        if to.structure? == Constants.Types.Structure.Tombstone {
            to.structure = nil
        }
        if to.land == .Tree {
            to.land = .Grass
            village.wood += 1
        }

        // Move the unit
        to.unit = from.unit
        from.unit = nil
        to.unit?.currentAction = Constants.Unit.Action.Moved
    }

    private func invadeNeutral(village: Village, unit: Unit, to: Tile) {
        var mainVillage = village
        var mergeVillage: Village

        // Update the state.
        mainVillage.addTile(to)
        self.game.neutralTiles = self.game.neutralTiles.filter({ $0 !== to })

        // Merge connected regions
        for n in self.map.neighbors(tile: to) {
            if n.owner.player === mainVillage.player {
                if n.owner === mainVillage { continue }

                if mainVillage.compareTo(n.owner) {
                    mergeVillage = n.owner
                } else {
                    mergeVillage = mainVillage
                    mainVillage = n.owner
                }

                for t in mergeVillage.controlledTiles {
                    mainVillage.addTile(t)
                    t.village = nil
                }

                self.game.currentPlayer.removeVillage(mergeVillage)
            }
        }
    }

    private func invadeEnemy(village: Village, unit: Unit, to: Tile) {
        var enemyPlayer = to.owner.player
        var enemyVillage = to.owner

        // Check specific offensive rules
        if to.village != nil && unit.type.rawValue < 2
                    || unit.type.rawValue == 2 && to.village?.rawValue == 2 { return }

        // Invade enemy tile
        to.owner?.removeTile(to)
        village.addTile(to)

        // Update destination tile
        to.unit = nil
        to.structure = nil
        if to.village != nil {
            village.wood = (to.owner?.wood)!
            village.gold = (to.owner?.wood)!
            to.village = nil
            to.owner.removeTile(to)
        }

        let regions = self.map.getRegions(enemyVillage.controlledTiles)
        for r in regions {
            // Region is too small
            if r.count < 3 {
                for t in r {
                    t.structure = nil
                    if t.unit != nil {
                        t.unit = nil
                        t.structure = .Tombstone
                    }
                    t.owner.removeTile(t)
                    self.game.neutralTiles.append(t)
                    if t.village != nil {
                        t.owner.player?.removeVillage(t.owner)
                        t.village = nil
                    }
                }
                continue
            }

            // Region can still support a village
            if self.map.getVillage(r) == nil {
                let newHovel = Village()
                for t in r {
                    enemyVillage.removeTile(t)
                    newHovel.addTile(t)
                }
                
                enemyPlayer?.addVillage(newHovel)
                
                r[0].land = .Grass
                r[0].unit = nil
                r[0].structure = nil
                r[0].village = newHovel.type
            }
        }
    }


    func upgradeVillage(tile: Tile) {
        if tile.owner.player !== self.game.currentPlayer { return }
        if tile.village == nil { return }

        tile.owner.upgradeVillage()
    }

    func upgradeUnit(tile: Tile, newLevel: Constants.Types.Unit) {
        if tile.owner.player !== self.game.currentPlayer { return }

        let village = tile.owner!
        village.upgradeUnit(tile.unit!, newType: newLevel)
    }

    func combineUnit(tileA: Tile, tileB: Tile) {
        if tileA.owner !== tileB.owner { return }
        if tileA.owner.player !== self.game.currentPlayer { return }

        tileA.unit?.combine(tileB.unit!)
        tileB.unit = nil
    }

    func recruitUnit(tile: Tile, type: Constants.Types.Unit) {
        if tile.owner.player !== self.game.currentPlayer { return }

        let village = tile.owner

        // Hovel can only recruit peasants and infantry (rawVaue: 1 & 2)
        // Town can also recruit soldiers (rawValue: 3)
        // Fort can also recruit knight (rawValue: 4)
        if type.rawValue > tile.owner.type.rawValue + 2 { return }

        let cost = (type.rawValue + 1) * Constants.Cost.Upgrade.Unit.rawValue
        if village.gold < cost || !tile.isWalkable() { return }

        village.gold -= cost

        var newUnit = Unit(type: type)
        newUnit.currentAction = .Moved
        tile.unit = newUnit
    }

    func buildTower(on: Tile) {
        if on.owner.player !== self.game.currentPlayer { return }

        let village = on.owner

        // Check tower construction rules
        if village.type == .Hovel { return }
        let tower = Constants.Types.Structure.Tower
        if village.wood < tower.cost() || !on.isBuildable() { return }

        // Update the state
        village.wood -= tower.cost()
        on.structure = tower
    }

    // Moves unit from -> on, instruct unit to start building road.
    func buildRoad(on: Tile, from: Tile) {
        if from.owner.player !== self.game.currentPlayer { return }

        let village = from.owner

        // Tiles must be connected and in the same region
        if village !== on.owner { return }

        let path = self.map.getPath(from: from, to: on, accessible: village.controlledTiles)
        if path.isEmpty { return }

        // Check road building rules
        let road = Constants.Types.Structure.Road
        if village.wood < road.cost()
                    || !on.isBuildable()
                    || from.unit?.currentAction != Constants.Unit.Action.ReadyForOrders
                    || from.unit?.type != Constants.Types.Unit.Peasant{ return }

        // Change the state.
        village.wood -= road.cost()
        on.unit = from.unit
        from.unit = nil
        on.unit?.currentAction = Constants.Unit.Action.BuildingRoad
    }

    // Moves unit from -> on, instruct unit to start creating meadow for 2 turns
    func startCultivating(on: Tile, from: Tile) {
        if from.owner.player !== self.game.currentPlayer { return }

        let village = from.owner

        //Tiles must be connected and in the same region
        if village !== on.owner { return }

        let path = self.map.getPath(from: from, to: on, accessible: village.controlledTiles)
        if path.isEmpty { return }

        // Check cultivation rules
        let cost = Constants.Types.Land.Meadow.cost()
        if village.wood < cost
                    || !on.isBuildable()
                    || from.unit?.currentAction != Constants.Unit.Action.ReadyForOrders
                    || from.unit?.type != Constants.Types.Unit.Peasant{ return }

        // Change the state
        village.wood -= cost
        on.unit = from.unit
        from.unit = nil
        on.unit?.currentAction = Constants.Unit.Action.StartCultivating
    }

    // MARK: - Serialization

    func loadMap(#number: String) {
        var e: NSError?
        if let path = NSBundle.mainBundle().pathForResource(number, ofType: "json") {
            if let json = NSString(contentsOfFile:path, encoding:NSUTF8StringEncoding, error:&e) {
                if let data = (json as NSString).dataUsingEncoding(NSUTF8StringEncoding) {
                    self.decode(data)
                }
            }
        }
    }
    
    func decode(matchData: NSData) {
        self.game = Game()
        self.game.importData(matchData)
    }
    
    func encodeMatchData() -> NSData {
        return (self.game?.encodeMatchData())!
    }
    
    func encodeTurnMessage() -> String {
        return self.game?.matchTurnMessage() ?? "No message."
    }
}
