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

	
}