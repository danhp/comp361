import Foundation

class Unit {
	private var type: Constants.Types.Unit
	private var position: Tile
	private var currentAction: Constants.Unit.Action

	init(type: Constants.Types.Unit, tile: Tile) {
		self.type = type
		self.position = tile
		self.currentAction = Constants.Unit.Action.Idle
	}

	func moveUnit(destination: Tile) {
		self.position = destination
	}

	func upgradeUnit(newType: Constants.Types.Unit) {
		self.type = newType
	}

	func setUnitAction(action: Constants.Unit.Action) {
		self.currentAction = action
	}

	func getUnitType() -> Constants.Types.Unit {
		return self.type
	}

	func getUnitPosition() -> Tile {
		return self.position
	}

	func getUnitAction() -> Constants.Unit.Action {
		return self.currentAction
	}
}
