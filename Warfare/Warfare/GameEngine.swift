import Foundation
import GameKit
import SpriteKit
import AVFoundation

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
    var currentChoices: [Int]?
    var userSelectingMap: Bool { return (self.currentChoices == nil && MatchHelper.sharedInstance().localParticipantIndex() == 0) || MatchHelper.sharedInstance().localParticipantIndex() == self.currentChoices?.count }

    // Mark: - Audio Player
    var audioPlayer: AVAudioPlayer?
    var musicPlayer: AVAudioPlayer?
    var shortPlayer: AVAudioPlayer?
    var yesPlayer: AVAudioPlayer?

    func playMusic(inGame: Bool = true) {
        var name: String = "background"
        if inGame { name = "background2" }

        if let url: NSURL = NSBundle.mainBundle().URLForResource(name, withExtension: "wav") {
            self.musicPlayer = AVAudioPlayer(contentsOfURL: url, error: nil)
            self.musicPlayer?.prepareToPlay()
            self.musicPlayer?.play()
            self.musicPlayer?.numberOfLoops = -1
        }
    }

    func stopMusic() { self.musicPlayer?.stop() }

    func playSound(name: String, type: String = "mp3", loop: Bool = true) {
        if let url: NSURL = NSBundle.mainBundle().URLForResource(name, withExtension: type) {
            self.audioPlayer = AVAudioPlayer(contentsOfURL: url, error: nil)
            self.audioPlayer?.play()
            if loop { self.audioPlayer?.numberOfLoops = -1 }
        }
    }

    func stopSound() {
        self.audioPlayer?.stop()
    }

    func playShortSound(name: String, type: String = "mp3") {
        if let url: NSURL = NSBundle.mainBundle().URLForResource(name, withExtension: type) {
            self.shortPlayer = AVAudioPlayer(contentsOfURL: url, error: nil)
            self.shortPlayer?.play()
        }
    }

    func randomYesSound() {
        let sounds = ["a vos ordres", "attendons order", "oui capitaine", "pour le roi", "pour notre souverain"]
        let random = Int(arc4random_uniform(UInt32(sounds.count + 5)))   // 5 so it doesn't always play a sound

        // play sound
        if random < sounds.count {
            if let url: NSURL = NSBundle.mainBundle().URLForResource(sounds[random], withExtension: "mp3") {
                self.yesPlayer = AVAudioPlayer(contentsOfURL: url, error: nil)
                self.yesPlayer?.play()
            }
        }
    }

    init() { }

    // Starts a (completely) new match
    func startGameWithMap(map: Int) {
        self.loadMap(number: String(map))
    }

    // Show map selection so player can
    //  i. make a selection
    //  ii. wait until everyone has chosen a map
    func showMapSelection() {
        if let vc = MatchHelper.sharedInstance().vc as? MainMenuViewController {
            vc.segueToMapSelectionViewController()
        } else if let vc = MatchHelper.sharedInstance().vc as? MapSelectionViewController {
            vc.updateWaitCount((self.currentChoices?.count ?? 0))
        }
    }

    func showGameScene() {
        // MAIN => GAME
        // MAP  => GAME
        if let vc = MatchHelper.sharedInstance().vc as? MainMenuViewController {
            vc.segueToGameViewController()
        } else if let vc = MatchHelper.sharedInstance().vc as? MapSelectionViewController {
            vc.segueToGameViewController()
        }
    }

    // User has selected a choice: Int, process it
    func processMapSelection(choice: Int) {
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

        if self.currentChoices?.count == 3 {
            MatchHelper.sharedInstance().loadMatchData()
        } else {
            (MatchHelper.sharedInstance().vc as MapSelectionViewController).updateWaitCount((self.currentChoices?.count)!)
        }
    }

    // MARK: - Operations

    // Should get called once a cycle (after all player have played their turn
    func growTrees() {
        if self.matchEnded { return }

        if let rows = self.map?.tiles.rows {
            let allTiles = rows.reduce([], combine: +)
            var seen = [Tile]()

            for t in allTiles {
                // Grow from tombstones (edge case)
                t.replaceTombstone()

                // Only consider tiles with trees
                if t.land != .Tree { continue }

                // Dont consider tiles with new trees
                if contains(seen, t) { continue }

                for n in (self.map?.neighbors(tile: t))! {
                    if n.isGrowable() {
                        let random = Int(arc4random_uniform(2))
                        if random == 0 {
                            n.land = .Tree
                            n.draw()
                            seen.append(n)
                        }
                        break
                    }
                }
            }
        }
    }

    // Set up the gameState after which the player can start giving out orders
    func beginTurn() {
        if !(self.game?.localIsCurrentPlayer)! { return }

        self.availableUnits = []
        self.availableVillages = []

        self.game?.roundCount++

        var gold = 0
        var wages = 0
        var starved = 0
        var meadows = 0
        var roads = 0
        var unitsReady = 0

        for village in (self.game?.currentPlayer.villages)! {
            // Update the village's state
            if village.state == .Upgrading1 {
                village.state = .Upgrading2
            } else if village.state == .Upgrading2 {
                village.state = .ReadyForOrders
                if let newType = Constants.Types.Village(rawValue: village.type.rawValue + 1) {
                    village.type = newType
                }
                village.health = village.type.health()
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
                            meadows++
                        } else if action == .BuildingRoad {
                            tile.structure = .Road
                            roads++
                        }

                        tile.unit?.currentAction = Constants.Unit.Action.ReadyForOrders
                        self.availableUnits.append(tile)
                        unitsReady++
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

                gold += tile.goldValue()
                wages += tile.wage()

                tile.draw()
            }

            // Starve the Village
            if village.gold <= 0 {
                starved++
                self.starveVillage(village)
            }
        }

        let goldString = "You gained " + String(gold) + " gold and paid " + String(wages) + " gold. "
        let starvedString = ((starved > 0) ? String(starved) + " of your villages starved. " : "")
        let meadowString = (meadows > 0 ? String(meadows) + " meadows were cultivated. " : "")
        let roadString = (roads > 0 ? String(roads) + " roads were built. " : "")
        let unitString = "You now have " + String(unitsReady) + " units ready. "
        let msg =  goldString +  starvedString + meadowString + roadString + unitString
        self.showToast(msg, duration: 10.0)
    }

    private func starveVillage(village: Village) {
        for tile in village.controlledTiles {
            if tile.unit != nil {
                tile.unit = nil
                tile.structure = .Tombstone
                tile.land = .Grass
            }
        }
        village.wood = 0
        village.gold = 0
        village.isSmoking = true
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
        if from.owner.player !== self.game?.currentPlayer {
            self.showToast("You don't own that tile")
            return
        }

        var path = [Tile]()
        let village = from.owner

        // Simple move rules
        if from.unit == nil {
            self.showToast("There is nothing to move")
            return
        }
        if (from.unit?.disabled)! {
            self.showToast("Selected unit is disabled")
            return
        }
        if from.unit?.type == Constants.Types.Unit.Knight && !to.isWalkable() {
            self.showToast("Your knight won't clear that tile")
            return
        }
        if to.land == .Sea {
            self.showToast("That unit doesn't want to drown")
            return
        }

        // Canon rules
        if from.unit?.type == Constants.Types.Unit.Canon {
            if !contains((self.map?.neighbors(tile: from))!, { $0 === to }) || !to.isWalkable() {
                self.showToast("Your canon won't clear that tile")
                return
            }
            if to.owner.player !== self.game?.currentPlayer {
                self.showToast("The canon can't invade enemy land")
                return
            }
        }

        // Check if path exists.
        if to.owner === village {
            // Cannot destroy object within controlled region
            if to.unit != nil || to.village != nil || to.structure == .Tower {
                self.showToast("You already have something at the destination")
                return
            }

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
        if path.isEmpty {
            self.showToast("Your unit can't reach that tile")
            return
        }

        //===== UPDATE THE GAME STATE =====

        // To tile is outside the controlled region.
        if to.owner !== village {
            // Check offensive rules
            if to.village == Constants.Types.Village.Castle {
                self.showToast("You can't invade a Castle like that")
                return
            }
            if to.isProtected(from.unit!) {
                self.showToast("Your unit is too weak to move there")
                return
            }
            for n in (self.map?.neighbors(tile: to))! {
                if n.owner == nil { continue }
                if n.owner.player? !== self.game?.currentPlayer {
                    if n.unit?.type == Constants.Types.Unit.Canon { continue }
                    if n.isProtected(from.unit!) {
                        self.showToast("Won't do that, there's unit standing guard")
                        return
                    }
                }
            }

            if to.owner == nil {
                self.invadeNeutral(village, unit: from.unit!, to: to)
            } else {
                // Peasant & Canon cannot invade enemy tiles
                if from.unit?.type == Constants.Types.Unit.Peasant {
                    self.showToast("Peasants don't have the means to invade enemy land")
                    return
                }
                if from.unit?.type == Constants.Types.Unit.Canon {
                    self.showToast("Canons can't invade enemy land")
                    return
                }

                self.invadeEnemy(village, unit: from.unit!, to: to)
            }
        }

        self.moveWithAnimation(to: to, from: from, path: path, state: .Moved)
    }

    func moveWithAnimation(#to: Tile, from: Tile, path: [Tile], state: Constants.Unit.Action) {
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
                        t.draw()
                        self.playShortSound("trample")
                    })
            }

            let dx = path[index+1].position.x - path[index].position.x
            let dy = path[index+1].position.y - path[index].position.y
            let delta = CGVector(dx: dx, dy: dy)

            let moveAction = SKAction.sequence([SKAction.moveBy(delta, duration: 0.3), removeGrass])
            moveActions.append(moveAction)
        }

        let u = (from.unit?)!

        // play sound
        self.playSound(u.type.name())
        self.randomYesSound()

        // run animation
        u.node!.runAction(SKAction.sequence(moveActions), completion: {
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
            if let unit = to.unit {
                unit.currentAction = state
            }

            self.stopSound()

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
        if to.village != nil && unit.type.rawValue < 3
            || unit.type.rawValue == 3 && to.village?.rawValue == 2 { return }


        // Update destination tile
        to.unit = nil
        to.structure = nil
        if to.village != nil {
            village.wood += (to.owner?.wood)!
            village.gold += (to.owner?.gold)!
            to.village = nil
        }

        // Invade enemy tile
        to.owner?.removeTile(to)
        village.addTile(to)

        self.checkPostAttack(enemyVillage)
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
                        t.land = .Tree
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

    func attack(from: Tile, to: Tile) {
        if from.owner.player !== self.game?.currentPlayer {
            self.showToast("You don't own that tile")
            return
        }
        if from.unit?.type != Constants.Types.Unit.Canon {
            self.showToast("Only canons may attack")
            return
        }
        if to.land == .Sea || to.owner == nil {
            self.showToast("This is war, the canon won't waste his shots")
            return
        }
        if from.owner.player === to.owner.player {
            self.showToast("The canon won't destroy his own land")
            return
        }
        if from.owner.wood < 1 {
            self.showToast("You don't have the resources to shoot the canon")
            return
        }
        if !(self.map?.isDistanceOfTwo(from, to: to))! {
            self.showToast("That tile is too far to shoot")
            return
        }

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

            // animate
            to.owner.isBurning = true
        } else {
            self.game?.neutralTiles.append(to)
            if let o = to.owner {
                to.owner.removeTile(to)
            }
        }

        if let v = enemyVillage {
            self.checkPostAttack(v)
            // TODO:
            self.map?.draw()
        }

        from.unit?.currentAction = Constants.Unit.Action.Moved
        from.owner.wood -= 1

        from.alpha = 0.0
        from.draw()
        from.runAction(SKAction.fadeInWithDuration(0.3))
        to.draw()

        self.playShortSound("attack")

        self.availableUnits = self.availableUnits.filter({ $0 !== from })
    }

    func upgradeVillage(tile: Tile) {
        if tile.owner.player !== self.game?.currentPlayer {
            self.showToast("You don't own that tile")
            return
        }
        if tile.owner.disaled {
            self.showToast("That village is busy")
            return
        }
        if tile.village == nil {
            self.showToast("There are no village to upgrade")
            return
        }

        self.playShortSound("build-upgrade", type: "wav")

        tile.owner.upgradeVillage()
        self.availableVillages = self.availableVillages.filter({ $0 !== tile})
    }

    func upgradeUnit(tile: Tile, newLevel: Constants.Types.Unit) {
        if tile.owner.player !== self.game?.currentPlayer {
            self.showToast("You don't own that tile")
            return
        }
        if tile.unit?.type.rawValue >= Constants.Types.Unit.Knight.rawValue {
            self.showToast("That unit has his highest potential")
            return
        }
        if (tile.unit?.disabled)! {
            self.showToast("That unit is busy")
            return
        }

        if let unit = tile.unit {
            let village = tile.owner!
            village.upgradeUnit(tile, newType: newLevel)
            self.availableUnits = self.availableUnits.filter({ $0 !== tile })
            self.randomYesSound()
        } else {
            self.showToast("There are no units to upgrade")
        }
    }

    func combineUnit(tileA: Tile, tileB: Tile) {
        if tileA === tileB {
            self.showToast("You can't combine with yourself")
            return
        }
        if tileA.owner !== tileB.owner {
            self.showToast("Units must be in the same region")
            return
        }
        if tileA.owner.player !== self.game?.currentPlayer {
            self.showToast("You don't own those units")
            return
        }
        if tileA.unit?.type.rawValue >= Constants.Types.Unit.Knight.rawValue
                    || tileB.unit?.type.rawValue >= Constants.Types.Unit.Knight.rawValue {
            self.showToast("One of the units has reached the maximal potiential")
            return
        }
        if (tileA.unit?.disabled)! || (tileB.unit?.disabled)! {
            self.showToast("One of the units is busy")
            return
        }
        tileA.unit?.combine(tileB.unit!)
        tileA.unit?.currentAction = Constants.Unit.Action.UpgradingCombining
//        tileB.unit = nil // setting below in animation
        self.availableUnits = self.availableUnits.filter({ $0 !== tileA || $0 !== tileB })

        // Animate
        tileB.unit?.node?.runAction(SKAction.fadeOutWithDuration(0.3), completion: ({
            tileB.unit = nil
            tileB.draw()

            tileA.alpha = 0.0
            tileA.draw()
            tileA.runAction(SKAction.fadeInWithDuration(0.3))
        }))

        self.randomYesSound()
    }

    func recruitUnit(villageTile: Tile, type: Constants.Types.Unit) {
        if villageTile.owner.player !== self.game?.currentPlayer {
            self.showToast("You don't own that tile")
            return
        }
        // Can only be called on a village
        if villageTile.village == nil {
            self.showToast("There are no villages there ")
            return
        }

        let village = villageTile.owner
        if village.disaled {
            self.showToast("That village is diabled")
            return
        }

        // Hovel (value: 0) can only recruit peasants and infantry (rawVaue: 1 & 2)
        // Town (value: 1) can also recruit soldiers (rawValue: 3)
        // Fort (value: 2) can also recruit knight and canon (rawValue: 4 & 5)
        if (type.rawValue > village.type.rawValue + 2) && village.type.rawValue < Constants.Types.Village.Fort.rawValue {
            self.showToast("The village can't support that unit")
            return
        }

        let costGold = type.cost().0
        let costWood = type.cost().1
        if village.gold < costGold || village.wood < costWood {
            self.showToast("You don't have enough money to recruit that unit")
            return
        }

        var newUnit = Unit(type: type)

        var destination: Tile?
        for n in village.controlledTiles {
            if n.isBuildable() {
                destination = n
                break
            }
        }
        // Look for a neutral tile around the edge
        if destination == nil {
            for t in self.map!.getEdgeTiles(village) {
                var invadable = true
                for n in (self.map?.neighbors(tile: t))! {
                    if n.owner == nil { continue }
                    if n.owner.player? !== self.game?.currentPlayer {
                        if n.unit?.type == Constants.Types.Unit.Canon { continue }
                        if n.isProtected(newUnit) {
                            invadable = false
                            break
                        }
                    }
                }
                if invadable {
                    destination = t
                    self.invadeNeutral(village, unit: newUnit, to: t)
                    break
                }
            }
        }
        // Still nil means we failed to find anything.
        if destination == nil {
            self.showToast("There is no more room around that village")
            return
        }


        village.gold -= costGold
        village.wood -= costWood


        // For testing purposes this is uncommented at times.
//        newUnit.currentAction = .Moved
        self.availableUnits.append(destination!)
        destination!.unit = newUnit

        destination?.alpha = 0.0
        destination?.draw()
        destination?.runAction(SKAction.fadeInWithDuration(0.3))

        self.playSound("recruit", type: "mp3", loop: false)
        self.randomYesSound()
    }

    func buildTower(on: Tile) {
        if on.owner.player !== self.game?.currentPlayer {
            self.showToast("You can only build towers on your land")
            return
        }

        let village = on.owner
        if village.disaled {
            self.showToast("That village is busy")
            return
        }

        // Check tower construction rules
        if village.type == .Hovel { return }
        let tower = Constants.Types.Structure.Tower
        if village.wood < tower.cost() {
            self.showToast("You don't have enought wood")
            return
        }
        if !on.isBuildable() {
            self.showToast("Can't build there")
            return
        }

        // Update the state
        village.wood -= tower.cost()
        on.structure = tower
        on.land = .Grass

        // update ui
        on.draw()
        on.alpha = 0
        on.runAction(SKAction.fadeInWithDuration(0.3))

        self.playShortSound("build-upgrade", type: "wav")
    }

    // Moves unit from -> on, instruct unit to start building road.
    func buildRoad(from: Tile, on: Tile) {
        if from.owner.player !== self.game?.currentPlayer {
            self.showToast("You don't own that tile")
            return
        }
        if from.unit == nil {
            self.showToast("There are no units that can build")
            return
        }
        let village = from.owner

        // Tiles must be connected and in the same region
        if village !== on.owner {
            self.showToast("You can only build in the same region")
            return
        }

        let path = (self.map?.getPath(from: from, to: on, accessible: village.controlledTiles))!
        if from !== on {
            if path.isEmpty {
                self.showToast("Your worker can't reach that tile")
                return
            }
            if !on.isBuildable() {
                self.showToast("You can't build there")
                return
            }
        } else {
            if on.structure != nil {
                self.showToast("You can't build there")
                return
            }
        }

        // Check road building rules
        let road = Constants.Types.Structure.Road
        if village.wood < road.cost() {
            self.showToast("You lack the resources")
            return
        }
        if (from.unit?.disabled)! {
            self.showToast("That unit is busy")
            return
        }
        if from.unit?.type != Constants.Types.Unit.Peasant{
            self.showToast("Only peasants can build")
            return
        }

        // Change the state.
        village.wood -= road.cost()

        // Move the unit
        if from !== on {
            self.moveWithAnimation(to: on, from: from, path: path, state: .BuildingRoad)
        }

        self.availableUnits = self.availableUnits.filter({ $0 !== from })

        self.playShortSound("build-upgrade", type: "wav")
    }

    // Moves unit from -> on, instruct unit to start creating meadow for 2 turns
    func startCultivating(from: Tile, on: Tile) {
        if from.owner.player !== self.game?.currentPlayer {
            self.showToast("You don't own that tile")
            return
        }
        if from.unit == nil {
            self.showToast("There doesn't seem to be a unit there")
            return
        }
        if on.land != .Grass{
            self.showToast("That land isn't ready for cultivation")
            return
        }

        let village = from.owner

        //Tiles must be connected and in the same region
        if village !== on.owner {
            self.showToast("You can only cultivate in the same region")
            return
        }

        let path = (self.map?.getPath(from: from, to: on, accessible: village.controlledTiles))!
        if from !== on {
            if path.isEmpty {
                self.showToast("Your worker can't reach that tile")
                return
            }
            if !on.isBuildable() {
                self.showToast("You can't build there")
                return
            }
        } else {
            if on.structure != nil {
                self.showToast("You can't build there")
                return
            }
        }

        // Check cultivation rules
        let cost = Constants.Types.Land.Meadow.cost()
        if village.wood < cost {
            self.showToast("You lack the resources to cultivate")
            return
        }
        if (from.unit?.disabled)! {
            self.showToast("That worker is diabled")
            return
        }
        if from.unit?.type != Constants.Types.Unit.Peasant {
            self.showToast("Only workers can cultivate")
            return
        }

        // Change the state
        village.wood -= cost

        // Move the unit
        if from !== on {
            self.moveWithAnimation(to: on, from: from, path: path, state: .StartCultivating)
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

    func showToast(msg: String, duration: NSTimeInterval = 5.0) {
        if let vc = MatchHelper.sharedInstance().vc as? GameViewController {
            vc.showToast(msg, duration: duration)
        }
    }

    // MARK: - UI Helper

    func getNextAvailableUnit() -> Tile? {
        if self.availableUnits.count <= 0 {
            self.showToast("All your units are busy")
            return nil
        }

        let nextTile = self.availableUnits.removeAtIndex(0)
        self.availableUnits.append(nextTile)

        return nextTile
    }

    func getNextAvailableVillage() -> Tile? {
        if self.availableVillages.count <= 0 {
            self.showToast("All you villages are busy")
            return nil
        }

        let nextTile = self.availableVillages.removeAtIndex(0)
        self.availableVillages.append(nextTile)
        self.map?.selected = nextTile

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
        self.startGameWithMap(3)
        self.beginTurn()
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
                    self.beginTurn()
                    if (self.game?.roundCount)! % 3 == 0 {
                        self.growTrees()
                    }
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
