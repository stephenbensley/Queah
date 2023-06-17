//
// Copyright 2023 Stephen E. Bensley
//
// This file is licensed under the MIT License. You may obtain a copy of the
// license at https://github.com/stephenbensley/Queah/blob/main/LICENSE.
//

import SpriteKit

class MenuButton: SKNode {
    override init() {
        super.init()
        
        let bg = SKShapeNode(rectOf: CGSize(width: 150, height: 55), cornerRadius: 20)
        bg.lineWidth = 5
        addChild(bg)
        
        let text = SKLabelNode(text: "Main Menu")
        text.fontName = "Helvetica"
        text.fontSize = 20
        text.verticalAlignmentMode = .center
        bg.addChild(text)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
