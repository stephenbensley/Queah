//
// Copyright 2023 Stephen E. Bensley
//
// This file is licensed under the MIT License. You may obtain a copy of the
// license at https://github.com/stephenbensley/Queah/blob/main/LICENSE.
//

import SwiftUI

@main
struct QueahApp: App {
    // We don't care if this doesn't load; we'll just fall back to defaults.
    private let model = QueahModel.create()
    @Environment(\.scenePhase) private var scenePhase

    var body: some Scene {
        WindowGroup {
            ContentView(model: model)
        }
        .onChange(of: scenePhase) { _, newPhase in
            if newPhase == .inactive {
                model.save()
            }
        }
    }
}
