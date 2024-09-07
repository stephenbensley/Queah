//
// Copyright 2023 Stephen E. Bensley
//
// This file is licensed under the MIT License. You may obtain a copy of the
// license at https://github.com/stephenbensley/Queah/blob/main/LICENSE.
//

import CheckersKit
import SpriteKit
import SwiftUI

// Provides the app-specific properties and methods consumed by the CheckersKit framework.
class QueahGame: CheckersGame {
    private let model: QueahModel
    private let scene: GameScene

    init() {
        let model = QueahModel.create()
        self.model = model
        self.scene = GameScene(appModel: model)
    }

    // AppInfo protocol
    var appStoreId: Int = 6450433350
    var copyright: String = "© 2024 Stephen E. Bensley"
    var description: String = "A strategy game from Liberia"
    var gitHubAccount: String = "stephenbensley"
    var gitHubRepo: String = "Queah"
    
    // CheckersGame protocol
    func getScene(size: CGSize, exitGame: @escaping () -> Void) -> SKScene {
        scene.addedToView(size: size, exitGame: exitGame)
        return scene
    }
    func newGame(white: PlayerType, black: PlayerType) {
        model.newGame(white: white, black: black)
    }
    func save() {
        model.save()
    }
    
    static let shared = QueahGame()
}

@main
struct QueahApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView(game: QueahGame.shared)
        }
    }
}
