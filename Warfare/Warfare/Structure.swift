import Foundation

class Structure {
	private let type: Constants.Types.Structure
	private let position: Tile

	init(newType: Constants.Types.Structure, position: Tile) {
		self.type = newType
		self.position = position
	}

	func getStructureType() -> Constants.Types.Structure {
		return self.type
	}

	func getStructurePosition() -> Tile {
		return self.position
	}
}
