//
// Copyright 2023 Stephen E. Bensley
//
// This file is licensed under the MIT License. You may obtain a copy of the
// license at https://github.com/stephenbensley/Queah/blob/main/LICENSE.
//

import Foundation

extension CGPoint {
    func scaled(by factor: CGFloat) -> CGPoint {
        return CGPoint(x: self.x * factor, y: self.y * factor)
    }
}

enum BoardRegion {
    case inPlay
    case whiteReserve
    case blackReserve
}

// Represents a location on the board and computes the on-screen coordinates.
struct BoardLocation: Equatable {
    let region: BoardRegion
    let index: Int

    // Spaces on the board are indexed as follows:
    // 12   11   10
    //    9    8
    //  7    6    5
    //    4    3
    //  2    1    0
    //
    // Coordinates are relative to the middle space.
    private static let spacePositions = [
        CGPoint(x:  2, y: -2),
        CGPoint(x:  0, y: -2),
        CGPoint(x: -2, y: -2),
        CGPoint(x:  1, y: -1),
        CGPoint(x: -1, y: -1),
        CGPoint(x:  2, y:  0),
        CGPoint(x:  0, y:  0),
        CGPoint(x: -2, y:  0),
        CGPoint(x:  1, y:  1),
        CGPoint(x: -1, y:  1),
        CGPoint(x:  2, y:  2),
        CGPoint(x:  0, y:  2),
        CGPoint(x: -2, y:  2)
    ]
    
    // Side length of a space
    static let spaceSideLength: CGFloat = 75
    // Amount by which to scale the space positions. Since the squares are rotated 45 degrees, each
    // unit is half the diagonal of a square.
    private static let spaceScaleFactor: CGFloat = spaceSideLength * sqrt(2.0) / 2.0
    // Y-offset of the reserve row from the center of the board
    private static let reserveRowY: CGFloat = 205
    // Maximum X-offset of the reserve row
    private static let reserveRowXmax: CGFloat = 140
    // Distribute the reserve pieces evenly between -reserveRowXmax and reserveRowXmax
    private static let reserveSpacing: CGFloat = reserveRowXmax * 2 / CGFloat(Queah.maxReserveCount - 1)

    init(_ region: BoardRegion, _ index: Int) {
        self.region = region
        self.index = index
    }

    var center: CGPoint { BoardLocation.center(region: region, index: index) }
    
    // The engine represents all reserve pieces by invalidSpace.
    var engineIndex: Int { region == .inPlay ? index : Queah.invalidSpace }
    
    static private func center(region: BoardRegion, index: Int) -> CGPoint {
        switch region {
        case .inPlay:
            return spacePositions[index].scaled(by: spaceScaleFactor)
        case .whiteReserve:
            return CGPoint(x: -reserveRowXmax + CGFloat(index) * reserveSpacing, y: -reserveRowY)
        case .blackReserve:
            return CGPoint(x: +reserveRowXmax - CGFloat(index) * reserveSpacing, y: +reserveRowY)
       }
    }
}
