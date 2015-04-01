import Foundation
import SpriteKit

private let _instance = Hud()

class Hud: SKNode {
    class var Instance: Hud { return _instance }

    override init() {
        super.init()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func update() {
        GameEngine.Instance.updateInfoPanel()
    }
}
