import Foundation

class Unit {
	var type: Constants.Types.Unit
	var position: Tile
	var currentAction: Constants.Unit.Action

    var disabled: Bool {
        get {
            return self.currentAction != .ReadyForOrders
        }
    }
    
	init(type: Constants.Types.Unit, tile: Tile) {
		self.type = type
		self.position = tile
		self.currentAction = .ReadyForOrders
	}
}
