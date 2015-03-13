//
//  Constants.swift
//  warfare
//
//  Created by Justin Domingue on 2015-01-21.
//  Copyright (c) 2015 Justin Domingue. All rights reserved.
//

import Darwin

struct Constants {

    struct Map {
        static let dimension = 6	// 18x18 maps
    }

    struct Tile {
        static let size = 60	// Distance from center to a corner
    }

    struct Types {
        enum Land: Int {
            case Grass = 0, Tree, Meadow, Sea

            func gold() -> Int {
                switch self {
                case .Meadow:
                    return 2
                case .Tree:
                    return 0
                default:
                    return 1
                }
            }

            func cost() -> Int {
                switch self {
                case .Meadow:
                    return 5
                default:
                    return 0
                }
            }
            
            func name() -> String {
                switch self {
                case .Grass:
                    return "grass"
                case .Tree:
                    return "tree"
                case .Meadow:
                    return "meadow"
                case .Sea:
                    return ["mountain", "mountain2"][Int(arc4random_uniform(2))]
                }
            }
            
            func scale() -> Float {
                switch self {
                case .Grass:
                    return 1
                case .Tree:
                    return 0.5
                case .Meadow:
                    return 1
                case .Sea:
                    return 0.4
                default:
                    return 1
                }
            }

            static func random() -> Land {
                switch arc4random_uniform(14) {
                case 0...2:
                    return .Tree
                case 3...4:
                    return .Meadow
                case 5: Sea
                    return .Sea
                default:
                    return .Grass
                }
            }
        }

        enum Village: Int {
            case Hovel = 0, Town, Fort, Castle

            func name() -> String {
                switch self {
                case .Hovel:
                    return "hovel"
                case .Town:
                    return "town"
                case .Fort:
                    return "tower"
                case .Castle:
                    return "castle"
                }
            }

            func wage() -> Int {
                switch self {
                case .Castle:
                    return 80
                default:
                    return 0
                }
            }

            func health() -> Int {
                switch self {
                case .Hovel:
                    return 1
                case .Town:
                    return 2
                case .Fort:
                    return 5
                case .Castle:
                    return 10
                }
            }
        }

        enum Unit: Int {
            case Peasant = 0, Infantry, Soldier, Knight, Canon

            // Cost in (Gold, Wood)
            func cost() -> (Int, Int) {
                switch self {
                case .Peasant:
                    return (10, 0)
                case .Infantry:
                    return (20, 0)
                case .Soldier:
                    return (30, 0)
                case .Knight:
                    return (40, 0)
                case .Canon:
                    return (35, 12)
                }
            }

            func wage() -> Int {
                switch self {
                case .Peasant:
                    return 2
                case .Infantry:
                    return 6
                case .Soldier:
                    return 18
                case .Knight:
                    return 54
                case .Canon:
                    return 5
                }
            }
            
            func name() -> String {
                switch self {
                case .Peasant:
                    return "peasant"
                case .Infantry:
                    return "infantry"
                case .Soldier:
                    return "soldier"
                case .Knight:
                    return "knight"
                case .Canon:
                    return "canon"
                }
            }
        }

        enum Structure: Int {
            case Tower = 0, Road, Tombstone

            func cost() -> Int {
                switch self {
                case .Tower:
                    return 5
                case .Road:
                    return 10
                case .Tombstone:
                    return 0
                }
            }
        }
    }

    struct Unit {
        enum Action: Int {
            case ReadyForOrders = 0, Moved, BuildingRoad, ChoppingTree, ClearingTombstone, UpgradingCombining, StartCultivating, FinishCultivating

            func name() -> String {
                switch self {
                case .ReadyForOrders:
                    return "ready"
                case .Moved:
                    return "moved"
                case .BuildingRoad:
                    return "roadb"
                case .ChoppingTree:
                    return "treec"
                case .ClearingTombstone:
                    return "tomb"
                case .UpgradingCombining:
                    return "upgraded"
                case .StartCultivating:
                    return "cultivate 1"
                case .FinishCultivating:
                    return "cultivate 2"
                }
            }
        }
    }

    struct Cost {
        enum Upgrade: Int {
            case Village = 8
            case Unit = 10
        }
    }
}
