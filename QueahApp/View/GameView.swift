//
// Copyright 2023 Stephen E. Bensley
//
// This file is licensed under the MIT License. You may obtain a copy of the
// license at https://github.com/stephenbensley/Queah/blob/main/LICENSE.
//

import SpriteKit
import SwiftUI

struct GameView: View {
    var model: QueahModel
    @Environment(\.scenePhase) private var scenePhase
    var body: some View {
        GeometryReader { geo in
            SpriteView(scene: GameScene(size: CGSize(width: geo.size.width,
                                                     height: geo.size.height),
                                        model: model))
        }
        .edgesIgnoringSafeArea(.all)
        .onChange(of: scenePhase) { phase in
            if phase == .inactive {
                model.save()
            }
        }
    }
}
