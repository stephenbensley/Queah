 <img src="docs/app-icon.png" alt="icon" width="75" height="75">

# Queah

Queah is an iOS app for the the [Liberian game of Queah](https://en.wikipedia.org/wiki/Liberian_Queah). The app lets you play against the computer or another human player (by pass-and-play). The computer implements a mathematically optimal strategy. You can learn a lot about the game by watching how the computer AI plays. When playing against the computer, you also have the option of displaying a hint showing your best available move.

### Installation

The app can be downloaded for free from the Apple [App Store](https://apps.apple.com/us/app/id6450433350/). There are no in-app purchases or ads.

### Privacy

This app does not collect or share any personal information. For complete details, read the [Privacy Policy](https://stephenbensley.github.io/Queah/privacy.html)

### License

The source code for this app has been released under the [MIT License](LICENSE).

### Copyright

© 2024 Stephen E. Bensley

## Building from Source

The app was developed with [Xcode](https://developer.apple.com/xcode/), which is freely available from Apple. After installing Xcode and cloning the repo, open the Xcode [project](Queah.xcodeproj) at the root of the repo. The Git tags correspond to App Store releases. Checkout the most recent tag to ensure a stable build.

### Dependencies

The app depends on two Swift Packages (both developed by me): [UtiliKit](https://github.com/stephenbensley/UtiliKit) and [CheckersKit](https://github.com/stephenbensley/CheckersKit). These should be resolved automatically when you open and build the project.

### Targets

The Xcode project has the following targets:

- Queah: The iOS app.
- QueahSolver: A MacOS app that solves the game. Make sure you build the Release configuration; Debug will be very slow.
