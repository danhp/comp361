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
	init(landType: Constants.Types.LandType) {
		super.init()
		
		self.path = makeHexagonalPath(CGFloat(Constants.Tile.size))
		self.fillColor = UIColor.blueColor()
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
