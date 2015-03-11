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
		self.removeAllChildren()
		self.displayPlayerData()
	}

	func displayPlayerData() {
		//create gold label
		let goldLabel = SKLabelNode(fontNamed: "Courier")
		goldLabel.name = "gold"
		goldLabel.fontSize = 25

		goldLabel.fontColor = SKColor.blackColor()
		goldLabel.text = "Gold: " + String((GameEngine.Instance.game?.currentPlayerGold)!)

		//Note need to position relative and scalable - not hard coded
		goldLabel.position = CGPoint(x: -430, y: 250 )
		addChild(goldLabel)

		//create wood label
		let woodLabel = SKLabelNode(fontNamed: "Courier")
		woodLabel.name = "wood"
		woodLabel.fontSize   = 25

		woodLabel.fontColor = SKColor.redColor()
		//Note need to poisiton relative and scalable - not hard coded
		woodLabel.text = NSString(format: "Wood: %02u", 100.0)

		woodLabel.position = CGPoint(x: -250, y: 250)
		woodLabel.text = "Wood: " + String((GameEngine.Instance.game?.currentPlayerWood)!)
		addChild(woodLabel)
        
        let indexLabel = SKLabelNode(text: "Participant: " + String(MatchHelper.sharedInstance().currentParticipantIndex()))
        indexLabel.position = CGPoint(x: -430, y: 200)
        self.addChild(indexLabel)
        
	}

	func displayRegionalData(tile: Tile) {
		self.update()

		if tile.owner.player !== GameEngine.Instance.game.currentPlayer { return }

		let regGold = SKLabelNode(text: "Region Gold: " + String(tile.owner.gold))
		regGold.position = CGPoint(x: -400, y: 150)
		regGold.name = "rGold"
		self.addChild(regGold)

		let regWood = SKLabelNode(text: "Region Wood: " + String(tile.owner.wood))
		regWood.position = CGPoint(x: -390, y: 100)
		regWood.name = "rGold"
		self.addChild(regWood)

	}

	

}
