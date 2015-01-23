//
//  warfareTests.swift
//  warfareTests
//
//  Created by Justin Domingue on 2015-01-21.
//  Copyright (c) 2015 Justin Domingue. All rights reserved.
//

import UIKit
import XCTest

class warfareTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testAccess() {
		let a = [
			["00","10","20","30","40","50"],
			["01","11","21","31","41","51"],
			["-12","02","12","22","32","42"],
			["-13","03","13","23","33","43"],
			["-24","-14","04","14","24","34"],
			["-25","-15","05","15","25","35"]
		]
		
		let grid = HexGrid(array: a)
		
		XCTAssert("03" == grid[0,3])
		XCTAssert("-25" == grid[-2,5])
    }
}
