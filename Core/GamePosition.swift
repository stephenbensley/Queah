//
// Copyright 2024 Stephen E. Bensley
//
// This file is licensed under the MIT License. You may obtain a copy of the
// license at https://github.com/stephenbensley/Queah/blob/main/LICENSE.
//

// Represents a game move. If from is invalid, this is a drop. If capturing is invalid, no
// capture occurs.
struct Move: Equatable {
    let from: Int
    let to: Int
    let capturing: Int
    
    init(
        from: Int = Queah.invalidSpace,
        to: Int = Queah.invalidSpace,
        capturing: Int = Queah.invalidSpace
    ) {
        self.from = from
        self.to = to
        self.capturing = capturing
    }
}

// Represents the neighboring spaces in a particular direction
fileprivate struct Neighbor {
    // Index of the adjacent space or invalid if it doesn't exist.
    let adjacent: Int
    // Index of the space that can be jumped to or invalid if it doesn't exist.
    let jumpTo: Int
    
    init(_ adjacent: Int, _ jumpTo: Int) {
        self.adjacent = adjacent
        self.jumpTo = jumpTo
    }
}

// Represents a position in the game without regard to which player has the next move. Queah is
// symmetric with regard to player color, so we can analyze a position without knowing which player
// moves next.
struct GamePosition: Codable, Comparable, Identifiable {
    // Player with the next move.
    private(set) var attacker: PlayerPosition
    // Player without the next move.
    private(set) var defender: PlayerPosition
    
    init(attacker: PlayerPosition, defender: PlayerPosition) {
        self.attacker = attacker
        self.defender = defender
    }
    
    // Returns an integer uniquely identifying this position.
    var id: UInt32 { (UInt32(attacker.id) << 16) | UInt32(defender.id) }

    // Returns an integer uniquely identifying this board position w/o regard to reserve counts.
    var boardId: UInt32 {
        (UInt32(attacker.bitboard) << Queah.spaceCount) | UInt32(defender.bitboard)
    }

    // Returns the canonical format of the move. Useful for collapsing game positions that are
    // strategically identical.
    var canonical: GamePosition {
        var canonical = self
        var candidate = self
        
        // Canonical form is whichever transposition has the lowest id.
        
        // Try all three other rotations.
        for _ in 1..<Queah.directionCount {
            candidate.rotate()
            canonical = min(canonical, candidate)
        }
        
        // Mirror the board.
        candidate.mirror()
        canonical = min(canonical, candidate)
        
        // Now try the three mirrored rotations.
        for _ in 1..<Queah.directionCount {
            candidate.rotate()
            canonical = min(canonical, candidate)
        }
        
        return canonical
    }
    
    // Returns true if the game is over.
    var gameOver: Bool { moves.isEmpty }
    
    // Returns all legal moves from the position.
    var moves: [Move] {
        var moves = drops
        let captures = captures
        if !captures.isEmpty {
            moves += captures
        } else {
            // Captures are forced, so only add simple_moves if no captures are available.
            moves += simpleMoves
        }
        return moves
    }
    
    // Returns true if the move is allowed from this position.
    func isLegal(move: Move) -> Bool { moves.contains(move) }
    
    // Determines the result of a move without actually changing the position.
    func tryMove(move: Move) -> GamePosition {
        var result = self
        result.makeMove(move: move)
        return result
    }
    
    // Updates the position according to the move.
    mutating func makeMove(move: Move) {
        assert(isLegal(move: move))
        attacker.move(from: move.from, to: move.to)
        if move.capturing.isValidSpace {
            defender.remove(from: move.capturing)
        }
        reverse()
    }
    
    // Starting position for the game.
    static let start = GamePosition(
        attacker: PlayerPosition(
            bitboard: PlayerPosition.start0,
            reserveCount: Queah.maxReserveCount
        ),
        defender: PlayerPosition(
            bitboard: PlayerPosition.start1,
            reserveCount: Queah.maxReserveCount
        )
    )

