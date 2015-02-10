import Foundation

class Engine {
	var currentPlayer: Player
	let players: [Player]

	init(firstPlayer: Int, players: [Player]) {
        assert(players.count == 3, "A Game should be between exactly 3 players.")

		self.currentPlayer = players[firstPlayer]
		self.players = players
	}
    
	func beginTurn() {
		
		for village in currentPlayer.villages {
			for tile in village.controlledTiles {

				// Replace tombstones
				if tile.structure?.type == Constants.Types.Structure.Tombstone {
					tile.structure == nil
					tile.land = .Tree
				}

				// Produce constructions
				// TODO:

				// Add gold value to village.
                village.gold += tile.land.gold()

				// Payout wages
                village.gold += (tile.unit?.type.wage())!
			}

			// Delete the Village
			if village.gold <= 0 {
				self.currentPlayer.removeVillages(village)
			}
		}
	}
}
