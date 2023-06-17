//
// Copyright 2023 Stephen E. Bensley
//
// This file is licensed under the MIT License. You may obtain a copy of the
// license at https://github.com/stephenbensley/Queah/blob/main/LICENSE.
//

import SwiftUI

struct QueahColor {
    static let mainBackground = Color("main-background")
    static let boardBackground = Color("board-background")
    static let border = Color("border")
}

enum ViewType {
    case menu
    case game
    case rules
}

struct ContentView: View {
    var model: QueahModel
    @State var mainView = ViewType.menu
    
    var body: some View {
        ZStack {
            QueahColor.mainBackground
                .edgesIgnoringSafeArea(.all)
            switch mainView {
            case .menu:
                MenuView(mainView: $mainView.animation(), model: model)
            case .game:
                GameView(mainView: $mainView.animation(), model: model)
            case .rules:
                RulesView(mainView: $mainView.animation())
            }
        }
    }
}
