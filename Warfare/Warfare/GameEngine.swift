import Foundation
import GameKit
import SpriteKit

private let _instance = GameEngine()

class GameEngine {
    class var Instance: GameEngine { return _instance }
    
    var game: Game?
    var map: Map? { return self.game?.map }
    var scene: GameScene?
    
    init() { }
    
    // Starts a (completely) new match
    func startGameWithMap(map: Int) {
        self.loadMap(number: String(map))
    }
    
    // Show screen so player can choose a map
    func mapSelection(current: [Int]?) {
        // Present the map selection controller
        // TODO
        // let selection = myController.seleciton
        let selection = 0
        
        var choices: [Int]
    
        if let cur = current {
            choices = cur + [selection] // append selection to previous ones
        } else {
            choices = [selection]   // new array with first selection
        }
        
        // Send info to GameCenter
        let dict = ["choices": choices]
        var error:NSError?
        let matchData = NSJSONSerialization.dataWithJSONObject(dict, options:NSJSONWritingOptions(0), error: &error)
        MatchHelper.sharedInstance().advanceSelectionTurn(matchData!)
    }
    
    // MARK: - Serialization
    
    func loadMap(#number: String) {
        var e: NSError?
        if let path = NSBundle.mainBundle().pathForResource(number, ofType: "json") {
            if let json = NSString(contentsOfFile:path, encoding:NSUTF8StringEncoding, error:&e) {
                if let data = (json as NSString).dataUsingEncoding(NSUTF8StringEncoding) {
                    self.game = Game()
                    self.game?.importDictionary(self.dataToDict(data)!)
                }
            }
        }
    }
    
    // SUMMARY
    // In map selection sequence:
    //      - match data only has 'choice' array, array grows from 1-2-3, at 3
    // After 3, we enter in map final selection and start of the game
    //      - replace current match data with the map selected
    func decode(matchData: NSData) {
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
    }
    
    func encodeMatchData() -> NSData {
        return (self.game?.encodeMatchData())!
    }
    
    func encodeTurnMessage() -> String {
        return self.game?.matchTurnMessage() ?? "No message."
    }
    
    // Decodes match data into a dictionary
    func dataToDict(data: NSData) -> NSDictionary? {
        var parseError: NSError?
        let parsedObject: AnyObject? = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.AllowFragments, error: &parseError)
        
        if let e = parseError { println(e) }
        
        return parsedObject as? NSDictionary
    }
}
