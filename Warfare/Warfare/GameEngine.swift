import Foundation
import GameKit
import SpriteKit

private let _instance = GameEngine()

class GameEngine {
    class var Instance: GameEngine { return _instance }

    var game: Game!
    var map: Map { return self.game.map }
    var scene: GameScene?
    var selectedMap: Int = 1
    
    init() { }
    
    func newGame() {
        self.loadMap(number: String(selectedMap))
    }

    // MARK: - Serialization

    func loadMap(#number: String) {
        var e: NSError?
        if let path = NSBundle.mainBundle().pathForResource(number, ofType: "json") {
            if let json = NSString(contentsOfFile:path, encoding:NSUTF8StringEncoding, error:&e) {
                if let data = (json as NSString).dataUsingEncoding(NSUTF8StringEncoding) {
                    self.decode(data)
                }
            }
        }
    }
    
    func decode(matchData: NSData) {
        self.game = Game()
        self.game.importData(matchData)
    }
    
    func encodeMatchData() -> NSData {
        return (self.game?.encodeMatchData())!
    }
    
    func encodeTurnMessage() -> String {
        return self.game?.matchTurnMessage() ?? "No message."
    }
}
