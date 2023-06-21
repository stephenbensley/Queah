# Queah

Queah is an iOS app that lets you play the [Liberian game of Queah](https://en.wikipedia.org/wiki/Liberian_Queah) against another player or the computer. The code consists of two top-level components:
1. QueahEngine contains the core game logic and an AI capable of perfect play.
2. QueahApp implements the iOS app.

## QueahEngine

The Queah engine is implemented in C++ and is accessed via a C API declared in [QueahEngine.h](QueahEngine/Engine/QueahEngine.h). The engine was developed under Xcode on MacOS. However, the code is completely standards-compliant and should be easily ported to other platforms.

The API exposes two objects:
1. QueahGame tracks game state and implements the game rules.
2. QueahAI returns the best move for any game state.

There is a [sample](QueahEngine/Sample/main.c) demonstrating how to call the API.

The AI relies on a precomputed solution file [queah.dat](QueahEngine/Data/queah.dat) that must be bundled along with the engine. The solution file is created offline by [QueahSolver](QueahEngine/Solver).

## QueahApp

The Queah iOS app is implemented in Swift using SwiftUI and SpriteKit. For more information about the app, see the [app store listing](https://apps.apple.com/us/app/queah/id6450433350/).
