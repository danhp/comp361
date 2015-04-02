import Foundation
import GameKit
import SpriteKit

private let _instance = GameEngine()

class GameEngine {
    class var Instance: GameEngine { return _instance }

    var game: Game?
    var map: Map? { return self.game?.map }
    var scene: GameScene?

    var matchEnded: Bool { return MatchHelper.sharedInstance().myMatch?.status == GKTurnBasedMatchStatus.Ended  ?? false }

    // List of unit awaiting orders
    var availableUnits: [Tile] = []
    var availableVillages: [Tile] = []

    // Map selection
    private var currentChoices: [Int]?

    init() { }

    // Starts a (completely) new match
    func startGameWithMap(map: Int) {
        self.loadMap(number: String(map))
    }

    // Show map selection so player can
    //  i. make a selection
    //  ii. wait until everyone has chosen a map
    func showMapSelection() {
        MatchHelper.sharedInstance().vc?.dismissViewControllerAnimated(true, completion: ({() in
            // Present the map selection controller
            if let mmvc = MatchHelper.sharedInstance().vc as? MainMenuViewController {
                mmvc.segueToMapSelectionViewController()
            }}))
    }

    func showGameScene() {
        // Dismiss any controller and then show Game View Controller
        MatchHelper.sharedInstance().vc?.dismissViewControllerAnimated(true, completion: ({() in
            // Present the game view controller
            if let mmvc = MatchHelper.sharedInstance().vc as? MainMenuViewController {
                mmvc.segueToGameViewController()
            }}))
    }

    // User has selected a choice: Int, process it
    func processMapSelection(choice: Int) {
        // TODO put the game in a "waiting for map selection..." state

        // Add choice to choices array
        if let cur = self.currentChoices {
            self.currentChoices = cur + [choice]    // append selection to previous ones
        } else {
            self.currentChoices = [choice]          // new array with first selection
        }

        // Send info to GameCenter
        let dict = ["choices": self.currentChoices!]
        var error:NSError?
        let matchData = NSJSONSerialization.dataWithJSONObject(dict, options:NSJSONWritingOptions(0), error: &error)
        MatchHelper.sharedInstance().advanceSelectionTurn(matchData!)
    }

    // MARK: - Operations

    // Should get called once a cycle (after all player have played their turn
    func growTrees() {
        if let rows = self.map?.tiles.rows {
            let allTiles = rows.reduce([], combine: +)
            var seen = [Tile]()

            for t in allTiles {
                // Only visit unseen tiles
                if contains(seen, { $0 === t}) { continue }
                seen.append(t)

                // Only consider tiles with trees
                if t.land != .Tree { continue }

                for n in (self.map?.neighbors(tile: t))! {
                    if contains(seen, { $0 === n }) { continue }
                    seen.append(n)

                    if n.isGrowable() {
                        let random = Int(arc4random_uniform(2))
                        if random == 0 {
                            n.land = .Tree
                        }
                        break
                    }
                }
            }
        }
    }

