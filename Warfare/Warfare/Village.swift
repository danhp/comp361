import SpriteKit
import Foundation

class Village {
	var node: SKNode?
    var player: Player?
	var type = Constants.Types.Village.Hovel
	var gold: Int = 0
	var wood: Int = 0

	var health: Int = 1

    var controlledTiles: [Tile] = [Tile]()

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

		let newLevel = Constants.Types.Village(rawValue: self.type.rawValue + 1)
		let cost = newLevel?.upgradeCost()

		if self.wood >= cost {
			self.wood -= cost!
			self.type = newLevel!
			self.health = self.type.health()
		}
	}

	func upgradeUnit(unit: Unit, newType: Constants.Types.Unit) {
		if !self.containsUnit(unit) { return }
		if unit.type == .Knight { return }

		let upgradeInterval = newType.rawValue - unit.type.rawValue

		if upgradeInterval >= 1 && self.gold >= upgradeInterval * Constants.Cost.Upgrade.Unit.rawValue {
			self.gold -= upgradeInterval * Constants.Cost.Upgrade.Unit.rawValue
			unit.type = newType
			unit.currentAction = .UpgradingCombining
		}
	}

	func containsUnit(unit: Unit) -> Bool {
		for tile in self.controlledTiles {
			if tile.unit === unit {
				return true
			}
		}

		return false
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
        node?.setScale(0.5)
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
		self.health = dict["health"] as Int
        
        // TILES
        if let controlled = dict["controlledTiles"] as? NSArray {
            for t in controlled {    // t is NSDictionary
                self.controlledTiles.append(Tile(dict: t as NSDictionary, ownerVillage: self))
            }
        }
    }
}
