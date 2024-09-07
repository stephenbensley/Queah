//
// Copyright 2023 Stephen E. Bensley
//
// This file is licensed under the MIT License. You may obtain a copy of the
// license at https://github.com/stephenbensley/Queah/blob/main/LICENSE.
//

import CheckersKit
import CoreGraphics

// Spaces on the board are indexed as follows:
// 12   11   10
//    9    8
//  7    6    5
//    4    3
//  2    1    0
//
// The reserve pieces are indexed -6 to -1 from left to right.

// Maps logical game positions to their (x, y) coordinates on the screen.
final class BoardPositions {
    // Various constants for mapping board positions. These depend on the exact layout of the
    // gameboard image.
    private static let reserveOffset: CGFloat = 56.0
    private static let reserveOrigin = CGPoint(x: -140.0, y: -205.0)
    // Since the squares are rotated 45 degrees, each unit is half the diagonal of a square.
    private static let inPlayOffset: CGFloat = 75.0 * sqrt(2.0) / 2.0
    // Zero square is over two and down two from the middle of the board.
    private static let inPlayOrigin = CGPoint(x: 2.0 * inPlayOffset, y: -2.0 * inPlayOffset)
    
    // Zero square has Queah.maxReserveCount positions ahead of it in the positions array.
    private static let originOffset = Queah.maxReserveCount
    // Cached position values for each player.
    private var positions = [[CGPoint]](repeating: .init(), count: 2)
    
    init() {
        for i in 0..<Queah.maxReserveCount {
            let point = Self.whiteReservePosition(i)
            positions[0].append(point)
            positions[1].append(point.reflectedOverX.reflectedOverY)
        }
        
        for i in 0..<Queah.spaceCount {
            let point = Self.inPlayPosition(i)
            positions[0].append(point)
            positions[1].append(point)
        }
    }
    
    // Returns the position based on index.
    func position(_ player: PlayerColor, index: Int) -> CGPoint {
        positions[player.rawValue][index + Self.originOffset]
    }
    
    // Location of white's reserve checkers specified by ordinal. Zero is far left piece.
    static func whiteReservePosition(_ ordinal: Int) -> CGPoint {
        .init(x: reserveOrigin.x + reserveOffset * CGFloat(ordinal),  y: reserveOrigin.y)
    }
    
    // Position of spaces on the Ur board specified by index.
    static func inPlayPosition(_ index: Int) -> CGPoint {
        // 2.5 squares per row
        let x = (-2 * index) % 5
        let y = (+2 * index) / 5
        return .init(
            x: inPlayOrigin.x + inPlayOffset * CGFloat(x),
            y: inPlayOrigin.y + inPlayOffset * CGFloat(y)
        )
    }
}
