import SpriteKit
import Foundation

class Village {
	var node: SKLabelNode?
    var player: Player?
	var type = Constants.Types.Village.Hovel
	var gold: Int = 0
	var wood: Int = 0

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
		if self.type.rawValue < 2 && self.wood >= Constants.Cost.Upgrade.Village.rawValue {
			self.wood -= Constants.Cost.Upgrade.Village.rawValue
			self.type = Constants.Types.Village(rawValue: self.type.rawValue + 1)!
		}
	}

	func upgradeUnit(unit: Unit, newType: Constants.Types.Unit) {
		if !self.containsUnit(unit) { return }

		let upgradeInterval = newType.rawValue - unit.type.rawValue

		if upgradeInterval >= 1 && self.gold >= upgradeInterval * Constants.Cost.Upgrade.Unit.rawValue {
			self.gold -= upgradeInterval * Constants.Cost.Upgrade.Unit.rawValue
			unit.type = newType
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
    
    func clearRegion() {
        for t in self.controlledTiles {
            t.clear()
        }
    }

	// MARK - Drawing

	func draw() -> SKLabelNode {
		switch self.type {
		case .Hovel:
			node = SKLabelNode(text: "Hovel")
		case .Town:
			node = SKLabelNode(text: "Town")
		case .Fort:
			node = SKLabelNode(text: "Frot")
		}
		return node!
	}

    // MARK - Serialization
    
    func serialize() -> NSDictionary {
        var dict = [String: AnyObject]()
        
        dict["type"] = self.type.rawValue
        dict["gold"] = self.gold
        dict["wood"] = self.wood
        dict["controlledTiles"] = self.controlledTiles.map({$0.serialize()})
        
        return dict
    }
    
    func deserialize(dict: NSDictionary) {
        self.type = Constants.Types.Village(rawValue: dict["type"] as Int)!
        self.gold = dict["gold"] as Int
        self.wood = dict["wood"] as Int
        
        // TILES
        if let controlled = dict["controlledTiles"] as? NSArray {
            for t in controlled {    // t is NSDictionary
                self.controlledTiles.append(Tile(dict: t as NSDictionary, ownerVillage: self))
            }
        }
    }
}
