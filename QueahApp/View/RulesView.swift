//
// Copyright 2023 Stephen E. Bensley
//
// This file is licensed under the MIT License. You may obtain a copy of the
// license at https://github.com/stephenbensley/Queah/blob/main/LICENSE.
//

import SwiftUI

// Displays the game rules.
struct RulesView: View {
    @Binding var mainView: ViewType
    var scale: CGFloat
    private let contents = load()
    
    // ScrollView doesn't play well with .scaleEffect, so we scale everything individually
    var body: some View {
        VStack {
            HStack {
                Spacer()
                Button(action: { mainView = .menu }) {
                    Text("Done")
                        .font(.custom("Helvetica", fixedSize: 18 * scale))
                }
                .padding(5 * scale)
            }
            HStack {
                Text("Rules of Queah")
                    .font(.custom("Helvetica-Bold", fixedSize: 28 * scale))
                    .padding(.bottom, 20 * scale)
                Spacer()
            }
            ScrollView {
                Text(contents)
                    .font(.custom("Helvetica", fixedSize: 18 * scale))
            }
        }
        .foregroundStyle(.white)
        .padding(.horizontal, 20 * scale)
        .frame(maxWidth: 500 * scale)
     }
    
    static func load() -> String {
        guard let path = Bundle.main.path(forResource: "rules", ofType: "txt") else {
            fatalError("Failed to locate rules.txt in bundle.")
        }
        
        guard let contents = try? String(contentsOfFile: path) else {
            fatalError("Failed to load rules.rtf from bundle.")
        }
        
        return contents
    }
}
