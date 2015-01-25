import Foundation

class Village {
	private var type: Constants.Types.VillageType
	private var gold: Int
	private var wood: Int

	private let position: Tile
	private var controlledTiles: Array<Tile>

	init(tile: Tile) {
		self.type = Constants.Types.VillageType.Hovel
		self.gold = 0
		self.wood = 0

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

	func upgradeVillage(newType: Constants.Types.VillageType) {
		//TODO Remove gold from bank
		self.type = newType
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

	func getVillageType() -> Constants.Types.VillageType {
		return self.type
	}

	func getVillagePosition() -> Tile {
		return self.position
	}

	func getVillageControlledTiles() -> Array<Tile> {
		return self.controlledTiles
	}
}
