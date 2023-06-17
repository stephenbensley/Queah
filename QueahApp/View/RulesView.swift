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
                .padding()
            }
            ScrollView {
                Text(contents)
                    .foregroundStyle(.white)
            }
            .padding(.horizontal, 20)
        }
    }
    
    static func load() -> AttributedString {
        guard let url = Bundle.main.url(forResource: "rules", withExtension: "rtf") else {
            fatalError("Failed to locate rules.rtf in bundle.")
        }
        
        let options: [NSAttributedString.DocumentReadingOptionKey : Any] = [
            .documentType: NSAttributedString.DocumentType.rtf
        ]
        
        guard let contents = try? NSAttributedString(url: url,
                                                     options: options,
                                                     documentAttributes: nil) else {
            fatalError("Failed to load rules.rtf from bundle.")
        }
        
        return AttributedString(contents)
    }
}
