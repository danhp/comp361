import Foundation
import GameKit
import SpriteKit

private let _instance = GameEngine()

class GameEngine {
    class var Instance: GameEngine { return _instance }

    var game: Game!
    var map: Map { return self.game.map }
    var scene: GameScene?
    
    init() { }
    
    func newGame() {
        self.loadMap(number: "1")
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
<<<<<<< Updated upstream
        self.game = Game()
        self.game.importData(matchData)
=======
        self.loadMap(number: "2")
        return
        // EXISTING MATCH
        if matchData.length > 0 {
            if let dict = self.dataToDict(matchData) {  // try to extract match data
                if let choices = dict["choice"] as? [Int] {    // choice is only present during map selection
                    
                    // MAP SELECTION SEQUENCE ENDED
                    if choices.count == 3 {
                        let finalChoice = choices[Int(arc4random_uniform(3))]
                        GameEngine.Instance.startGameWithMap(finalChoice)   // replace match data with a new game loaded with map number
                        MatchHelper.sharedInstance().updateMatchData()      // send update to every one
                        
                    // MAP SELECTION SEQUENCE IN PROGRESS
                    } else {
                        self.mapSelection(choices) // current player will select a map
                    }
                    
                // MATCH IN PROGRESS
                } else {
                    self.game = Game()
                    self.game?.importDictionary(dict)
                    self.scene?.resetMap()
                }
            }
        
        // NEW MATCH - initiate map selection sequence
        } else {
            self.mapSelection(nil)
        }
>>>>>>> Stashed changes
    }
    
    func encodeMatchData() -> NSData {
        return (self.game?.encodeMatchData())!
    }
    
    func encodeTurnMessage() -> String {
        return self.game?.matchTurnMessage() ?? "No message."
    }
}
