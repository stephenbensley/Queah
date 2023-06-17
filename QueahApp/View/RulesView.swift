//
// Copyright 2023 Stephen E. Bensley
//
// This file is licensed under the MIT License. You may obtain a copy of the
// license at https://github.com/stephenbensley/Queah/blob/main/LICENSE.
//

import SwiftUI

struct RulesView: View {
    @Binding var mainView: ViewType
    let contents = load()
    
    var body: some View {
        VStack {
            HStack(spacing: 15) {
                Spacer()
                Button("Done") {
                    mainView = .menu
                }
                .padding(5)
            }
            HStack {
                Text("Rules of Queah")
                    .font(.custom("Helvetica-Bold", fixedSize: 28))
                    .padding(.bottom, 20)
                Spacer()
            }
            ScrollView {
                Text(contents)
                    .font(.custom("Helvetica", fixedSize: 18))
            }
        }
        .foregroundStyle(.white)
        .padding(.horizontal, 20)
        
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
