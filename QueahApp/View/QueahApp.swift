//
// Copyright 2023 Stephen E. Bensley
//
// This file is licensed under the MIT License. You may obtain a copy of the
// license at https://github.com/stephenbensley/Queah/blob/main/LICENSE.
//

import SwiftUI

@main
struct QueahApp: App {
    let model = QueahModel.load() ?? QueahModel()
    @Environment(\.scenePhase) private var scenePhase

    var body: some Scene {
        WindowGroup {
            ContentView(model: model)
        }
        .onChange(of: scenePhase) { phase in
            if phase == .inactive {
                model.save()
            }
        }
    }
}
