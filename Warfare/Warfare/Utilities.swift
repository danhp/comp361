//
//  Utilities.swift
//  Warfare
//
//  Created by Justin Domingue on 2015-01-27.
//  Copyright (c) 2015 Justin Domingue. All rights reserved.
//

import Foundation
import SpriteKit

extension UIColor {
    convenience init(rgb: UInt, alpha: CGFloat) {
        self.init(
            red: CGFloat((rgb & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgb & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgb & 0x0000FF) / 255.0,
            alpha: CGFloat(alpha)
        )
    }
}

class Utilities {
    class func arrayToAxialCoordinates(#row: Int, col: Int) -> (x: Int, y: Int) {
        return (col - (row-(row&1)) / 2, row)
    }
    
    class Colors {
        class func colorForLandType(l: Constants.Types.Land, lighten: Bool = false) -> UIColor {
            let alpha: CGFloat = lighten ? 0.5 : 1
            
            switch l {
            case .Sea:
                return UIColor(rgb: 0x588c7e, alpha: alpha)
            case .Grass, .Tree:
                return UIColor(rgb: 0x1b4001, alpha: alpha)
            case .Meadow:
                return UIColor(rgb: 0xffe6c5, alpha: alpha)
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