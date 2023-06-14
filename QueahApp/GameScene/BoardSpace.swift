//
// Copyright 2023 Stephen E. Bensley
//
// This file is licensed under the MIT License. You may obtain a copy of the
// license at https://github.com/stephenbensley/obatgonu/blob/main/LICENSE.
//

import Foundation
import SpriteKit

class BoardSpace: SKSpriteNode {
    let location: BoardLocation
    private var selected: Bool = false
    
    static let spaceSelected = SKTexture(imageNamed: "space-selected")

    init(index: Int) {
        location = BoardLocation(.inPlay, index)
        let size = CGSize(width: BoardLocation.spaceSideLength,
                          height: BoardLocation.spaceSideLength)
        super.init(texture: nil, color: .clear, size: size)
        self.position = location.center
        self.zPosition = Layer.boardSpace.rawValue
        self.zRotation = CGFloat(Double.pi / 2)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func select(selected newValue: Bool) -> Void {
        if selected != newValue {
            selected = newValue
            texture = selected ? BoardSpace.spaceSelected : nil
        }
    }
}
