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
        
        XCTAssertEqual((t.structure)!, Constants.Types.Structure.Tombstone)
        
        t.replaceTombstone()

        XCTAssertTrue(t.structure == nil, "Tile structure should be nil after removing tombstone.")
        XCTAssertEqual(t.land, Constants.Types.Land.Tree, "Tile land type should be tree.")
    }
}
