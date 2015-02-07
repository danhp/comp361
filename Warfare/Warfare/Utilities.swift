//
//  Utilities.swift
//  Warfare
//
//  Created by Justin Domingue on 2015-01-27.
//  Copyright (c) 2015 Justin Domingue. All rights reserved.
//

import Foundation
import SpriteKit

class Utilities {
    class func arrayToAxialCoordinates(#row: Int, col: Int) -> (x: Int, y: Int) {
        return (col - (row-(row&1)) / 2, row)
    }
    
    class Colors {
        class func colorForLandType(l: Constants.Types.Land) -> UIColor {
            var color: UIColor
            
            switch l {
            case .Sea:
                color = UIColor.blueColor()
            case .Grass:
                color = UIColor.greenColor()
            case .Tree:
                color = UIColor.brownColor()
            case .Meadow:
                color = UIColor.yellowColor()
            }
            
            return color
        }
    }
}