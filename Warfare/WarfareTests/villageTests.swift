import UIKit
import XCTest

class villageTest: XCTestCase {
	func testInit() {
		let tile = Tile(coordinates: (0,0))
		let village = Village(tile: tile)

		XCTAssertEqual(village.getVillagePosition(), tile)
		XCTAssertEqual(village.getVillageType(), Constants.Types.Village.Hovel)
		XCTAssertEqual(village.getVillageGold(), 0)
		XCTAssertEqual(village.getVillageWood(), 0)
	}

	func testUpgrade() {
		let tile = Tile(coordinates: (0,0))
		let village = Village(tile: tile)

		village.addWood(10)
		XCTAssertEqual(village.getVillageWood(), 10)

		village.upgradeVillage(Constants.Types.Village.Fort)
		XCTAssertEqual(village.getVillageType(), Constants.Types.Village.Hovel)

		village.upgradeVillage(Constants.Types.Village.Town)
		XCTAssertEqual(village.getVillageType(), Constants.Types.Village.Town)
		XCTAssertEqual(village.getVillageWood(), 2)

		village.upgradeVillage(Constants.Types.Village.Hovel)
		XCTAssertEqual(village.getVillageType(), Constants.Types.Village.Town)
		XCTAssertEqual(village.getVillageWood(), 2)

		village.upgradeVillage(Constants.Types.Village.Fort)
		XCTAssertEqual(village.getVillageType(), Constants.Types.Village.Town)
		XCTAssertEqual(village.getVillageWood(), 2)

		village.addWood(6)
		XCTAssertEqual(village.getVillageWood(), 8)

		village.upgradeVillage(Constants.Types.Village.Fort)
		XCTAssertEqual(village.getVillageType(), Constants.Types.Village.Fort)
		XCTAssertEqual(village.getVillageWood(), 0)
	}

	func testUpgradeUnit() {
		let tile = Tile(coordinates: (0,0))
		let village = Village(tile: tile)

		let tile2 = Tile(coordinates: (0,1))
		let unit = Unit(type: Constants.Types.Unit.Peasant, tile: tile2)

		XCTAssertEqual(village.containsUnit(unit), false)

		village.addUnit(unit)
		XCTAssertEqual(village.containsUnit(unit), true)
		village.upgradeUnit(unit, newType: Constants.Types.Unit.Infantry)
		XCTAssertEqual(unit.getUnitType(), Constants.Types.Unit.Peasant)

		village.addGold(10)
		village.upgradeUnit(unit, newType: Constants.Types.Unit.Infantry)
		XCTAssertEqual(unit.getUnitType(), Constants.Types.Unit.Infantry)
		XCTAssertEqual(village.getVillageGold(), 0)

		village.addGold(15)
		village.upgradeUnit(unit, newType: Constants.Types.Unit.Knight)
		XCTAssertEqual(unit.getUnitType(), Constants.Types.Unit.Infantry)
		XCTAssertEqual(village.getVillageGold(), 15)

		village.addGold(5)
		village.upgradeUnit(unit, newType: Constants.Types.Unit.Knight)
		XCTAssertEqual(unit.getUnitType(), Constants.Types.Unit.Knight)
		XCTAssertEqual(village.getVillageGold(), 0)
	}
}
