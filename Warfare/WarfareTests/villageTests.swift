import UIKit
import XCTest

class villageTest: XCTestCase {

	func testUpgradeVillage() {
		let tile = Tile(coordinates: (0,0))
		let village = Village()

		village.wood += 10
		XCTAssertEqual(village.wood, 10)

		village.upgradeVillage(Constants.Types.Village.Fort)
		XCTAssertEqual(village.type, Constants.Types.Village.Hovel)

		village.upgradeVillage(Constants.Types.Village.Town)
		XCTAssertEqual(village.type, Constants.Types.Village.Town)
		XCTAssertEqual(village.wood, 2)

		village.upgradeVillage(Constants.Types.Village.Hovel)
		XCTAssertEqual(village.type, Constants.Types.Village.Town)
		XCTAssertEqual(village.wood, 2)

		village.upgradeVillage(Constants.Types.Village.Fort)
		XCTAssertEqual(village.type, Constants.Types.Village.Town)
		XCTAssertEqual(village.wood, 2)

		village.wood += 6
		XCTAssertEqual(village.wood, 8)

		village.upgradeVillage(Constants.Types.Village.Fort)
		XCTAssertEqual(village.type, Constants.Types.Village.Fort)
		XCTAssertEqual(village.wood, 0)
	}

	func testUpgradeUnit() {
		let tile = Tile(coordinates: (0,0))
		let village = Village()

		let tile2 = Tile(coordinates: (0,1))
		let unit = Unit(type: Constants.Types.Unit.Peasant, tile: tile2)

		XCTAssertFalse(village.containsUnit(unit))

		tile.unit = unit
		village.controlledTiles.append(tile)

		XCTAssertTrue(village.containsUnit(unit))

		village.upgradeUnit(unit, newType: Constants.Types.Unit.Infantry)
		XCTAssertEqual(unit.type, Constants.Types.Unit.Peasant)

		village.gold += 10
		village.upgradeUnit(unit, newType: Constants.Types.Unit.Infantry)
		XCTAssertEqual(unit.type, Constants.Types.Unit.Infantry)
		XCTAssertEqual(village.gold, 0)

		village.gold += 15
		village.upgradeUnit(unit, newType: Constants.Types.Unit.Knight)
		XCTAssertEqual(unit.type, Constants.Types.Unit.Infantry)
		XCTAssertEqual(village.gold, 15)

		village.gold += 5
		village.upgradeUnit(unit, newType: Constants.Types.Unit.Knight)
		XCTAssertEqual(unit.type, Constants.Types.Unit.Knight)
		XCTAssertEqual(village.gold, 0)
	}

	func testAddRemoveTile() {
		let tile = Tile(coordinates: (0,0))
		let village = Village()

		let tile2 = Tile(coordinates: (1,1))

		village.addTile(tile2)
		XCTAssertTrue(contains(village.controlledTiles, {$0 === tile2}))

		village.removeTile(tile2)
		XCTAssertFalse(contains(village.controlledTiles, {$0 === tile2}))
	}
}
