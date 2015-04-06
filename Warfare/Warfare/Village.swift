import SpriteKit
import Foundation

class Village {
    var node: SKNode?
    var player: Player?
    var type = Constants.Types.Village.Hovel
    var state = Constants.Village.Action.ReadyForOrders
    var gold: Int = 7
    var wood: Int = 7

    var health: Int = 1

    var controlledTiles: [Tile] = [Tile]()

    var disaled: Bool {
        get {
            return self.state != .ReadyForOrders
        }
    }

    init() { }

    init(dict: NSDictionary, owner: Player) {
        self.player = owner
        self.deserialize(dict)
    }

    func addTile(tile: Tile) {
        controlledTiles.append(tile)
        tile.owner = self
    }

    func removeTile(tile: Tile) {
        controlledTiles = controlledTiles.filter({ $0 !== tile })
        tile.owner = nil
    }

    func upgradeVillage() {
        if self.type == Constants.Types.Village.Castle { return }
        if self.disaled { return }

        let newLevel = Constants.Types.Village(rawValue: self.type.rawValue + 1)
        let cost = newLevel?.upgradeCost()
        if cost > self.wood { return }

        self.wood -= cost!
        self.type = newLevel!
        self.health = self.type.health()

        self.state = .Upgrading1
    }

    func upgradeUnit(unitTile: Tile, newType: Constants.Types.Unit) {
        if let unit = unitTile.unit {
            if unitTile.owner !== self { return }
            if unit.type == .Knight || unit.type == .Canon { return }

            let upgradeInterval = newType.rawValue - unit.type.rawValue

            if upgradeInterval < 1 { return }
            if self.gold < upgradeInterval * Constants.Cost.Upgrade.Unit.rawValue { return }

            self.gold -= upgradeInterval * Constants.Cost.Upgrade.Unit.rawValue
            unit.type = newType
            unit.currentAction = .UpgradingCombining
        }
    }

    func compareTo(village: Village) -> Bool {
        if self.type.rawValue > village.type.rawValue {
            return true
        } else {
            return false
        }
    }

    func attacked() {
        self.health -= 1
    }

    func clearRegion() {
        for t in self.controlledTiles {
            t.clear()
        }
    }

    // MARK - Drawing

    func draw() -> SKNode {
        node = SKSpriteNode(imageNamed: self.type.name())
        return node!
    }

    // MARK - Serialization

    func serialize() -> NSDictionary {
        var dict = [String: AnyObject]()

        dict["type"] = self.type.rawValue
        dict["gold"] = self.gold
        dict["wood"] = self.wood
        dict["health"] = self.health
        dict["controlledTiles"] = self.controlledTiles.map({$0.serialize()})

        return dict
    }

    func deserialize(dict: NSDictionary) {
        self.type = Constants.Types.Village(rawValue: dict["type"] as Int)!
        self.gold = dict["gold"] as Int
        self.wood = dict["wood"] as Int
        self.health = dict["health"] as? Int ?? self.type.health()

        // TILES
        if let controlled = dict["controlledTiles"] as? NSArray {
            for t in controlled {    // t is NSDictionary
                self.controlledTiles.append(Tile(dict: t as NSDictionary, ownerVillage: self))
            }
        }
    }
}
