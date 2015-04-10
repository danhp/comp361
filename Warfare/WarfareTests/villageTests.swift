import UIKit
import XCTest

class villageTest: XCTestCase {

//    func testUpgradeVillage() {
//        let tile = Tile(coordinates: (0,0))
//        let village = Village()
//
//        village.wood = 0
//        village.wood += 10
//        XCTAssertEqual(village.wood, 10)
//
//        XCTAssertEqual(village.type, Constants.Types.Village.Hovel)
//
//        village.upgradeVillage()
//        XCTAssertEqual(village.type, Constants.Types.Village.Town)
//        XCTAssertEqual(village.wood, 2)
//
//        village.upgradeVillage()
//        XCTAssertEqual(village.type, Constants.Types.Village.Town)
//        XCTAssertEqual(village.wood, 2)
//
//        village.wood += 6
//        XCTAssertEqual(village.wood, 8)
//
//        village.state = .ReadyForOrders
//        village.upgradeVillage()
//        XCTAssertEqual(village.type, Constants.Types.Village.Fort)
//        XCTAssertEqual(village.wood, 0)
//
//        village.wood += 8
//        village.upgradeVillage()
//        XCTAssertEqual(village.type, Constants.Types.Village.Fort)
//        XCTAssertEqual(village.wood, 8)
//    }

    func testUpgradeUnit() {
        let tile = Tile(coordinates: (0,0))
        let village = Village()

        let tile2 = Tile(coordinates: (0,1))
        let unit = Unit(type: Constants.Types.Unit.Peasant)


        tile.unit = unit
        village.addTile(tile)
        village.gold = 0


        village.upgradeUnit(tile, newType: Constants.Types.Unit.Infantry)
        XCTAssertEqual(unit.type, Constants.Types.Unit.Peasant)

        village.gold += 10
        village.upgradeUnit(tile, newType: Constants.Types.Unit.Infantry)
        XCTAssertEqual(village.gold, 0)
        XCTAssertEqual(unit.type, Constants.Types.Unit.Infantry)

        village.gold += 15
        village.upgradeUnit(tile, newType: Constants.Types.Unit.Knight)
        XCTAssertEqual(unit.type, Constants.Types.Unit.Infantry)
        XCTAssertEqual(village.gold, 15)

        village.gold += 5
        village.upgradeUnit(tile, newType: Constants.Types.Unit.Knight)
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
