//
// Copyright 2023 Stephen E. Bensley
//
// This file is licensed under the MIT License. You may obtain a copy of the
// license at https://github.com/stephenbensley/Queah/blob/main/LICENSE.
//

import SwiftUI

struct MenuItem: View {
    var text: String
    var symbol: String = "chevron.right"
    var action: () -> Void
    
    var body: some View {
        HStack {
            Text(text)
            Spacer()
            Image(systemName: symbol)
                .font(.subheadline.bold())
                .foregroundColor(Color(QColor.tertiaryLabel))
        }
        .onTapGesture {
            action()
        }
    }
}

enum ViewType {
    case game
    case rules
}

struct MenuView: View {
    let model = QueahModel.load() ?? QueahModel()
    @State var path: [ViewType] = []
    @Environment(\.openURL) var openURL
    
    var body: some View {
        NavigationStack(path: $path) {
            List {
                MenuItem(text: "Play as White vs. Computer") {
                    model.newGame(white: .human, black: .computer)
                    navigate(to: .game)
                }
                MenuItem(text: "Play as Black vs. Computer") {
                    model.newGame(white: .computer, black: .human)
                    navigate(to: .game)
                }
                MenuItem(text: "Player vs. Player") {
                    model.newGame(white: .human, black: .human)
                    navigate(to: .game)
                }
                MenuItem(text: "Resume Game") {
                    navigate(to: .game)
                }
                MenuItem(text: "How to Play") {
                    navigate(to: .rules)
                }
                MenuItem(text: "Privacy Policy", symbol: "link") {
                    if let url = URL(string: "http://www.daddario.com") {
                        openURL(url)
                    }
                }
            }
            .navigationDestination(for: ViewType.self) { type in
                switch type {
                case .game:
                    GameView(model: model)
                case .rules:
                    RulesView()
                }
            }
        }
    }
    
    func navigate(to viewType: ViewType) -> Void {
        path.append(viewType)
    }
}

struct MenuView_Previews: PreviewProvider {
    static var previews: some View {
        MenuView()
    }
}
