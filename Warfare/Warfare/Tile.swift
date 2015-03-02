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
    var coordinates: (Int, Int)
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
    
    init(dict: NSDictionary, village: Village?) {
        self.coordinates = (-1,-1)
        self.land = .Grass
        
        super.init()
        
        self.village = village
        self.deserialize(dict)
        
        self.draw()
    }
    
    init(coordinates: (Int, Int), landType: Constants.Types.Land = .Grass) {
        self.coordinates = coordinates
        self.land = landType
        
		super.init()
    }
    
    func draw() {
        self.path = makeHexagonalPath(CGFloat(Constants.Tile.size))
        self.fillColor = Utilities.Colors.colorForLandType(self.land)
        
        if let turn = self.village?.player?.turn {
            self.strokeColor = Utilities.Colors.colorForPlayer(turn)
        } else {
            self.strokeColor = Utilities.Colors.colorForPlayer(-1)
        }
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
    
    // MARK - Serialize
    
    func serialize() -> NSDictionary {
        var dict = [String: AnyObject]()
        
        dict["position"] = [self.coordinates.0, self.coordinates.1]
        dict["unit"] = self.unit?.serialize()
        dict["structure"] = self.structure?.type.rawValue
        dict["land"] = self.land.rawValue
        
        return dict
    }
    
    func deserialize(dict: NSDictionary) {
        let p = dict["position"] as? NSArray
        self.coordinates = (p![0] as Int, p![1] as Int)
        
        self.land = Constants.Types.Land(rawValue: dict["land"] as Int)!

        // UNIT
        if let u = dict["unit"] as? NSDictionary {
            self.unit = Unit(dict: u, position: self)
        }
        
        // STRUCTURE
        if let u = dict["structure"] as? NSDictionary {
        }
        
        // Add tile to Map
//        GameEngine.Instance.map.setTile(at:self.coordinates, to: self)
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
