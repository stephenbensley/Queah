//
// Copyright 2023 Stephen E. Bensley
//
// This file is licensed under the MIT License. You may obtain a copy of the
// license at https://github.com/stephenbensley/Queah/blob/main/LICENSE.
//

import SpriteKit

// Represents a space on the board.
final class BoardSpace: SKSpriteNode {
    // Spaces never move, so location is immutable.
    let location: BoardLocation
    // Indicates whether the space is displayed in the selected state.
    var selected: Bool = false {
        willSet {
            if newValue != selected {
                texture = newValue ? BoardSpace.spaceSelected : nil
            }
        }
    }
    
    static let spaceSelected = SKTexture(imageNamed: "space-selected")
    
    init(index: Int) {
        location = BoardLocation(.inPlay, index)
        // This sprite needs to be the same size as the squares in the game-board image, so the
        // hit area will be consistent.
        let size = CGSize(width: BoardLocation.spaceSideLength,
                          height: BoardLocation.spaceSideLength)
        super.init(texture: nil, color: .clear, size: size)
        
        self.position = location.center
        self.zPosition = Layer.boardSpace.rawValue
        // The Queah board is rotated 45 degrees.
        self.zRotation = CGFloat(Double.pi / 2)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