    // Set up the gameState after which the player can start giving out orders
    func beginTurn() {
        self.availableUnits = []
        self.availableVillages = []

        for village in (self.game?.currentPlayer.villages)! {
            // Update the village's state
            if village.state == .Upgrading1 {
                village.state = .Upgrading2
            } else {
                village.state = .ReadyForOrders
            }

            // Update states for all the tiles.
            for tile in village.controlledTiles {

                // Replace tombstones
                tile.replaceTombstone()

                // Produce constructions and set unit actions.
                // ReadyForOrders for all except first phase cultivation
                if let action = tile.unit?.currentAction {
                    if action == .StartCultivating {
                        tile.unit?.currentAction = .FinishCultivating
                    } else {
                        if action == .FinishCultivating {
                            tile.land = .Meadow
                        } else if action == .BuildingRoad {
                            tile.structure = .Road
                        }

                        tile.unit?.currentAction = Constants.Unit.Action.ReadyForOrders
                        self.availableUnits.append(tile)
                    }
                }

                if tile.village != nil {
                    if tile.owner.state == .ReadyForOrders {
                        self.availableVillages.append(tile)
                    }
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
            if tile.village != nil {
                self.availableVillages = self.availableVillages.filter({ $0 !== tile})
                tile.village = nil
            }
            tile.owner.removeTile(tile)

            self.game?.neutralTiles.append(tile)
            self.availableUnits = self.availableUnits.filter({ $0 !== tile })
        }
        village.player?.removeVillage(village)
    }

    func moveUnit(from: Tile, to: Tile) {
        if from.owner.player !== self.game?.currentPlayer { return }

        var path = [Tile]()
        let village = from.owner

        // Simple move rules
        if from.unit == nil { return }
        if (from.unit?.disabled)! { return }
        if from.unit?.type == Constants.Types.Unit.Knight && !to.isWalkable() { return }
        if to.land == .Sea { return }

        // Canon rules
        if from.unit?.type == Constants.Types.Unit.Canon {
            if !contains((self.map?.neighbors(tile: from))!, { $0 === to }) || !to.isWalkable() { return }
            if to.owner != nil {
                if to.owner.player !== self.game!.currentPlayer { return }
            }
        }

        // Check if path exists.
        if to.owner === village {
            // Cannot destroy object within controlled region
            if to.unit != nil || to.village != nil || to.structure == .Tower { return }

            path = (self.map?.getPath(from: from, to: to, accessible: village.controlledTiles))!
        } else {
            for n in (self.map?.neighbors(tile: to))! {
                if n.owner === village && n.isWalkable() {
                    path = (self.map?.getPath(from: from, to: n, accessible: village.controlledTiles))!
                    if !path.isEmpty {
                        path.append(to)
                        break
                    }
                }
            }
        }
        if path.isEmpty { return }

        //===== UPDATE THE GAME STATE =====

        // To tile is outside the controlled region.
        if to.owner !== village {
            // Check offensive rules
            if to.village == Constants.Types.Village.Castle { return }
            if to.isProtected(from.unit!) { return }
            for n in (self.map?.neighbors(tile: to))! {
                if n.owner == nil { continue }
                if n.owner.player? !== self.game?.currentPlayer {
                    if n.unit?.type == Constants.Types.Unit.Canon { continue }
                    if n.isProtected(from.unit!) { return }
                }
            }

            if to.owner == nil {
                self.invadeNeutral(village, unit: from.unit!, to: to)
            } else {
                // Peasant & Canon cannot invade enemy tiles
                if from.unit?.type == Constants.Types.Unit.Peasant { return }
                if from.unit?.type == Constants.Types.Unit.Canon { return }

                self.invadeEnemy(village, unit: from.unit!, to: to)
            }
        }

        from.unit?.currentAction = Constants.Unit.Action.Moved
        self.moveWithAnimation(to: to, from: from, path: path)
    }

    func moveWithAnimation(#to: Tile, from: Tile, path: [Tile]) {
        var moveActions = [SKAction]()

        // Update tiles in the path
        for (index, t) in enumerate(path) {
            if index+1 >= path.count { break }

            var removeGrass = SKAction.runBlock({})

            if (from.unit?.type.rawValue >= Constants.Types.Unit.Soldier.rawValue)
                && t.land == .Meadow
                && t.structure != .Road {
                    removeGrass = SKAction.runBlock({
                        t.land = .Grass
                    })
            }

            let dx = path[index+1].position.x - path[index].position.x
            let dy = path[index+1].position.y - path[index].position.y
            let delta = CGVector(dx: dx, dy: dy)

            let moveAction = SKAction.sequence([SKAction.moveBy(delta, duration: 0.3), removeGrass])
            moveActions.append(moveAction)
        }

        let n = ((from.unit?)!.node?)!
        n.runAction(SKAction.sequence(moveActions), completion: {
            // Update the destination tile
            if to.structure? == Constants.Types.Structure.Tombstone {
                to.structure = nil
            }
            if to.land == .Tree {
                to.land = .Grass
                from.owner.wood += 1
            }
            if (from.unit?.type.rawValue >= Constants.Types.Unit.Soldier.rawValue)
                && to.land == .Meadow
                && to.structure != .Road {
                    to.land = .Grass
            }

            // Move the unit
            to.unit = from.unit
            from.unit = nil
            self.availableUnits = self.availableUnits.filter({ $0 !== from })

            GameEngine.Instance.map?.resetColor()
            GameEngine.Instance.map?.draw()
            self.updateInfoPanel()
        })
    }

    private func invadeNeutral(village: Village, unit: Unit, to: Tile) {
        var mainVillage = village
        var mergeVillage: Village

        // Update the state.
        mainVillage.addTile(to)
        self.game?.neutralTiles = (self.game?.neutralTiles)!.filter({ $0 !== to })

        // Merge connected regions
        for n in (self.map?.neighbors(tile: to))! {
            if n.owner == nil { continue }
            if n.owner.player === mainVillage.player {
                if n.owner === mainVillage { continue }

                if mainVillage.compareTo(n.owner) {
                    mergeVillage = n.owner
                } else {
                    mergeVillage = mainVillage
                    mainVillage = n.owner
                }

                // Transfer tiles
                for t in mergeVillage.controlledTiles {
                    mainVillage.addTile(t)
                    if t.village != nil {
                        t.village = nil
                        self.availableVillages = self.availableVillages.filter({$0 !== t})
                    }
                }

                // Transfer resources
                mainVillage.gold += mergeVillage.gold
                mainVillage.wood += mergeVillage.wood

                self.game?.currentPlayer.removeVillage(mergeVillage)
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

        self.checkPostAttack(enemyVillage)
    }

    func attack(from: Tile, to: Tile) {
        if from.owner.player !== self.game?.currentPlayer { return }
        if from.unit?.type != Constants.Types.Unit.Canon { return }
        if to.isBelongsToLocal() { return }
        if from.owner.wood < 1 { return }
        if to.land == .Sea { return }
        if !(self.map?.isDistanceOfTwo(from, to: to))! { return }

        var enemyVillage = to.owner

        to.structure = nil
        to.land = .Grass
        if to.unit != nil {
            to.unit = nil
            to.structure = .Tombstone
        }
        if to.village != nil {
            to.owner.attacked()
            if to.owner.health == 0 {
                let newHovel = Village()
                to.village = nil
                to.owner.player?.removeVillage(to.owner)
                to.owner.player?.addVillage(newHovel)
                for t in to.owner.controlledTiles {
                    if t === to {
                        self.game?.neutralTiles.append(t)
                        to.owner = nil
                    } else {
                        newHovel.addTile(t)
                    }
                }
                enemyVillage = newHovel
            }
        } else {
            self.game?.neutralTiles.append(to)
            if let o = to.owner {
                to.owner.removeTile(to)
            }
        }

        if let v = enemyVillage {
            self.checkPostAttack(v)
        }

        from.unit?.currentAction = Constants.Unit.Action.Moved
        from.owner.wood -= 1
        self.availableUnits = self.availableUnits.filter({ $0 !== from })
    }

    private func checkPostAttack(enemyVillage: Village) {
        let regions = (self.map?.getRegions(enemyVillage.controlledTiles))!
        for r in regions {
            // Region is too small
            if r.count < 3 {
                for t in r {
                    t.structure = nil
                    if t.unit != nil {
                        t.unit = nil
                        t.structure = .Tombstone
                    }
                    self.game?.neutralTiles.append(t)
                    if t.village != nil {
                        t.owner.player?.removeVillage(t.owner)
                        t.village = nil
                    }
                    t.owner.removeTile(t)
                }
                continue
            }

            // Region can still support a village
            if self.map?.getVillage(r) == nil {
                let newHovel = Village()
                for t in r {
                    enemyVillage.removeTile(t)
                    newHovel.addTile(t)
                }

                enemyVillage.player!.addVillage(newHovel)

                r[0].land = .Grass
                r[0].unit = nil
                r[0].structure = nil
                r[0].village = newHovel.type
            }
        }
    }

    func upgradeVillage(tile: Tile) {
        if tile.owner.player !== self.game?.currentPlayer { return }
        if tile.owner.disaled { return }
        if tile.village == nil { return }

        tile.owner.upgradeVillage()
        self.availableVillages = self.availableVillages.filter({ $0 !== tile})
    }

    func upgradeUnit(tile: Tile, newLevel: Constants.Types.Unit) {
        if tile.owner.player !== self.game?.currentPlayer { return }
        if tile.unit?.type.rawValue >= Constants.Types.Unit.Knight.rawValue { return }
        if (tile.unit?.disabled)! { return }

        if let unit = tile.unit {
            if unit.type == .Knight || unit.type == .Canon { return }

            let village = tile.owner!
            village.upgradeUnit(tile.unit!, newType: newLevel)
            self.availableUnits = self.availableUnits.filter({ $0 !== tile })
        }
    }

    func combineUnit(tileA: Tile, tileB: Tile) {
        if tileA.owner !== tileB.owner { return }
        if tileA.owner.player !== self.game?.currentPlayer { return }
        if tileA.unit?.type.rawValue >= Constants.Types.Unit.Knight.rawValue
                    || tileB.unit?.type.rawValue >= Constants.Types.Unit.Knight.rawValue { return }
        if (tileA.unit?.disabled)! || (tileB.unit?.disabled)! { return }
        tileA.unit?.combine(tileB.unit!)
        tileA.unit?.currentAction = Constants.Unit.Action.UpgradingCombining
        tileB.unit = nil
        self.availableUnits = self.availableUnits.filter({ $0 !== tileA || $0 !== tileB })
    }

    func recruitUnit(villageTile: Tile, type: Constants.Types.Unit) {
        if villageTile.owner.player !== self.game?.currentPlayer { return }
        // Can only be called on a village
        if villageTile.village == nil { return }

        let village = villageTile.owner
        if village.disaled { return }

        // Hovel (value: 0) can only recruit peasants and infantry (rawVaue: 1 & 2)
        // Town (value: 1) can also recruit soldiers (rawValue: 3)
        // Fort (value: 2) can also recruit knight and canon (rawValue: 4 & 5)
        if villageTile.owner.type.rawValue + 2 < type.rawValue { return }

        var destination: Tile?
        for n in (self.map?)!.neighbors(tile: villageTile) {
            if n.owner !== villageTile.owner { continue }
            if n.isWalkable() && n.unit == nil && n.structure == nil {
                destination = n
                break
            }
        }
        if destination == nil { return }

        let costGold = type.cost().0
        let costWood = type.cost().1
        if village.gold < costGold || village.wood < costWood { return }


        village.gold -= costGold
        village.wood -= costWood

        var newUnit = Unit(type: type)

        // For testing purposes this is uncommented at times.
//        newUnit.currentAction = .Moved
//        self.availableUnits.append(destination!)
        destination!.unit = newUnit
    }

    func buildTower(on: Tile) {
        if on.owner.player !== self.game?.currentPlayer { return }

        let village = on.owner
        if village.disaled { return }

        // Check tower construction rules
        if village.type == .Hovel { return }
        let tower = Constants.Types.Structure.Tower
        if village.wood < tower.cost() || !on.isBuildable() { return }

        // Update the state
        village.wood -= tower.cost()
        on.structure = tower
    }

    // Moves unit from -> on, instruct unit to start building road.
    func buildRoad(from: Tile, on: Tile) {
        if from.owner.player !== self.game?.currentPlayer { return }
        if from.unit == nil { return }
        let village = from.owner

        // Tiles must be connected and in the same region
        if village !== on.owner { return }

        let path = (self.map?.getPath(from: from, to: on, accessible: village.controlledTiles))!
        if from !== on {
            if path.isEmpty { return }
            if !on.isBuildable() { return }
        } else {
            if on.structure != nil { return }
        }

        // Check road building rules
        let road = Constants.Types.Structure.Road
        if village.wood < road.cost()
            || (from.unit?.disabled)!
            || from.unit?.type != Constants.Types.Unit.Peasant{ return }

        // Change the state.
        village.wood -= road.cost()

        // Move the unit
        from.unit?.currentAction = Constants.Unit.Action.BuildingRoad
        if from !== on {
            self.moveWithAnimation(to: on, from: from, path: path)
        }

        self.availableUnits = self.availableUnits.filter({ $0 !== from })
    }

    // Moves unit from -> on, instruct unit to start creating meadow for 2 turns
    func startCultivating(from: Tile, on: Tile) {
        if from.owner.player !== self.game?.currentPlayer { return }
        if from.unit == nil { return }
        if on.land != .Grass{ return }

        let village = from.owner

        //Tiles must be connected and in the same region
        if village !== on.owner { return }

        let path = (self.map?.getPath(from: from, to: on, accessible: village.controlledTiles))!
        if from !== on {
            if path.isEmpty { return }
            if !on.isBuildable() { return }
        } else {
            if on.structure != nil { return }
        }

        // Check cultivation rules
        let cost = Constants.Types.Land.Meadow.cost()
        if village.wood < cost
            || (from.unit?.disabled)!
            || from.unit?.type != Constants.Types.Unit.Peasant{ return }

        // Change the state
        village.wood -= cost

        // Move the unit
        from.unit?.currentAction = Constants.Unit.Action.StartCultivating
        if from !== on {
            self.moveWithAnimation(to: on, from: from, path: path)
        }
        self.availableUnits = self.availableUnits.filter({ $0 !== from })
    }

    // MARK: Operation helper

    func updateInfoPanel() {
        if let vc = MatchHelper.sharedInstance().vc as? GameViewController {
            vc.updateInfoPanel(self.game?.map.selected)
        }
    }

    func updateTurnLabel() {
        if let vc = MatchHelper.sharedInstance().vc as? GameViewController {
            vc.updateTurnLabel()
        }
    }

    // MARK: - UI Helper

    func getNextAvailableUnit() -> Tile? {
        if self.availableUnits.count <= 0 { return nil }

        let nextTile = self.availableUnits.removeAtIndex(0)
        self.availableUnits.append(nextTile)

        return nextTile
    }

    func getNextAvailableVillage() -> Tile? {
        if self.availableVillages.count <= 0 { return nil }

        let nextTile = self.availableVillages.removeAtIndex(0)
        self.availableVillages.append(nextTile)

        return nextTile
    }

    // MARK: - Serialization

    func loadMap(#number: String) {
        var e: NSError?
        if let path = NSBundle.mainBundle().pathForResource(number, ofType: "json") {
            if let json = NSString(contentsOfFile:path, encoding:NSUTF8StringEncoding, error:&e) {
                if let data = (json as NSString).dataUsingEncoding(NSUTF8StringEncoding) {
                    self.game = Game()
                    self.game?.importDictionary(self.dataToDict(data)!)
                }
            }
        }
    }

    // SUMMARY
    // In map selection sequence:
    //      - match data only has 'choice' array, array grows from 1-2-3, at 3
    // After 3, we enter in map final selection and start of the game
    //      - replace current match data with the map selected
    func decode(matchData: NSData) {
        //TODO TEMP
        self.startGameWithMap(3)
        self.showGameScene()

        return

        // EXISTING MATCH
        if matchData.length > 0 {
            if let dict = self.dataToDict(matchData) {  // try to extract match data
                if let choices = dict["choices"] as? [Int] {    // choice is only present during map selection

                    // MAP SELECTION SEQUENCE ENDED
                    if choices.count == 3 && MatchHelper.sharedInstance().currentParticipantIndex() == 0  { // make sure current player is first one
                        let finalChoice = choices[Int(arc4random_uniform(3))]
                        GameEngine.Instance.startGameWithMap(finalChoice)   // replace match data with a new game loaded with map number
                        MatchHelper.sharedInstance().updateMatchData()      // send update to every one
                        self.showGameScene()
                        // MAP SELECTION SEQUENCE IN PROGRESS
                    } else { // TODO pass a bool saying userShouldSelect or userShouldwait
                        self.currentChoices = choices
                        self.showMapSelection() // current player will select a map
                    }

                    // MATCH IN PROGRESS
                } else {
                    self.game = Game()
                    self.game?.importDictionary(dict)
                    self.scene?.resetMap()
                    self.updateTurnLabel()
                    self.showGameScene()
                }
            }

            // NEW MATCH - initiate map selection sequence
        } else {
            self.showMapSelection()
        }
    }

    func encodeMatchData() -> NSData {
        return (self.game?.encodeMatchData())!
    }

    func encodeTurnMessage() -> String {
        return self.game?.matchTurnMessage() ?? "No message."
    }

    // Decodes match data into a dictionary
    func dataToDict(data: NSData) -> NSDictionary? {
        var parseError: NSError?
        let parsedObject: AnyObject? = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.AllowFragments, error: &parseError)

        if let e = parseError { println(e) }

        return parsedObject as? NSDictionary
    }
}
