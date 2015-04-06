//
//  Constants.swift
//  warfare
//
//  Created by Justin Domingue on 2015-01-21.
//  Copyright (c) 2015 Justin Domingue. All rights reserved.
//

import Darwin
import SpriteKit

struct Constants {

    struct Map {
        static let dimension = 18   // 18x18 maps
    }

    struct Tile {
        static let size = 60    // Distance from center to a corner

        enum Alpha: CGFloat {
            case normal = 1, flood = 0.5, selected = 0.8
        }
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

            func priority() -> Int {
                switch self {
                case .Meadow:
                    return 5
                default:
                    return 1
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
                    return "mountain2"
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
                    return "fort"
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

            func upgradeCost() -> Int {
                switch self {
                case .Castle:
                    return 12
                default:
                    return 8
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
            case Peasant = 1, Infantry, Soldier, Knight, Canon

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

            func name() -> String {
                switch self {
                case .Tower:
                    return "tower"
                case .Road:
                    return "road"
                case .Tombstone:
                    return "tombstone"
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
                    return "Ready"
                case .Moved:
                    return "Moved"
                case .BuildingRoad:
                    return "Building Road"
                case .ChoppingTree:
                    return "Chopping Tree"
                case .ClearingTombstone:
                    return "Clearing Tombstone"
                case .UpgradingCombining:
                    return "Upgraded"
                case .StartCultivating:
                    return "Cultivating"
                case .FinishCultivating:
                    return "Cultivating"
                }
            }
        }
    }

    struct Village {
        enum Action: Int {
            case ReadyForOrders = 0, Upgrading1, Upgrading2

            func name() -> String {
                switch self {
                case .ReadyForOrders:
                    return "Ready"
                case .Upgrading1:
                    return "Updrading"
                case .Upgrading2:
                    return "Finishing Upgrade"
                }
            }
        }
    }

    struct Cost {
        enum Upgrade: Int {
            case Unit = 10
        }
    }

    struct UI {
        enum State {
            case NothingPressed, BuildRoadPressed, BuildTowerPressed, BuildMeadowPressed, MovePressed, CombinePressed, AttackPressed, UpgradePressed, RecruitPressed
        }
    }
}
