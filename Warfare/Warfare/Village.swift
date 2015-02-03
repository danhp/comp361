import Foundation

class Village {
	private var type = Constants.Types.Village.Hovel
	private var gold: Int = 0
	private var wood: Int = 0

	private let position: Tile
	private var controlledUnits: Array<Unit> = Array<Unit>()
	private var controlledTiles: Array<Tile> = Array<Tile>()

	init(tile: Tile) {
		self.position = tile
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
		if (newType.rawValue - self.type.rawValue) == 1 && self.wood >= 8 {
			self.wood -= 8
			self.type = newType
		}
	}

	func addTile(tile: Tile) {
		controlledTiles.append(tile)
	}

	func addUnit(unit: Unit) {
		controlledUnits.append(unit)
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

	func getVillageControlledUnit() -> Array<Unit> {
		return self.controlledUnits
	}


	func upgradeUnit(unit: Unit, newType: Constants.Types.Unit) {
		if !self.containsUnit(unit) { return }

		let upgradeInterval = newType.rawValue - unit.getUnitType().rawValue

		if upgradeInterval >= 1 && self.gold >= upgradeInterval * 10 {
			self.gold -= 10 * upgradeInterval
			unit.upgradeUnit(newType)
		}

		
	}

	func containsUnit(unit: Unit) -> Bool {
		for element in self.controlledUnits {
			if element === unit {
				return true
			}
		}

		return false
	}
}
