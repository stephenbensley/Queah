//
// Copyright 2023 Stephen E. Bensley
//
// This file is licensed under the MIT License. You may obtain a copy of the
// license at https://github.com/stephenbensley/Queah/blob/main/LICENSE.
//

import SpriteKit

// Button that returns user to main menu.
class MenuButton: SKNode {
    var highlighted: Bool = false {
        didSet {
            alpha = highlighted ? 0.6 : 1.0
        }
    }
    
    override init() {
        super.init()
        
        // Button is a peer of the game board.
        self.zPosition = Layer.gameBoard.rawValue
        
        let shape = SKShapeNode(rectOf: CGSize(width: 150, height: 55), cornerRadius: 20)
        shape.lineWidth = 5
        addChild(shape)
        
        let text = SKLabelNode(text: "Main Menu")
        text.fontName = "Helvetica"
        text.fontSize = 20
        text.verticalAlignmentMode = .center
        shape.addChild(text)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
