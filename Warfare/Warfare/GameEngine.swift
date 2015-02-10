import Foundation

class Engine {
	var currentPlayer: Player
	let players: [Player]

	init(firstPlayer: Player, players: [Player]) {
		self.currentPlayer = firstPlayer
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
				switch tile.land {
				case .Meadow:
					village.gold += 2
				case .Tree:
					break
				default:
					village.gold += 1
				}

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
