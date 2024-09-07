//
// Copyright 2023 Stephen E. Bensley
//
// This file is licensed under the MIT License. You may obtain a copy of the
// license at https://github.com/stephenbensley/Queah/blob/main/LICENSE.
//

import CheckersKit
import Foundation

extension Array where Element: Equatable {
    mutating func removeFirstMatch(_ value: Array.Element) {
        if let index = firstIndex(of: value) {
            remove(at: index)
        }
    }
}

extension Move {
    // Simple helper to reindex a Move. Useful when swizzling from internal to external indices.
    func reindex(from: Int) -> Move {
        .init(from: from, to: self.to, capturing: self.capturing)
    }
}

// Represents the non-visual state of the game -- everything necessary to rebuild the game view
// from scratch.
final class QueahModel: Codable {
    private let game: GameModel
    private(set) var playerType: [PlayerType] = [ .human, .computer ]
    private var reserve = QueahModel.initializeReserve()
    
    // Type of the current player.
    var currentType: PlayerType { playerType[toMove.rawValue] }
    // Returns true if the game is over.
    var isOver: Bool { game.isOver }
    // Returns the number of times the current position has occurred.
    var repetitions: Int { game.repetitions }
    // Returns the next player to move.
    var toMove: PlayerColor { game.toMove }
    
    // Returns the best move from the current position.
    var bestMove: Move {
        let move = game.bestMove
        if move.from.isValidSpace {
            // 'from' is valid, so use as is.
            return move
        } else {
            // Prefer the far right piece in reserve.
            return move.reindex(from: reserve[toMove.rawValue].last ?? Queah.invalidSpace)
        }
    }
    
    // Returns all valid moves from the current position.
    var moves: [Move] {
        var result = [Move]()
        for move in game.moves {
            if move.from.isValidSpace {
                result.append(move)
            } else {
                // Player can move any of their reserve pieces.
                result += reserve[toMove.rawValue].map { move.reindex(from: $0) }
            }
        }
        return result
    }
    
    static func create() -> QueahModel {
        if let data = UserDefaults.standard.data(forKey: "AppModel"),
           let model = try? JSONDecoder().decode(QueahModel.self, from: data) {
            return model
        }
        // If we can't restore the app model, just create a new default one.
        return QueahModel()
    }
    
    func newGame(white: PlayerType, black: PlayerType) {
        game.newGame()
        playerType = [ white, black ]
        reserve = Self.initializeReserve()
    }
    
    func makeMove(move: Move) {
        // If move.from is non-negative, we simply forward the move to GameModel.
        guard move.from < 0 else {
            game.makeMove(move: move)
            return
        }
        
        // Remove the piece from the reserve.
        reserve[toMove.rawValue].removeFirstMatch(move.from)
        
        // Map all reserve indices to Queah.invalidSpace
        game.makeMove(move: move.reindex(from: Queah.invalidSpace))
    }
    
    func pieces(for player: PlayerColor) -> [Int] {
        reserve[player.rawValue] + game.pieces(for: player)
    }
    
    func save() {
        let data = try! JSONEncoder().encode(self)
        UserDefaults.standard.set(data, forKey: "AppModel")
    }
    
    private init() {
        self.game = GameModel()
    }
    
    private static func initializeReserve() -> [[Int]] {
        (0..<2).map { _ in ((-Queah.maxReserveCount)...(-1)).map { $0 } }
    }
}
