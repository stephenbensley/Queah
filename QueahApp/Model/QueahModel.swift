//
// Copyright 2023 Stephen E. Bensley
//
// This file is licensed under the MIT License. You may obtain a copy of the
// license at https://github.com/stephenbensley/Queah/blob/main/LICENSE.
//

import Foundation

enum PlayerType: Int {
    case human = 0
    case computer
}

// Represents the non-visual state of the game -- everything necessary to rebuild the game view
// from scratch.
class QueahModel {
    let game = QueahGame()
    let ai = QueahAI()
    var playerType: [PlayerType] = [ .human, .computer]
    
    func newGame(white: PlayerType, black: PlayerType) -> Void {
        game.reset()
        playerType[PlayerColor.white.rawValue] = white
        playerType[PlayerColor.black.rawValue] = black
    }
    
    static func load() -> QueahModel? {
        // Verify all the keys are present in UserDefaults
        guard let data = UserDefaults.standard.data(forKey: "Game"),
              let type0 = loadPlayerType(forKey: "Player0"),
              let type1 = loadPlayerType(forKey: "Player1") else {
            return nil
        }
        
        let model = QueahModel()
        
        // Ensure the values are valid. We don't allow computer vs. computer.
        guard model.game.decode(data: data) &&
                ((type0 != .computer) || (type1 != .computer)) else {
            return nil
        }
        
        model.playerType[0] = type0
        model.playerType[1] = type1
        return model
    }
    
    func save() -> Void {
        let data = game.encode()
        UserDefaults.standard.set(data, forKey: "Game")
        UserDefaults.standard.set(playerType[0].rawValue, forKey: "Player0")
        UserDefaults.standard.set(playerType[1].rawValue, forKey: "Player1")
    }
    
    private static func loadPlayerType(forKey key: String) -> PlayerType? {
        guard UserDefaults.standard.object(forKey: key) != nil else {
            return nil
        }
        return PlayerType(rawValue: UserDefaults.standard.integer(forKey: key))
    }
}
