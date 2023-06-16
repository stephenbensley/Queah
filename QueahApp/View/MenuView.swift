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

struct MenuView: View {
    @Binding var mainView: ViewType
    var model: QueahModel
    @Environment(\.openURL) var openURL
    
    var body: some View {
        List {
            MenuItem(text: "Play as White vs. Computer") {
                model.newGame(white: .human, black: .computer)
                mainView = .game
            }
            MenuItem(text: "Play as Black vs. Computer") {
                model.newGame(white: .computer, black: .human)
                mainView = .game
            }
            MenuItem(text: "Player vs. Player") {
                model.newGame(white: .human, black: .human)
                mainView = .game
            }
            MenuItem(text: "Resume Game") {
                mainView = .game
            }
            MenuItem(text: "How to Play") {
                mainView = .rules
            }
            MenuItem(text: "Privacy Policy", symbol: "link") {
                if let url = URL(string: "http://www.daddario.com") {
                    openURL(url)
                }
            }
        }
    }
}
