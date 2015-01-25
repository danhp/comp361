import Foundation

class Structure {
	private let type: Constants.Types.StructureType
	private let position: Tile

	init(newType: Constants.Types.StructureType, position: Tile) {
		self.type = newType
		self.position = position
	}

	func getStructureType() -> Constants.Types.StructureType {
		return self.type
	}

	func getStructurePosition() -> Tile {
		return self.position
	}
}
