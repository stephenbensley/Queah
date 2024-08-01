//
// Copyright 2024 Stephen E. Bensley
//
// This file is licensed under the MIT License. You may obtain a copy of the
// license at https://github.com/stephenbensley/Queah/blob/main/LICENSE.
//

import Foundation

// White goes plays first.
enum PlayerColor: Int, Codable {
    case white
    case black
    
    var other: PlayerColor {
        switch self {
        case .white:
            return .black
        case .black:
            return .white
        }
    }
}

// Main entry point into the Queah game engine.
final class GameModel {
    // Used for determining bestMove
    private var evaluator: PositionEvaluator
    // Current game position without regard to who moves next
    private var position: GamePosition = GamePosition.start
    // Player to move next
    private(set) var toMove: PlayerColor = .white
    // Number of half moves played in the current game -- used only for reporting
    private var halfMoveCount = 0
    // Tracks how many times each position has occurred -- used to detect three-fold repetition
    private var positionCounts = [UInt64: Int]()
    
    // Returns true if the game is over.
    var isOver: Bool { position.gameOver }
    
    // Returns the number of times the current position has occurred.
    var repetitions: Int { repetitions(position: position, toMove: toMove) }
    
    // Returns the number of full moves completed. Moves are counted chess style.
    var movesCompleted: Int { (halfMoveCount + 1) / 2 }
    
    // Returns all possible moves from the current position.
    var moves: [Move] { position.moves }
    
    // Returns the best move from the current position.
    var bestMove: Move {
        // Stores the needed info for each candidate for best move.
        struct Candidate: Comparable {
            let move: Move
            let value: GameValue
            let repetitions: Int
            
            static func == (lhs: Candidate, rhs: Candidate) -> Bool {
                // Ignore move -- we're only comparing desirability
                (lhs.value == rhs.value) && (lhs.repetitions == rhs.repetitions)
            }

            static func < (lhs: Candidate, rhs: Candidate) -> Bool {
                // Prefer positions with fewer visits. This avoids draws.
                (lhs.value < rhs.value) ||
                ((lhs.value == rhs.value) && (lhs.repetitions < rhs.repetitions))
            }
        }
        
        // Collect, evaluate, and sort all the candidate moves.
        let candidates = moves.map({ move in
            let next = position.tryMove(move: move)
            let value = evaluator.evaluate(position: next)
            let repetitions = repetitions(position: next, toMove: toMove.other)
            return Candidate(move: move, value: value, repetitions: repetitions)
        }).sorted()
        
        // Count how many moves are tied for first. We know there's at least one.
        let index = candidates.lastIndex(where: { candidates.first! == $0 })!
        // Select randomly from the equally desirable moves.
        return candidates[0...index].randomElement()!.move
    }
    
    // Returns an array of indices indicating which spaces the player occupies.
    func pieces(for player: PlayerColor) -> [Int] {
        playerPosition(for: player).indices
    }
    
    // Returns the number of pieces the player has in reserve.
    func reserveCount(for player: PlayerColor) -> Int {
        playerPosition(for: player).reserveCount
    }
    
    // Updates game state based on the specified move.
    func makeMove(move: Move) {
        position.makeMove(move: move)
        toMove = toMove.other
        halfMoveCount += 1
        visit()
    }
    
    // Start a new game.
    func newGame() {
        position = GamePosition.start
        toMove = .white
        positionCounts.removeAll()
        halfMoveCount = 0
        visit()
    }
    
    // Subset of the object's state that needs to be persisted.
    struct CodableState: Codable {
        let position: GamePosition
        let toMove: PlayerColor
        let halfMoveCount: Int
        let positionCounts: [UInt64: Int]
    }
    
    func encode() -> Data {
        let state = CodableState(
            position: position,
            toMove: toMove,
            halfMoveCount: halfMoveCount,
            positionCounts: positionCounts
        )
        return try! JSONEncoder().encode(state)
    }
  
    init(evaluator: PositionEvaluator) {
        self.evaluator = evaluator
    }
    
    init?(evaluator: PositionEvaluator, data: Data) {
        guard let state = try? JSONDecoder().decode(CodableState.self, from: data) else {
            return nil
        }
        self.evaluator = evaluator
        self.position = state.position
        self.toMove = state.toMove
        self.halfMoveCount = state.halfMoveCount
        self.positionCounts = state.positionCounts
    }

    // Returns the index used for tracking repetitions
    private func index(position: GamePosition, toMove: PlayerColor) -> UInt64 {
        // Stick color into the low order bit.
        var id = UInt64(position.id) << 1
        if toMove == .black {
            id += 1
        }
        return id
    }
    
    // Returns player position based on color.
    private func playerPosition(for player: PlayerColor) -> PlayerPosition {
        player == toMove ? position.attacker : position.defender
    }

    // Returns repetition count for any position, not just the current one.
    private func repetitions(position: GamePosition, toMove: PlayerColor) -> Int {
        positionCounts[index(position: position, toMove: toMove)] ?? 0
    }
    
    // Increment the repetition count for the current state.
    private func visit() {
        let index = index(position: position, toMove: toMove)
        let count = (positionCounts[index] ?? 0) + 1
        positionCounts[index] = count
    }
}
