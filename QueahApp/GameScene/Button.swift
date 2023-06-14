//
// Copyright 2023 Stephen E. Bensley
//
// This file is licensed under the MIT License. You may obtain a copy of the
// license at https://github.com/stephenbensley/obatgonu/blob/main/LICENSE.
//

import Foundation
import SpriteKit

class Button: SKNode {
    init(text: String) {
        super.init()
        
        let bg = SKShapeNode(rectOf: CGSize(width: 125, height: 50), cornerRadius: 10)
        bg.lineWidth = 1.5
        addChild(bg)
        
        let text = SKLabelNode(text: text)
        text.fontName = "Helvetica-Bold"
        text.fontSize = 20
        text.verticalAlignmentMode = .center
        bg.addChild(text)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
