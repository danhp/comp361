import SpriteKit
import Foundation

class Village {
    var node: SKNode?
    var player: Player?
    var type = Constants.Types.Village.Hovel
    var state = Constants.Village.Action.ReadyForOrders
    var gold: Int = 7
    var wood: Int = 7
    var upkeep: Int { return self.controlledTiles.reduce(0) {$0 + $1.wage()} }
    var income: Int { return self.controlledTiles.reduce(0) {$0 + $1.goldValue()} }

    var health: Int = 1
    var isSmoking: Bool = false
    var isBurning: Bool = false

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
        if self.type == Constants.Types.Village.Castle {
            GameEngine.Instance.showToast("You can't upgrade a castle")
            return
        }
        if self.disaled {
            GameEngine.Instance.showToast("That village is busy")
            return
        }

        let newLevel = Constants.Types.Village(rawValue: self.type.rawValue + 1)
        let cost = newLevel?.upgradeCost()
        if cost > self.wood {
            GameEngine.Instance.showToast("That village lacks the resources to upgrade")
            return
        }

        self.wood -= cost!

        self.state = .Upgrading1
    }

    func upgradeUnit(unitTile: Tile, newType: Constants.Types.Unit) {
        if let unit = unitTile.unit {
            if unitTile.owner !== self {
                GameEngine.Instance.showToast("You don't own that tile")
                return
            }
            if unit.type == .Knight || unit.type == .Canon {
                GameEngine.Instance.showToast("That unit has reached his maximum potential")
                return
            }

            let upgradeInterval = newType.rawValue - unit.type.rawValue

            if upgradeInterval < 1 {
                GameEngine.Instance.showToast("That upgrade isn't legal")
                return
            }
            if self.gold < upgradeInterval * Constants.Cost.Upgrade.Unit.rawValue {
                GameEngine.Instance.showToast("You don't have the resoureces to upgrade the unit")
                return
            }

            self.gold -= upgradeInterval * Constants.Cost.Upgrade.Unit.rawValue
            unit.type = newType
            unit.currentAction = .UpgradingCombining
        } else {
            GameEngine.Instance.showToast("There are no units to upgrade there")
        }
    }

    func compareTo(village: Village) -> Bool {
        if self.type == village.type {
            if self.state != .ReadyForOrders {
                return true
            }
            if village.state != .ReadyForOrders {
                return false
            }
        }

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
        node = SKNode()

        if self.isSmoking {
            let smokePath = NSBundle.mainBundle().pathForResource("smoke", ofType: "sks")
            let smoke = NSKeyedUnarchiver.unarchiveObjectWithFile(smokePath!) as SKEmitterNode
            self.node?.addChild(smoke)
        } else if self.isBurning {
            let firePath = NSBundle.mainBundle().pathForResource("fire", ofType: "sks")
            let fire = NSKeyedUnarchiver.unarchiveObjectWithFile(firePath!) as SKEmitterNode
            self.node?.addChild(fire)
        }

        self.node?.addChild(SKSpriteNode(imageNamed: self.type.name()))


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
