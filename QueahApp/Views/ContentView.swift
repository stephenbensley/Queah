//
// Copyright 2023 Stephen E. Bensley
//
// This file is licensed under the MIT License. You may obtain a copy of the
// license at https://github.com/stephenbensley/obatgonu/blob/main/LICENSE.
//

import SpriteKit
import SwiftUI

struct ContentView: View {
    var scene: SKScene {
        let scene = GameScene(playerColor: .white)
        return scene
    }
    
    var body: some View {
        SpriteView(scene: scene)
            .frame(width: 390, height: 844)
            .ignoresSafeArea()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
