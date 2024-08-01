//
// Copyright 2024 Stephen E. Bensley
//
// This file is licensed under the MIT License. You may obtain a copy of the
// license at https://github.com/stephenbensley/Queah/blob/main/LICENSE.
//

// Space indices:
// 12   11   10
//    9    8
//  7    6    5
//    4    3
//  2    1    0

// Represents one player's position in the game.
struct PlayerPosition: Codable, Identifiable {
     // Starting positions for players
    static let start0: UInt16 = 0b000_00_000_11_011
    static let start1: UInt16 = 0b110_11_000_00_000

    // Reflect the board horizontally
    private static let mirrorTable = [ 2, 1, 0, 4, 3, 7, 6, 5, 9, 8, 12, 11, 10 ]
    // Rotate the board clockwise
    private static let rotateTable = [ 10, 5, 0, 8, 3, 11, 6, 1, 9, 4, 12, 7, 2 ]
    
    // Lower 13 bits contain the bitboard; upper 3 bits contain the reserve count.
    private var value: UInt16
    
    // Returns an integer uniquely identifying this player position.
    var id: UInt16 { value }
    // Returns a bitboard representing the locations of the player's pieces.
    var bitboard: UInt16 { value & 0x1fff }
    // Returns the number of pieces on the board.
    var boardCount: Int { bitboard.nonzeroBitCount }
    // Returns the number of pieces in reserve.
    var reserveCount: Int { Int(value >> Queah.spaceCount) }
    // Returns true if the player can drop a piece on the board.
    var canDrop: Bool { (boardCount < Queah.maxBoardCount) && (reserveCount > 0) }
    // Returns the indices of all spaces containing pieces.
    var indices: [Int] { (0..<Queah.spaceCount).filter({ occupies(space: $0) }) }
    
    init(bitboard: UInt16, reserveCount: Int) {
        self.value = bitboard | UInt16(reserveCount << Queah.spaceCount)
    }
    
    init(value: UInt16) {
        self.value = value
    }
    
    // Returns true if the player has a piece occupying the specified space.
    func occupies(space: Int) -> Bool { (value & (1 << space)) != 0 }
    
    // Moves one of the player's pieces. If from is invalid, drops a piece from the reserve.
    mutating func move(from: Int, to: Int) {
        if from.isValidSpace {
            remove(from: from)
        } else {
            assert(reserveCount > 0)
            value -= (1 << Queah.spaceCount)
        }
        place(to: to)
    }
    
    // Places a piece on the specified space.
    mutating func place(to: Int) {
        assert(!occupies(space: to))
        value |= (1 << to)
    }
    
    // Removes a piece from the specified space.
    mutating func remove(from: Int) {
        assert(occupies(space: from))
        value &= ~(1 << from)
    }
    
    // Reflects the player's pieces horizontally.
    mutating func mirror() {
        transpose(table: Self.mirrorTable)
    }
    
    // Rotates the player's pieces clockwise.
    mutating func rotate() {
        transpose(table: Self.rotateTable)
    }
    
    // Transposes the player's pieces according to the table.
    private mutating func transpose(table: borrowing [Int]) {
        assert(table.count == Queah.spaceCount)
        var transposed = PlayerPosition(bitboard: 0, reserveCount: reserveCount)
        for space in 0..<Queah.spaceCount where occupies(space: space) {
            transposed.place(to: table[space])
        }
        self = transposed
    }
}
