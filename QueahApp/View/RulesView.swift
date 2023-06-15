//
// Copyright 2023 Stephen E. Bensley
//
// This file is licensed under the MIT License. You may obtain a copy of the
// license at https://github.com/stephenbensley/Queah/blob/main/LICENSE.
//

import SwiftUI

struct RulesView: View {
    var contents = load()
    
    var body: some View {
        ScrollView {
            Text(contents)
        }
        .padding()
    }
    
    static func load() -> AttributedString {
        guard let url = Bundle.main.url(forResource: "rules", withExtension: "rtf") else {
            fatalError("Failed to locate rules.rtf in bundle.")
        }
        
        guard let contents = try? NSAttributedString(url: url,
                                                     options: [NSAttributedString.DocumentReadingOptionKey.documentType: NSAttributedString.DocumentType.rtf],
                                                     documentAttributes: nil) else {
            fatalError("Failed to load rules.rtf from bundle.")
        }
        
        return AttributedString(contents)
    }
}

struct RulesView_Previews: PreviewProvider {
    static var previews: some View {
        RulesView()
    }
}
