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

	func addGold(amount: Int) {
		self.gold += amount
	}

	func addWood(amount: Int) {
		self.gold = self.gold + amount
	}

	func upgradeVillage(newType: Constants.Types.Village) {
		//TODO Remove gold from bank
		self.type = newType
	}

	func addTiles(tile: Tile) {
		controlledTiles.append(tile)
	}


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
}
