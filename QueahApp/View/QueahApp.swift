//
// Copyright 2023 Stephen E. Bensley
//
// This file is licensed under the MIT License. You may obtain a copy of the
// license at https://github.com/stephenbensley/Queah/blob/main/LICENSE.
//

import SwiftUI

#if os(macOS)
class AppDelegate: NSObject, NSApplicationDelegate {
    var model: QueahModel?
    
    func applicationWillTerminate(_ aNotification: Notification) {
        model?.save()
    }
}
#endif

@main
struct QueahApp: App {
    let model = QueahModel.load() ?? QueahModel()
    @Environment(\.scenePhase) private var scenePhase
#if os(macOS)
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    init() {
        appDelegate.model = model
    }
#endif

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
