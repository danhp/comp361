import Foundation
import GameKit
import SpriteKit

private let _instance = GameEngine()

class GameEngine {
    class var Instance: GameEngine { return _instance }
    
    var game: Game?
    var map: Map? { return self.game?.map }
    var scene: GameScene?
    var selectedMap: Int = 1
    
    // Map selection
    private var currentChoices: [Int]?
    
    init() { }
    
    // Starts a (completely) new match
    func startGameWithMap(map: Int) {
        self.loadMap(number: String(map))
    }
    
    // Show map selection so player can
    //  i. make a selection
    //  ii. wait until everyone has chosen a map
    func showMapSelection() {
        MatchHelper.sharedInstance().vc?.dismissViewControllerAnimated(true, completion: ({() in
            // Present the map selection controller
            if let mmvc = MatchHelper.sharedInstance().vc as? MainMenuViewController {
                mmvc.segueToMapSelectionViewController()
            }}))
    }
    
    func showGameScene() {
        // Dismiss any controller and then show Game View Controller
        MatchHelper.sharedInstance().vc?.dismissViewControllerAnimated(true, completion: ({() in
            // Present the game view controller
            if let mmvc = MatchHelper.sharedInstance().vc as? MainMenuViewController {
                mmvc.segueToGameViewController()
            }}))
    }
    
    // User has selected a choice: Int, process it
    func processMapSelection(choice: Int) {
        // TODO put the game in a "waiting for map selection..." state
        
        // Add choice to choices array
        if let cur = self.currentChoices {
            self.currentChoices = cur + [choice]    // append selection to previous ones
        } else {
            self.currentChoices = [choice]          // new array with first selection
        }
        
        // Send info to GameCenter
        let dict = ["choices": self.currentChoices!]
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
                if let choices = dict["choices"] as? [Int] {    // choice is only present during map selection
                    
                    // MAP SELECTION SEQUENCE ENDED
                    if choices.count == 3 && MatchHelper.sharedInstance().currentParticipantIndex() == 0  { // make sure current player is first one
                        let finalChoice = choices[Int(arc4random_uniform(3))]
                        GameEngine.Instance.startGameWithMap(finalChoice)   // replace match data with a new game loaded with map number
                        MatchHelper.sharedInstance().updateMatchData()      // send update to every one
                        self.showGameScene()
                    // MAP SELECTION SEQUENCE IN PROGRESS
                    } else { // TODO pass a bool saying userShouldSelect or userShouldwait
                        self.currentChoices = choices
                        self.showMapSelection() // current player will select a map
                    }
                    
                // MATCH IN PROGRESS
                } else {
                    self.game = Game()
                    self.game?.importDictionary(dict)
                    self.scene?.resetMap()
                    self.showGameScene()
                }
            }
        
        // NEW MATCH - initiate map selection sequence
        } else {
            self.showMapSelection()
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
