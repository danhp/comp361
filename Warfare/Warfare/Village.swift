import Foundation

class Village {
	private var type = Constants.Types.Village.Hovel
	private var gold: Int = 0
	private var wood: Int = 0

	private let position: Tile
	private var controlledTiles: Array<Tile>

	init(tile: Tile) {
		self.position = tile
		controlledTiles = Array<Tile>()
	}

	//Setters
	func addGold(amount: Int) {
		self.gold += amount
	}
	func removeGold(amount: Int) {
		self.gold -= amount
	}

	func addWood(amount: Int) {
		self.wood += amount
	}
	func removeWood(amount: Int) {
		self.wood -= amount
	}

	func upgradeVillage(newType: Constants.Types.Village) {
		if self.isLegalUpgrade(newType) {
			self.wood -= 8 * (newType.rawValue - self.type.rawValue)
			self.type = newType
		}
	}

	func addTiles(tile: Tile) {
		controlledTiles.append(tile)
	}

	//Getters
	func getVillageGold() -> Int {
		return self.gold
	}

	func getVillageWood() -> Int {
		return self.wood
	}

	func getVillageType() -> Constants.Types.Village {
		return self.type
	}

	func getVillagePosition() -> Tile {
		return self.position
	}

	func getVillageControlledTiles() -> Array<Tile> {
		return self.controlledTiles
	}


	func isLegalUpgrade(newType: Constants.Types.Village) -> Bool {
		if (newType.rawValue - self.type.rawValue) == 1 && self.wood >= 8 ||
		   (newType.rawValue - self.type.rawValue) == 2 && self.wood >= 16 {
			return true
		} else {
			return false
		}
	}
}
