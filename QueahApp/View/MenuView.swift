//
// Copyright 2023 Stephen E. Bensley
//
// This file is licensed under the MIT License. You may obtain a copy of the
// license at https://github.com/stephenbensley/Queah/blob/main/LICENSE.
//

import SwiftUI

struct MenuItem: View {
    var text: LocalizedStringKey
    var action: () -> Void
    
    var body: some View {
        Text(text)
            .font(.custom("Helvetica", fixedSize: 20))
            .frame(width: 250)
            .padding()
            .background(QueahColor.boardBackground)
            .cornerRadius(20)
            .overlay(RoundedRectangle(cornerRadius: 20)
                .stroke(QueahColor.border, lineWidth: 5)
            )
            .padding(2)
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
        VStack {
            Spacer()
            Text("Queah")
                .font(.custom("Helvetica-Bold", fixedSize: 40))
                .foregroundStyle(.white)
            Text("An abstract strategy game from Liberia")
                .font(.custom("Helvetica", fixedSize: 15))
                .foregroundStyle(.white)
                .padding(.bottom)
            Group {
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
                    if let url = URL(string: "http://www.daddario.com") {
                        openURL(url)
                    }
                }
            }
            Spacer()
            Spacer()
        }
    }
}
