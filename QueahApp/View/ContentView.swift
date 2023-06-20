//
// Copyright 2023 Stephen E. Bensley
//
// This file is licensed under the MIT License. You may obtain a copy of the
// license at https://github.com/stephenbensley/Queah/blob/main/LICENSE.
//

import SwiftUI

// Common colors used across the app.
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

// Common scaling used across the app.
struct QueahScale {
    // Area of the screen that must be preserved
    static let safeArea = CGSize(width: 390, height: 750)
    // Ignore scale factors less than this amount.
    static let minAdjustment = 1.1
    // Never use a scale factor greater than this amount.
    static let maxScaleFactor = 1.5

    static func scaleFactor(frame: CGSize) -> CGFloat {
        let scaleX = frame.width / safeArea.width
        let scaleY = frame.height / safeArea.height
        let scale = min(scaleX, scaleY)
        if (scale < minAdjustment) {
            return 1.0
        } else {
            return min(scale, maxScaleFactor)
        }
     }
}

// Signals which view to display.
enum ViewType {
    case menu
    case game
    case rules
}

// Main view just toggles between the three different subviews.
struct ContentView: View {
    var model: QueahModel
    @State private var mainView = ViewType.menu
    
    var body: some View {
        GeometryReader { geo in
            ZStack {
                QueahColor.background
                    .edgesIgnoringSafeArea(.all)
                switch mainView {
                case .menu:
                    MenuView(mainView: $mainView.animation(),
                             scale: QueahScale.scaleFactor(frame: geo.size),
                             model: model)
                case .game:
                    GameView(mainView: $mainView.animation(),
                             model: model)
                case .rules:
                    RulesView(mainView: $mainView.animation(),
                              scale: QueahScale.scaleFactor(frame: geo.size))
                }
            }
        }
    }
}
