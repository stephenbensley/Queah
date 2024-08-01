# Queah

Queah is an iOS app that lets you play the [Liberian game of Queah](https://en.wikipedia.org/wiki/Liberian_Queah) against another player or the computer. The code consists of three top-level components:
1. [QueahEngine](QueahEngine) contains the core game logic and an AI capable of perfect play.
2. The AI relies on a precomputed solution file [queahSolution.data](QueahApp/Resources/queahSolution.data) that is bundled along with the engine. The solution file is created offline by a MacOS app: [QueahSolver](QueahSolver).
3. QueahApp implements the iOS app. The app is implemented using SwiftUI and SpriteKit. For more information about the app, see the [app store listing](https://apps.apple.com/us/app/queah/id6450433350/).
