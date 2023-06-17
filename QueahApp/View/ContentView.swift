//
// Copyright 2023 Stephen E. Bensley
//
// This file is licensed under the MIT License. You may obtain a copy of the
// license at https://github.com/stephenbensley/Queah/blob/main/LICENSE.
//

import SwiftUI

struct QueahColor {
    static let background  = QueahColor.fromHex(0x699DB5)
    static let boardFill   = QueahColor.fromHex(0xE7CB7E)
    static let boardStroke = QueahColor.fromHex(0x4E3524)
    
    static func fromHex(_ hex: UInt) -> Color {
        let r = Double((hex & 0xff0000) >> 16) / 255
        let g = Double((hex & 0x00ff00) >>  8) / 255
        let b = Double((hex & 0x0000ff)      ) / 255
        return Color(red: r, green: g, blue: b)
    }
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
            QueahColor.background
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
