import Foundation
import GameKit

private let _instance = GameEngine()

class GameEngine {
    var currentPlayer = Player()
    var players = [Player]()
    let map = Map()
    
    // MARK: Singleton
    
    class var Instance: GameEngine { return _instance }
    
    // MARK: - Initializers
    
    init() {
    }
    
    init(firstPlayer: Int, players: [Player]) {
        assert(players.count == 3, "A Game should be between exactly 3 players.")
        
        self.currentPlayer = players[firstPlayer]
        self.players = players
    }
    
    // MARK: - Serialization
    
    func loadMap(#number: String) {
        var e: NSError?
        if let path = NSBundle.mainBundle().pathForResource(number, ofType: "json") {
            if let json = NSString(contentsOfFile:path, encoding:NSUTF8StringEncoding, error:&e) {
                let data = (json as NSString).dataUsingEncoding(NSUTF8StringEncoding)
                var parseError: NSError?
                let parsedObject: AnyObject? = NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.AllowFragments, error: &parseError)
                
                if let top = parsedObject as? NSDictionary {
                    
                    // PLAYERS
                    if let players = top["players"] as? NSArray {
                        for p in players {
                            self.players.append(Player(dict: p as NSDictionary))
                        }
                    }
                    
                    // NEUTRAL TILES
                    if let neutral = top["neutral"] as? NSArray {
                        for t in neutral {  // t is an NSDictionary
                            let t = Tile(dict: t as NSDictionary, village: nil)
//                            self.map.setTile(at: t.coordinates, to: t)
                        }
                    }
                }
            }
        }
    }
    
    func serialize() -> NSDictionary {
        var dict = [String: AnyObject]()
        
        dict["players"] = self.players.map({$0.serialize()})
        dict["neutral"] = ""
        
        return dict
    }
    
    func toJSON(dict: NSDictionary) -> String {
        // Make JSON
        var error:NSError?
        var data = NSJSONSerialization.dataWithJSONObject(dict, options:NSJSONWritingOptions(0), error: &error)
        
        // Return as a String
        return NSString(data: data!, encoding: NSUTF8StringEncoding)!
    }
    
    // MARK: - Operations
    
    func beginTurn() {
        
        for village in currentPlayer.villages {
            for tile in village.controlledTiles {
                
                // Replace tombstones
                tile.replaceTombstone()
                
                // Produce constructions
                if tile.makeRoadOrMeadow() {
                    // Add a new meadow
                    // TODO
                }
                
                // Add gold value to village.
                village.gold += tile.goldValue()
                
                // Payout wages
                village.gold += tile.wage()
            }
            
            // Delete the Village
            if village.gold <= 0 {
                self.currentPlayer.removeVillages(village)
            }
        }
    }
}
