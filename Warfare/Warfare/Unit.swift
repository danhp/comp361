import Foundation

class Unit {
	private var type: Constants.Types.UnitType
	private var position: Tile
	private var currentAction: Constants.Types.UnitAction

	init(type: Constants.Types.UnitType, tile: Tile) {
		self.type = type
		self.position = tile
		self.currentAction = Constants.Types.UnitAction.Idle
	}

	//Setters
	func upgradeUnit(newType: Constants.Types.UnitType) {
		self.type = newType
	}

	func moveUnit(destination: Tile) {
		self.position = destination
	}

	func setUnitAction(action: Constants.Types.UnitAction) {
		self.currentAction = action
	}

	//Getters
	func getUnitType() -> Constants.Types.UnitType {
		return self.type
	}

	func getUnitPosition() -> Tile {
		return self.position
	}

	func getUnitAction() -> Constants.Types.UnitAction {
		return self.currentAction
	}
}
