//
//  Utilities.swift
//  Warfare
//
//  Created by Justin Domingue on 2015-01-27.
//  Copyright (c) 2015 Justin Domingue. All rights reserved.
//

import Foundation

class Utilities {
    class func arrayToAxialCoordinates(#row: Int, col: Int) -> (x: Int, y: Int) {
        return (col - (row-(row&1)) / 2, row)
    }
}