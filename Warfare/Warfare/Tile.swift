//
//  Tile.swift
//  warfare
//
//  Created by Justin Domingue on 2015-01-21.
//  Copyright (c) 2015 Justin Domingue. All rights reserved.
//

import SpriteKit
import Darwin

class Tile: SKShapeNode {
    let coordinates: (Int, Int)
    
    init(coordinates: (Int, Int), landType: Constants.Types.Land = .Grass) {
        self.coordinates = coordinates
        
		super.init()
        
		self.path = makeHexagonalPath(CGFloat(Constants.Tile.size))
		
		// TEMPORARY
		var color = UIColor()
		let n = arc4random_uniform(5)
		
		if (n < 2) {
			color = UIColor.greenColor()
		} else if (n == 2) {
			color = UIColor.yellowColor()
		} else if (n == 3) {
			color = UIColor.blueColor()
		} else if (n == 4) {
			color = UIColor.redColor()
		}
		
		self.fillColor = color
	}

	func makeHexagonalPath(size: CGFloat) -> CGPath {
		let path = CGPathCreateMutable()
		
		for i in 0...5 {
			var angle: CGFloat = CGFloat(M_PI) / 3 * (CGFloat(i) + 0.5)
			var x = size * cos(angle)
			var y = size * sin(angle)
			
			if i == 0 {
				CGPathMoveToPoint(path, nil, x, y)
			} else {
				CGPathAddLineToPoint(path, nil, x, y)
			}
		}
		
		CGPathCloseSubpath(path)
		return path
	}
	
	required init?(coder aDecoder: NSCoder) {
	    fatalError("init(coder:) has not been implemented")
	}
}
