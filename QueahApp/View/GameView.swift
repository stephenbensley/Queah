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
        VStack {
            SpriteView(scene: GameScene(model: model))
                .frame(width: 390, height: 700)
                .ignoresSafeArea()
        }
        .onChange(of: scenePhase) { phase in
            if phase == .inactive {
                model.save()
            }
        }
    }
}
