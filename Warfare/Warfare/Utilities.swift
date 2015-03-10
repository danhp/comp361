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
            switch l {
            case .Sea:
                return UIColor.blueColor()
            case .Grass:
                return UIColor.greenColor()
            case .Tree:
                return UIColor.brownColor()
            case .Meadow:
                return UIColor.yellowColor()
            }
        }
        
        class func colorForPlayer(id: Int) -> UIColor {
            switch id {
            case 0:
                return UIColor.orangeColor()
            case 1:
                return UIColor.purpleColor()
            case 2:
                return UIColor.redColor()
            default:
                return UIColor.whiteColor()
            }
        }
        
        struct Tile {
            static let strokeColor = UIColor.whiteColor()
        }
    }
}