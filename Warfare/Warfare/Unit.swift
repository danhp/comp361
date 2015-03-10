import SpriteKit
import Foundation

class Unit {
    var type: Constants.Types.Unit
	var currentAction = Constants.Unit.Action.ReadyForOrders

    var disabled: Bool {
        get {
            return self.currentAction != .ReadyForOrders
        }
    }
    
    init(dict: NSDictionary, position: Tile) {
        self.type = .Infantry
        self.deserialize(dict)
    }
    
	init(type: Constants.Types.Unit) {
		self.type = type
		self.currentAction = .ReadyForOrders
	}

    func draw() -> SKLabelNode {
        switch self.type {
        case .Peasant:
            return SKLabelNode(text: "Peasant")
        case .Infantry:
            return SKLabelNode(text: "Infantry")
        case .Soldier:
            return SKLabelNode(text: "Soldier")
        case .Knight:
            return SKLabelNode(text: "Knight")
        }
    }
    
    func serialize() -> NSDictionary {
        var dict = [String: Int]()
        
        dict["type"] = self.type.rawValue
        dict["currentAction"] = self.currentAction.rawValue
        
        return dict
    }
    
    func deserialize(dict: NSDictionary) {
        self.type = Constants.Types.Unit(rawValue: dict["type"] as Int)!
        self.currentAction = Constants.Unit.Action(rawValue: dict["currentAction"] as Int)!
    }

    func combine(with: Unit) {
        let newLevel = min(self.type.rawValue + with.type.rawValue, 4)
        self.type = Constants.Types.Unit(rawValue: newLevel)!
    }
}
