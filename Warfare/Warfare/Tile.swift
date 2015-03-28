//
//  Tile.swift
//  warfare
//
//  Created by Justin Domingue on 2015-01-21.
//  Copyright (c) 2015 Justin Domingue. All rights reserved.
//

import SpriteKit
import Darwin

func == (lhs: Tile, rhs: Tile) -> Bool {
    return lhs.hashValue == rhs.hashValue
}

class Tile: SKShapeNode, Hashable {
    var coordinates: (Int, Int)!
    var unit: Unit?
    var village: Constants.Types.Village?
    var structure: Constants.Types.Structure?
    var land: Constants.Types.Land!
    var owner: Village!
    var lighten: CGFloat = Constants.Tile.Alpha.normal.rawValue
    override var hashValue: Int {
        return "\(self.coordinates.0), \(self.coordinates.1)".hashValue
    }

    var selected: Bool = false {
        didSet {
            if selected {
                self.fillColor = Utilities.Colors.colorForLandType(self.land, lighten: Constants.Tile.Alpha.selected.rawValue)
            } else {
                self.fillColor = Utilities.Colors.colorForLandType(self.land, lighten: self.lighten)
            }
        }
    }

    // MARK - Initializer

    init(dict: NSDictionary, ownerVillage village: Village? = nil) {
        super.init()

        self.owner = village
        self.deserialize(dict)

        self.draw()
    }

    init(coordinates: (Int, Int), landType: Constants.Types.Land = .Grass) {
        self.coordinates = coordinates
        self.land = landType

        super.init()
    }

    func draw() {
        self.removeAllChildren()

        self.path = makeHexagonalPath(CGFloat(Constants.Tile.size))
        self.fillColor = Utilities.Colors.colorForLandType(self.land, lighten: self.lighten)

        if self.owner?.player != nil {
            self.lineWidth = 2
            self.glowWidth = 2
        }

        // Structure
        if let s = self.structure {
            let sprite = SKSpriteNode(imageNamed: s.name())
            self.addChild(sprite)
        }

        // Village
        if self.village != nil {
            self.addChild((self.owner?.draw())!)
        }

        // Unit
        if let u = self.unit {
            self.addChild(u.draw())
        }

        // Player color
        if let order = self.owner?.player?.order {
            self.strokeColor = Utilities.Colors.colorForPlayer(order)
        } else {
            self.strokeColor = Utilities.Colors.colorForPlayer(-1)
        }

        // Land
        if self.land != .Grass {
            let sprite = SKSpriteNode(imageNamed: self.land.name())
            self.addChild(sprite)
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
        if let v = self.village {
            return v.wage()
        }

        return 0
    }

    func replaceTombstone() {
        if self.structure? == Constants.Types.Structure.Tombstone {
            self.structure = nil
            self.land = .Tree
        }
    }

    func removeUnit() {
        if self.unit != nil {
            self.unit?.node?.removeFromParent()
            self.unit = nil
        }
    }

    func isWalkable() -> Bool {
        return (self.land == .Grass || self.land == .Meadow)
                && self.structure != .Tombstone
    }

    // Check if self can prevent enemy from invading neighbouring tile.
    // @returns True if against unit is outclassed by tile content.
    // TODO: Check the edges cases
    func isProtected(against: Unit) -> Bool {
        let attackingType = against.type.rawValue

        if let defendingUnitType = self.unit?.type {
            return attackingType < min(defendingUnitType.rawValue, Constants.Types.Unit.Knight.rawValue)
        }

        return self.structure? == Constants.Types.Structure.Tower && attackingType < Constants.Types.Unit.Soldier.rawValue
                    || self.village?.rawValue >= Constants.Types.Village.Fort.rawValue && attackingType < Constants.Types.Unit.Knight.rawValue
    }

    func isBuildable() -> Bool {
        return self.unit == nil
                    && self.village == nil
                    && self.structure == nil
                    && self.land == .Grass
    }

    func isGrowable() -> Bool {
        return self.unit == nil
                    && self.village == nil
                    && self.structure == nil
                    && self.land != .Sea
                    && self.land != .Tree
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
        dict["structure"] = self.structure?.rawValue
        dict["village"] = self.village?.rawValue
        dict["land"] = self.land.rawValue

        return dict
    }

    func deserialize(dict: NSDictionary) {
        let p = dict["position"] as? NSArray
        self.coordinates = (p![0] as Int, p![1] as Int)

        self.land = Constants.Types.Land(rawValue: dict["land"] as Int)!

        // Unit
        if let u = dict["unit"] as? NSDictionary {
            self.unit = Unit(dict: u, position: self)
        }

        // Structure
        if let s = dict["structure"] as? Int {
            self.structure = Constants.Types.Structure(rawValue: s)
        }

        // Village
        if let v = dict["village"] as? Int {
            self.village = Constants.Types.Village(rawValue: v)
        }

        // Add tile to Map
        GameEngine.Instance.map?.setTile(at:self.coordinates, to: self)
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
