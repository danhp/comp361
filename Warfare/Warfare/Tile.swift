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
    var unit: Unit?
	var village: Village?
	var structure: Structure?
    var land: Constants.Types.Land
    
    var selected: Bool = false {
        didSet {
            if selected {
                self.fillColor = UIColor.blackColor()
            } else {
                self.fillColor = Utilities.Colors.colorForLandType(self.land)
            }
        }
    }
    
    // MARK - Initializer
    
    init(coordinates: (Int, Int), landType: Constants.Types.Land = .Grass) {
        self.coordinates = coordinates
        self.land = landType
        
		super.init()
        
		self.path = makeHexagonalPath(CGFloat(Constants.Tile.size))
		
		self.fillColor = Utilities.Colors.colorForLandType(self.land)
        self.strokeColor = Utilities.Colors.Tile.strokeColor
	}
    
    // MARK - Public functions
    
    func goldValue() -> Int {
        return self.land.gold()
    }
    
    func wage() -> Int {
        if let u = self.unit {
            return u.type.wage()
        }
        
        return 0
    }
    
    func replaceTombstone() {
        if self.structure?.type == Constants.Types.Structure.Tombstone {
            self.structure = nil
            self.land = .Tree
        }
    }
    
    // Builds a road or finishes cultivating a meadow if the required conditions are met
    //
    // @returns True if a meadow was done being cultivated (in which case, according to the requirements, a new meadow should be produce
    //
    func makeRoadOrMeadow() -> Bool {
        if let action: Constants.Unit.Action = self.unit?.currentAction {
            if action == .BuildingRoad {
                self.structure = Structure(type: .Road)
                self.unit?.currentAction = Constants.Unit.Action.ReadyForOrders
            } else if action == .FinishCultivating && self.land == .Meadow {
                self.land = .Grass
                self.unit?.currentAction = .ReadyForOrders
                return true
            }
        }
        
        return false
    }

    func isWalkable() -> Bool {
        return self.land == .Grass
    }

    
    func clear() {
        unit = nil
        village = nil
        structure = nil
    }
    
    // MARK - Drawing

	private func makeHexagonalPath(size: CGFloat) -> CGPath {
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
