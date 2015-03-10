import UIKit
import XCTest

class gameTests: XCTestCase {
    var map = Map()
    var player1 = Player()
    var player2 = Player()
    var player3 = Player()
    var players = [Player]()
    var ge = GameEngine()

    override func setUp() {
        super.setUp()

        let a : [[Tile]] = [
            [Tile(coordinates: (0,0)), Tile(coordinates: (1,0)), Tile(coordinates: (2,0)), Tile(coordinates: (3,0)), Tile(coordinates: (4,0)), Tile(coordinates: (5,0))],
            [Tile(coordinates: (0,1)), Tile(coordinates: (1,1)), Tile(coordinates: (2,1)), Tile(coordinates: (3,1)), Tile(coordinates: (4,1)), Tile(coordinates: (5,1))],
            [Tile(coordinates: (-1,2)), Tile(coordinates: (0,2)), Tile(coordinates: (1,2)), Tile(coordinates: (2,2)), Tile(coordinates: (3,2)), Tile(coordinates: (4,2))],
            [Tile(coordinates: (-1,3)), Tile(coordinates: (0,3)), Tile(coordinates: (1,3)), Tile(coordinates: (2,3)), Tile(coordinates: (3,3)), Tile(coordinates: (4,3))],
            [Tile(coordinates: (-2,4)), Tile(coordinates: (-1,4)), Tile(coordinates: (0,4)), Tile(coordinates: (1,4)), Tile(coordinates: (2,4)), Tile(coordinates: (3,4))],
            [Tile(coordinates: (-2,5)), Tile(coordinates: (-1,5)), Tile(coordinates: (0,5)), Tile(coordinates: (1,5)), Tile(coordinates: (2,5)), Tile(coordinates: (3,5))]]

        map = Map(array: a)
        players.append(player1)
        players.append(player2)
        players.append(player3)
        ge.game = Game(players: players, playerOrder: [0, 1, 2], map: map)
    }

    func testMoveUnit() {
        let tiles = map.tiles
        var unit = Unit(type: Constants.Types.Unit.Knight)
        var village = Village()
        ge.game?.currentPlayer.addVillage(village)
        tiles[3, 5]?.owner = village

        tiles[3, 4]?.unit = unit
        tiles[3, 2]?.land = .Tree
        village.addTile(tiles[3, 5]!)
        village.addTile(tiles[3, 4]!)
        village.addTile(tiles[3, 3]!)
        village.addTile(tiles[3, 2]!)

        ge.game?.moveUnit(tiles[3,4]!, to: tiles[3,2]!)
        XCTAssertTrue(tiles[3, 2]?.unit == nil)

        unit.type = Constants.Types.Unit.Peasant

        ge.game?.moveUnit(tiles[3,4]!, to: tiles[3,2]!)

        XCTAssertTrue(tiles[3,2]?.unit === unit)
        XCTAssertNil(tiles[3,4]?.unit)
        XCTAssertTrue(tiles[3, 4]?.land == Constants.Types.Land.Grass)
        XCTAssertTrue(village.wood == 1)

        tiles[3, 3]?.structure = Constants.Types.Structure.Tombstone
        ge.game?.moveUnit(tiles[3, 2]!, to: tiles[3, 3]!)
        XCTAssertTrue(tiles[3, 3]?.structure != nil)
        unit.currentAction = .ReadyForOrders
        ge.game?.moveUnit(tiles[3, 2]!, to: tiles[3, 3]!)
        XCTAssertTrue(tiles[3, 3]?.structure == nil)

        unit.currentAction = .ReadyForOrders
        XCTAssertTrue(!contains(village.controlledTiles, {$0 === tiles[3, 1]!}))
        ge.game?.moveUnit(tiles[3, 3]!, to: tiles[2, 2]!)
        XCTAssertTrue(contains(village.controlledTiles, {$0 === tiles[2, 2]!}))

        var village2 = Village()
        village2.wood = 30
        village2.upgradeVillage()
        village2.addTile(tiles[1, 0]!)
        village2.addTile(tiles[1, 1]!)
        village2.addTile(tiles[0, 2]!)
        // TODO: watch it.
        tiles[1, 1]?.owner = village2
        tiles[1, 1]?.village = village2.type
        ge.game?.currentPlayer.addVillage(village2)

        var village3 = Village()
        village3.wood = 30
        village3.upgradeVillage()
        village3.upgradeVillage()
        village3.addTile(tiles[3, 0]!)
        village3.addTile(tiles[4, 0]!)
        village3.addTile(tiles[5, 0]!)
        tiles[3, 0]?.owner = village3
        tiles[3, 0]?.village = village3.type
        ge.game?.currentPlayer.addVillage(village3)

        // 3-way merge
        unit.currentAction = .ReadyForOrders
        XCTAssertEqual(village.wood, 1)
        XCTAssertEqual(village2.wood, 22)
        XCTAssertEqual(village3.wood, 14)
        XCTAssertEqual((ge.game?.currentPlayer.villages.count)!, 3)
        XCTAssertNotEqual(unit.type, Constants.Types.Unit.Knight)
        ge.game?.moveUnit(tiles[2, 2]!, to: tiles[2, 1]!)
        XCTAssertTrue(contains(village2.controlledTiles, {$0 === tiles[2, 1]}))
        XCTAssertEqual(village3.wood, 37)
        XCTAssertTrue(tiles[3, 5]?.village == nil)
        XCTAssertTrue(tiles[1, 1]?.village == nil)
        XCTAssertTrue(tiles[3, 0]?.village != nil)
        XCTAssertTrue(contains(village3.controlledTiles, {$0 === tiles[3, 0]}))
        XCTAssertTrue(contains(village3.controlledTiles, {$0 === tiles[3, 5]}))
        XCTAssertTrue(contains(village3.controlledTiles, {$0 === tiles[1, 1]}))
        XCTAssertEqual((ge.game?.currentPlayer.villages.count)!, 1)

        // Invade
        // TODO: Prone to break.
        ge.game?.endTurn()
        
        var enemyUnit = Unit(type: Constants.Types.Unit.Knight)
        var enemyVillage = Village()
        ge.game?.currentPlayer.addVillage(enemyVillage)

        enemyVillage.addTile(tiles[1, 2]!)
        enemyVillage.addTile(tiles[1, 3]!)
        enemyVillage.addTile(tiles[0, 3]!)
        tiles[1, 2]?.unit = enemyUnit

        ge.game?.moveUnit(tiles[1, 2]!, to: tiles[2, 1]!)
        XCTAssertTrue(tiles[2, 1]?.unit === enemyUnit)
//        XCTAssertEqual(players[0].villages.count, 3)

        tiles[1, 0]?.unit = unit
        enemyUnit.currentAction = .ReadyForOrders
        ge.game?.moveUnit(tiles[2, 1]!, to: tiles[1, 1]!)
//        XCTAssertEqual(players[0].villages.count, 2)
        XCTAssertTrue(tiles[1, 0]?.structure == Constants.Types.Structure.Tombstone)

    }
}
