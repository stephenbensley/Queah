//
// Copyright 2023 Stephen E. Bensley
//
// This file is licensed under the MIT License. You may obtain a copy of the
// license at https://github.com/stephenbensley/Queah/blob/main/LICENSE.
//

import SpriteKit
import SwiftUI

// Presents the SpriteKit game scene
struct GameView: View {
    @Binding var mainView: ViewType
    var model: QueahModel
    
    var body: some View {
        GeometryReader { geo in
            SpriteView(scene: GameScene(viewType: $mainView, size: geo.size, model: model))
        }
        .edgesIgnoringSafeArea(.all)
    }
}
