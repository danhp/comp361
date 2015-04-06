//
//  Map.swift
//  warfare
//
//  Created by Justin Domingue on 2015-01-21.
//  Copyright (c) 2015 Justin Domingue. All rights reserved.
//

import SpriteKit
import Darwin

extension Array {
    mutating func shuffle() {
        for i in 0..<(count - 1) {
            let j = Int(arc4random_uniform(UInt32(count - i))) + i
            swap(&self[i], &self[j])
        }
    }
}

struct Node {
    let priority: Int
    let tile: Tile
}

class Map: SKNode {
    let tiles: HexGrid
    let scroller = SKNode()

    var selected: Tile? {
        willSet {
            // Deselect previous tile
            self.selected?.selected = false

            // Select new tile
            newValue?.selected = true

            if let vc = MatchHelper.sharedInstance().vc as? GameViewController {
                vc.update(newValue!)
                GameEngine.Instance.updateInfoPanel()
            }

            // Added due to a weird behaviour of run action
            self.draw()
        }
    }

    override init() {
        self.tiles = HexGrid()

        super.init()

        initalizeScroller()
    }

    init(array: [[Tile]]) {
        self.tiles = HexGrid(array: array)

        super.init()

        initalizeScroller()
    }

    func initalizeScroller() {
        self.addChild(scroller)
    }


    // Helper for deserialization
    func setTile(#at: (Int, Int), to: Tile) {
        self.tiles[at.0, at.1] = to
    }

    func neighbors(#tile: Tile) -> [Tile] {
        return neighbors(x: tile.coordinates.0, y: tile.coordinates.1)
    }

    func neighbors(#x: Int, y: Int) -> [Tile] {
        var neighbors = [Tile]()

        var directions: [[Int]] = [
            [+1,  0], [+1, -1], [ 0, -1],
            [-1,  0], [-1, +1], [ 0, +1]
        ]

        directions.shuffle()

        for i in 0..<directions.count {
            let d = directions[i]

            if let t = self.tiles[x+d[1],y+d[0]] {
                neighbors.append(t)
            }
        }

        return neighbors
    }

    func centerAround(centerAround: Tile) {
        let positionInMap = convertPoint(centerAround.position, fromNode: self.scroller)
        let delta = CGVector(dx: -positionInMap.x , dy: -positionInMap.y )
        self.scroll(delta)
    }

    // Get the set of tiles in the shortest path
    // @return [Tile] if path exists, else return empty set.
    func getPath(#from: Tile, to: Tile, accessible: [Tile]) -> [Tile] {
        var queue = PriorityQueue<Node>({$0.priority < $1.priority})
        var seen = [Tile]()
        var cameFrom = [Tile: Tile]()
        var costSoFar = [Tile: Int]()

        // Conditions to walk on a tile:
        //      1 - Tile is owned by Village
        //      2 - Tile is empty

        queue.push(Node(priority: 0, tile: from))
        costSoFar[from] = 0
        seen.append(from)

        while !queue.isEmpty {
            let node = queue.pop()

            // Return the path
            if node?.tile == to {
                var current = to
                var finalPath = [Tile]()
                finalPath.append(current)

                while current != from {
                    current = cameFrom[current]!
                    finalPath.append(current)
                }

                return finalPath.reverse()
            }

            // Add unvisited neighbors to the queue
            for t in neighbors(tile: (node?.tile)!) {
                let newCost = costSoFar[(node?.tile)!]! + t.land.priority()

                if t.isWalkable()
                            && contains(accessible, { $0 === t })
                            && (newCost < costSoFar[t] || !contains(seen, {$0 === t}))
                            || (t === to  && t.land != .Sea) {
                    queue.push(Node(priority: newCost, tile: t))
                    costSoFar[t] = newCost
                    cameFrom[t] = node?.tile
                }
                seen += [t]
            }
        }

        var empty = [Tile]()
        return empty
    }

    // Split a set of unconnected regions into sets of connected regions
    // @returns [[Tile]] made up of at most 3 sets of connected regions.
    func getRegions(tileSet: [Tile]) -> [[Tile]] {
        var tileSetCopy = tileSet
        var seen = [Tile]()
        var queue = [Tile]()

        var regions = [[Tile]]()
        var group = [Tile]()

        while !tileSetCopy.isEmpty {
            var seed = tileSetCopy.removeLast()
            seen.append(seed)
            queue.append(seed)

            while !queue.isEmpty {
                let tile = queue.removeLast()

                // Visit the tile
                group.append(tile)
                tileSetCopy = tileSetCopy.filter({$0 !== tile})

                // Visit the neighbours
                for t in neighbors(tile: tile) {
                    if contains(tileSet, {$0 === t}) && !contains(seen, {$0 === t}) {
                        queue.append(t)
                    }
                    seen.append(t)
                }
            }
            regions.append(group)
            group = [Tile]()
        }
        return regions
    }