    // Returns true if either player has a piece occupying the specified space.
    private func occupied(space: Int) -> Bool {
        attacker.occupies(space: space) || defender.occupies(space: space)
    }
    
    // All legal capturing moves.
    private var captures: [Move] {
        var captures = [Move]()
        for space in 0..<Queah.spaceCount where attacker.occupies(space: space) {
            for neighbor in Self.neighbors[space] {
                // If the jumpTo space is empty and the adjacent space is occupied by an opposing
                // piece, then we can capture.
                if neighbor.jumpTo.isValidSpace && !occupied(space: neighbor.jumpTo) &&
                    defender.occupies(space: neighbor.adjacent) {
                    captures.append(
                        Move(from: space, to: neighbor.jumpTo, capturing: neighbor.adjacent)
                    )
                }
            }
        }
        return captures
    }
    
    // All legal drops.
    private var drops: [Move] {
        var drops = [Move]()
        if attacker.canDrop {
            // We can drop on any empty space.
            for space in 0..<Queah.spaceCount where !occupied(space: space) {
                drops.append(Move(to: space))
            }
        }
        return drops
    }
    
    // All legal moves that are neither captures or drops.
    private var simpleMoves: [Move] {
        var moves = [Move]()
        for space in 0..<Queah.spaceCount where attacker.occupies(space: space) {
            for neighbor in Self.neighbors[space] {
                // If the adjacent space is empty, then we can move.
                if neighbor.adjacent.isValidSpace && !occupied(space: neighbor.adjacent) {
                    moves.append(Move(from: space, to: neighbor.adjacent))
                }
            }
        }
        return moves
    }
    
    // Reverse the attacker and defender.
    private mutating func reverse() { swap(&attacker, &defender) }
    
    // Reflects the board horizontally.
    private mutating func mirror() {
        attacker.mirror()
        defender.mirror()
    }
    
    // Rotates the players' pieces clockwise.
    private mutating func rotate() {
        attacker.rotate()
        defender.rotate()
    }
    
    // Comparable
    static func < (lhs: GamePosition, rhs: GamePosition) -> Bool {
        lhs.id < rhs.id
    }
    static func == (lhs: GamePosition, rhs: GamePosition) -> Bool {
        lhs.id == rhs.id
    }
    
    // Throwaway typealias to make the following table more concise.
    private typealias NB = Neighbor
    // Neighbors for each space and direction.
    private static let neighbors: [[Neighbor]]  = [
        [ NB(-1, -1), NB(-1, -1), NB( 3,  6), NB(-1, -1 ) ], //  0
        [ NB(-1, -1), NB(-1, -1), NB( 4,  7), NB( 3,  5 ) ], //  1
        [ NB(-1, -1), NB(-1, -1), NB(-1, -1), NB( 4,  6 ) ], //  2
        [ NB( 0, -1), NB( 1, -1), NB( 6,  9), NB( 5, -1 ) ], //  3
        [ NB( 1, -1), NB( 2, -1), NB( 7, -1), NB( 6,  8 ) ], //  4
        [ NB(-1, -1), NB( 3,  1), NB( 8, 11), NB(-1, -1 ) ], //  5
        [ NB( 3,  0), NB( 4,  2), NB( 9, 12), NB( 8, 10 ) ], //  6
        [ NB( 4,  1), NB(-1, -1), NB(-1, -1), NB( 9, 11 ) ], //  7
        [ NB( 5, -1), NB( 6,  4), NB(11, -1), NB(10, -1 ) ], //  8
        [ NB( 6,  3), NB( 7, -1), NB(12, -1), NB(11, -1 ) ], //  9
        [ NB(-1, -1), NB( 8,  6), NB(-1, -1), NB(-1, -1 ) ], // 10
        [ NB( 8,  5), NB( 9,  7), NB(-1, -1), NB(-1, -1 ) ], // 11
        [ NB( 9,  6), NB(-1, -1), NB(-1, -1), NB(-1, -1 ) ]  // 12
    ]
}
