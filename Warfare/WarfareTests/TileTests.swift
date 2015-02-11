//
//  Tile.swift
//  Warfare
//
//  Created by Justin Domingue on 2015-02-10.
//  Copyright (c) 2015 Justin Domingue. All rights reserved.
//

import UIKit
import XCTest

class TileTests: XCTestCase {
    func testReplaceTombstone() {
        let t = Tile(coordinates: (0,0))
        t.structure = Constants.Types.Structure.Tombstone
        
        XCTAssertEqual((t.structure?)!, Constants.Types.Structure.Tombstone)
        
        t.replaceTombstone()

        XCTAssertTrue(t.structure? == nil, "Tile structure should be nil after removing tombstone.")
        XCTAssertEqual(t.land, Constants.Types.Land.Tree, "Tile land type should be tree.")
    }
    
    func testMakeRoadOrMeadow() {
        let t = Tile(coordinates: (0,0))
        t.unit = Unit(type: .Peasant, tile: t)
        
        // Test Roads
        t.unit?.currentAction = .BuildingRoad
        
        t.makeRoadOrMeadow()
        
        XCTAssertEqual((t.structure?)!, Constants.Types.Structure.Road, "Tile structure should be road after building")
        XCTAssertEqual((t.unit?.currentAction)!, Constants.Unit.Action.ReadyForOrders, "Tile unit should be ready for orders")
        
        // Test Meadows
        t.clear()
        t.land = .Meadow
        t.unit = Unit(type: .Peasant, tile: t)
        t.unit?.currentAction = .FinishCultivating
        
        t.makeRoadOrMeadow()
        
        XCTAssertEqual(t.land, Constants.Types.Land.Grass, "Meadow should be replaced by grass")
        XCTAssertEqual((t.unit?.currentAction)!, Constants.Unit.Action.ReadyForOrders, "Tile unit should be ready for orders")
    }
}