    // Get the region that a unit can move to
    func getAccessibleRegion(seed: Tile) -> [Tile] {
        var result = [Tile]()
        var seen = [Tile]()
        var queue = [Tile]()

        if seed.unit == nil { return result }
        if seed.owner.player !== GameEngine.Instance.game?.currentPlayer { return result }

        queue.append(seed)
        result.append(seed)
        seen.append(seed)

        if let unitType = seed.unit?.type {
            if unitType == .Canon {
                for t in neighbors(tile: seed) {
                    if (t.owner === seed.owner || t.owner == nil) && t.isWalkable() && t.unit == nil && t.village == nil {
                        result.append(t)
                    }
                }
            } else {
                while !queue.isEmpty {
                    var newSeed = queue.removeLast()

                    for t in neighbors(tile: newSeed) {
                        if contains(seen, { $0 === t}) { continue }
                        if unitType.rawValue > 3 && !t.isWalkable() { continue }
                        if t.land == .Sea { continue }

                        if t.owner === seed.owner {
                            if t.isWalkable() {
                                queue.append(t)
                            }
                            if t.structure != .Tower && t.village == nil && t.unit == nil {
                                result.append(t)
                            }
                        } else {
                            if t.owner != nil && seed.unit?.type == Constants.Types.Unit.Peasant { continue }
                            if t.village == Constants.Types.Village.Castle { continue }
                            if !t.isProtected(seed.unit!) {
                                var b = false
                                for n in self.neighbors(tile: t) {
                                    if n.owner == nil { continue }
                                    if n.owner.player !== seed.owner.player {
                                        if n.unit?.type == Constants.Types.Unit.Canon { continue }
                                        if n.isProtected(seed.unit!) {
                                            b = true
                                        }
                                    }
                                }
                                if !b {
                                    result.append(t)
                                }
                            }
                        }
                        seen.append(t)
                    }
                }
            }
        }

        return result
    }

    func getBuildableRegion(seed: Tile) -> [Tile] {
        var result = [Tile]()
        var seen = [Tile]()
        var queue = [Tile]()

        if seed.unit?.type != Constants.Types.Unit.Peasant { return result }

        queue.append(seed)
        seen.append(seed)
        if seed.structure == nil {
            result.append(seed)
        }

        while !queue.isEmpty {
            var newSeed = queue.removeLast()

            for t in neighbors(tile: newSeed) {
                if contains(seen, { $0 === t}) { continue }
                if !t.isWalkable() { continue }
                if t.land == .Sea { continue }

                if t.owner === seed.owner {
                    if t.isWalkable() {
                        queue.append(t)
                    }
                    if t.isBuildable() {
                        result.append(t)
                    }
                }
                seen.append(t)

            }
        }
        return result
    }

    func getAttackableRegion(seed: Tile) -> [Tile] {
        var result = [Tile]()
        var seen = [Tile]()
        var queue = [Tile]()

        if seed.unit?.type != Constants.Types.Unit.Canon { return result }

        queue.append(seed)
        seen.append(seed)

        for n in neighbors(tile: seed) {
            for n2 in neighbors(tile: n) {
                if n2.owner !== seed.owner && !n2.isBelongsToLocal() {
                    result.append(n2)
                }
            }

            if n.owner !== seed.owner && !n.isBelongsToLocal() {
                result.append(n)
            }
        }

        return result
    }

    func getVillage(region: [Tile]) -> Village? {
        for tile in region {
            if tile.village != nil {
                return tile.owner
            }
        }
        return nil
    }

    func isDistanceOfTwo(from: Tile, to: Tile) -> Bool {
        for n1 in self.neighbors(tile: from) {
            if n1 === to { return true }
            for n2 in self.neighbors(tile: n1) {
                if n2 === to { return true }
            }
        }
        return false
    }

    func draw() {
        let height = Constants.Tile.size * 2
        let width = sqrt(3)/2.0 * Double(height)
        let vert = height * 3/4
        let horiz = width

        self.scroller.removeAllChildren()

        // Go row by row
        for (i, row) in enumerate(self.tiles.rows) {
            let x_offset = i % 2 == 0 ? 0 : width/2

            // Add the tiles for the current row.
            for (j, tile) in enumerate(row) {

                let coord = Utilities.arrayToAxialCoordinates(row: i, col: j)
                let tile = tiles[coord.x, coord.y]!
                tile.draw()
                tile.position = CGPointMake(CGFloat(Double(x_offset)+Double(j)*horiz), -CGFloat(i*vert))

                // let label = SKLabelNode(text: String(coord.x) + ", " + String(coord.y))
                // label.fontSize = 16.0
                // tile.addChild(label)
                self.scroller.addChild(tile)
            }
        }
    }

    func resetColor() {
        let tileList: [Tile] = tiles.rows.reduce([], +)

        for t in tileList {
            t.lighten = false
        }
    }

    func scroll(delta: CGVector) {
        let move = SKAction.moveBy(delta, duration: 1)
        self.scroller.runAction(move)
    }

    func scroll(delta: CGPoint) {
        scroller.position = CGPointMake(scroller.position.x + delta.x, scroller.position.y + delta.y)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
