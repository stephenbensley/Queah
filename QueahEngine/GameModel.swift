//
// Copyright 2024 Stephen E. Bensley
//
// This file is licensed under the MIT License. You may obtain a copy of the
// license at https://github.com/stephenbensley/Queah/blob/main/LICENSE.
//

import Foundation

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

class GameModel {
    var evaluator: PositionEvaluator
    var position: GamePosition = GamePosition.start
    private(set) var toMove: PlayerColor = .white
    var halfMoveCount = 0
    var positionCounts = [UInt64: Int]()
    
    var isOver: Bool { position.gameOver }
    var repetitions: Int { repetitions(position: position, toMove: toMove) }
    var movesCompleted: Int { (halfMoveCount + 1) / 2 }
    var moves: [Move] { position.moves }
    
    var bestMove: Move {
        // Stores the needed info for each candidate for best move.
        struct Candidate: Comparable {
            let move: Move
            let value: GameValue
            let repetitions: Int
            
            static func == (lhs: Candidate, rhs: Candidate) -> Bool {
                // Ignore move: we're only comparing desirability.
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
        
        // Count how many moves are tied for first.
        let index = candidates.lastIndex(where: { candidates.first! == $0 })!
        // Select randomly from the equally desirable moves.
        return candidates[0...index].randomElement()!.move
    }
    
    init(evaluator: PositionEvaluator) {
        self.evaluator = evaluator
    }
    
    func pieces(for player: PlayerColor) -> [Int] {
        playerPosition(for: player).indices
    }
    
    func reserveCount(for player: PlayerColor) -> Int {
        playerPosition(for: player).reserveCount
    }
    
    func playerPosition(for player: PlayerColor) -> PlayerPosition {
        player == toMove ? position.attacker : position.defender
    }
    
    func makeMove(move: Move) {
        position.makeMove(move: move)
        toMove = toMove.other
        halfMoveCount += 1
        visit()
    }
    
    func newGame() {
        position = GamePosition.start
        toMove = .white
        positionCounts.removeAll()
        halfMoveCount = 0
        visit()
    }
    
    func index(position: GamePosition, toMove: PlayerColor) -> UInt64 {
        var id = UInt64(position.id) << 1
        if toMove == .black {
            id += 1
        }
        return id
    }
    
    func repetitions(position: GamePosition, toMove: PlayerColor) -> Int {
        positionCounts[index(position: position, toMove: toMove)] ?? 0
    }
    
    func visit() {
        let index = index(position: position, toMove: toMove)
        let count = (positionCounts[index] ?? 0) + 1
        positionCounts[index] = count
    }
    
    struct CodableState: Codable {
        var position: GamePosition = GamePosition.start
        private(set) var toMove: PlayerColor = .white
        var halfMoveCount = 0
        var positionCounts = [UInt64: Int]()
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
}
