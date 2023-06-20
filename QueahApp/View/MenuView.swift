//
// Copyright 2023 Stephen E. Bensley
//
// This file is licensed under the MIT License. You may obtain a copy of the
// license at https://github.com/stephenbensley/Queah/blob/main/LICENSE.
//

import SwiftUI

// An item in the main menu
struct MenuItem: View {
    var text: LocalizedStringKey
    var action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(text)
                .font(.custom("Helvetica", fixedSize: 20))
                .frame(width: 250)
                .padding()
                .background(QueahColor.boardFill)
                .cornerRadius(20)
                .overlay(RoundedRectangle(cornerRadius: 20)
                    .stroke(QueahColor.boardStroke, lineWidth: 5)
                )
        }
        .buttonStyle(PlainButtonStyle())
        .padding(2)
    }
}

// Presents the main menu of options for the user to choose from.
struct MenuView: View {
    @Binding var mainView: ViewType
    var model: QueahModel
    @Environment(\.horizontalSizeClass) var sizeClass
    @Environment(\.openURL) private var openURL

    var scale: CGFloat {
        return sizeClass == .compact ? 1.0 : 1.5
    }
    
    var body: some View {
        VStack {
            Spacer()
            VStack {
                Text("Queah")
                    .font(.custom("Helvetica-Bold", fixedSize: 40))
                    .foregroundStyle(.white)
                Text("A strategy game from Liberia")
                    .font(.custom("Helvetica", fixedSize: 18))
                    .foregroundStyle(.white)
                    .padding(.bottom)
                MenuItem(text: "White vs. Computer") {
                    model.newGame(white: .human, black: .computer)
                    mainView = .game
                }
                MenuItem(text: "Black vs. Computer") {
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
                MenuItem(text: "Privacy Policy  \(Image(systemName: "link"))") {
                    if let url = URL(string: "https://stephenbensley.github.io/Queah/privacy.html") {
                        openURL(url)
                    }
                }
                
            }
            .scaleEffect(scale, anchor: .center)
            Spacer()
            Spacer()
        }
    }
}
