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
final class QueahModel {
    let game: GameModel
    var playerType: [PlayerType] = [ .human, .computer ]
    
    func newGame(white: PlayerType, black: PlayerType) {
        game.newGame()
        playerType[PlayerColor.white.rawValue] = white
        playerType[PlayerColor.black.rawValue] = black
    }
    
    static func create() -> QueahModel {
        // Load the solution
        guard let evaluator = PositionEvaluator(
            forResource: "queahSolution",
            withExtension: "data"
        ) else {
            // There's no possible recovery if the app bundle is corrupt.
            fatalError("Unable to load solution file.")
        }
        
        let from = UserDefaults.standard
        
        // Load player types
        let playerType = loadPlayerType(from: from)
        
        // Load the game model
        if let data = UserDefaults.standard.data(forKey: "Game"),
           let game = GameModel(evaluator: evaluator, data: data) {
            return QueahModel(game: game, playerType: playerType)
        }
        
        // Use a default game model.
        return QueahModel(game: GameModel(evaluator: evaluator), playerType: playerType)
    }
    
    func save() {
        let to = UserDefaults.standard
        to.set(game.encode(), forKey: "Game")
        to.set(playerType[0].rawValue, forKey: "Player0")
        to.set(playerType[1].rawValue, forKey: "Player1")
    }
    
    private init(game: GameModel, playerType: [PlayerType]) {
        self.game = game
        self.playerType = playerType
    }
    
    private static func loadPlayerType(from: UserDefaults) -> [PlayerType] {
        if let type0 = loadPlayerType(from: from, forKey: "Player0"),
           let type1 = loadPlayerType(from: from, forKey: "Player1") {
            // We don't allow computer vs. computer
            if type0 != .computer || type1 != .computer {
                return [type0, type1]
            }
        }
        // Something went wrong, so default to human vs. human
        return [.human, .human]
    }
    
    private static func loadPlayerType(from: UserDefaults, forKey key: String) -> PlayerType? {
        guard let rawValue = from.value(forKey: key) as? Int else {
            return nil
        }
        return PlayerType(rawValue: rawValue)
    }
}
