//
// Copyright 2024 Stephen E. Bensley
//
// This file is licensed under the MIT License. You may obtain a copy of the
// license at https://github.com/stephenbensley/Queah/blob/main/LICENSE.
//

// Common definitions
final class Queah {
    // Number of directions a piece can move
    static let directionCount = 4
    // Number of spaces on the board
    static let spaceCount = 13
    // Max number of pieces on the board
    static let maxBoardCount = 4
    // Max number of pieces in reserve
    static let maxReserveCount = 6

    // Special space number used to indicate any of the following:
    // 1) No move is available in that direction.
    // 2) No capture is possible.
    // 3) The piece  is coming from the reserve, not the board.
    static let invalidSpace = -1
}

extension Int {
    var isValidSpace: Bool { return self != Queah.invalidSpace }
}
