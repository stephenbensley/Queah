//
// Copyright 2023 Stephen E. Bensley
//
// This file is licensed under the MIT License. You may obtain a copy of the
// license at https://github.com/stephenbensley/Queah/blob/main/LICENSE.
//

import CheckersKit
import SpriteKit
import SwiftUI
import UtiliKit

final class GameScene: SKScene {
    // Game coordinates are designed for this size.
    static private let minSize = CGSize(width: 390, height: 750)
    // Side length for the board spaces.
    static private let spaceLength = 75.0
    // Duration of the move animation.
    static let moveDuration: CGFloat = 0.6
    
    // Global game state
    private let game: QueahModel
    // Set by the enclosing SwiftUI view to allow this scene to return to the main menu.
    private var exitGame: (() -> Void)? = nil
    
    // Used to map logical board positions to screen coordinates.
    private let positions = BoardPositions()
    
    // These nodes are interacted with frequently, so we cache references to them.
    private let board = GameBoard()
    private let hintButton = SKButton("Hint", size: .init(width: 125, height: 45))
    private let menuButton = SKButton("Menu", size: .init(width: 125, height: 45))
    
    // MARK: Initialization
    
    init(appModel: QueahModel) {
        self.game = appModel
        super.init(size: Self.minSize)
        self.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        self.backgroundColor = .background
        self.scaleMode = .aspectFit
        
        // Add the permanent nodes.
        addChild(board)
        addTargets()
        hintButton.action = displayHint
        hintButton.position = .init(x: +80.0, y: -310.0)
        addChild(hintButton)
        menuButton.action = returnToMainMenu
        menuButton.position = .init(x: -80.0, y: -310.0)
        addChild(menuButton)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func addTargets() {
        for i in 0..<Queah.spaceCount {
            let target = BoardTarget(sideLength: Self.spaceLength, zRotation: CGFloat.pi / 2.0)
            // Doesn't matter which color we use, both colors use the same on-board indices.
            target.position = positions.position(.white, index: i)
            board.addChild(target)
        }
    }
    
    // Invoked when we've been added to a SwiftUI view.
    func addedToView(size: CGSize, exitGame: @escaping () -> Void) {
        self.size = Self.minSize.stretchToAspectRatio(size.aspectRatio)
        self.exitGame = exitGame
    }
    
    // MARK: Clean-up
    
    // Returns to a clean state by stopping all ongoing activity and clearing the gameboard.
    private func returnToMainMenu() {
        board.clear()
        exitGame?()
    }
    
    // MARK: Load state
    
    // Invoked when our scene is added to an SKView and will now be displayed.
    override func didMove(to view: SKView) {
        super.didMove(to: view)
        
        // Load state from the app model. This might have changed since we were last displayed.
        loadAppModel()
        
        // Kick off the game FSM.
        pickMove()
    }
    
    private func loadAppModel() {
        // Place the checkers on the board.
        board.clear()
        placeCheckers(player: .white)
        placeCheckers(player: .black)
        
        // Place the buttons based on whether we're in solo mode.
        if game.playerType[0] != game.playerType[1] {
            hintButton.enabled = false
            hintButton.isHidden = false
            menuButton.position = .init(x: -80.0, y: -310.0)
        } else {
            hintButton.isHidden = true
            menuButton.position = .init(x: 0, y: -310.0)
        }
    }
    
    private func placeCheckers(player: PlayerColor) {
        for piece in game.pieces(for: player) {
            let checker = Checker(player: player)
            checker.position = positions.position(player, index: piece)
            board.addChild(checker)
        }
    }
    
    // MARK: FSM entry points
    
    private func pickMove() {
        if game.isOver || (game.repetitions >= 3) {
            return displayOutcome()
        }
        
        switch game.currentType {
        case .human:
            hintButton.enabled = true
            board.pickMove(
                for: game.toMove,
                allowedMoves: game.moves.map(convertMove),
                onMovePicked: executeMove
            )
        case .computer:
            // Introduce a slight delay, so the computer appears to think for a bit.
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { self.pickComputerMove() }
        }
    }

    private func pickComputerMove() {
        let viewMove = convertMove(game.bestMove)
        guard let checker = board.checker(at: viewMove.from) else { return }
        executeMove(checker: checker, viewMove: viewMove)
    }
    
    private func executeMove(checker: Checker, viewMove: GameBoard.Move) {
        guard let move = viewMove.userData as? Move else { return }
        
        hintButton.enabled = false
        game.makeMove(move: move)
        
        Self.animateMove(checker: checker, to: viewMove.to, completion: pickMove)
        
        if move.capturing.isValidSpace {
            let position = positions.position(game.toMove.other, index: move.capturing)
            if let captured = board.checker(at: position) {
                Self.animateCapture(checker: captured)
            }
        }
    }
    
    func displayOutcome() {
        let text = game.isOver ? "\(game.toMove.other) wins!" : "Draw by repetition"
        board.displayOutcome(text: text)
     }
    
    func displayHint() {
        let viewMove = convertMove(game.bestMove)
        board.selectMove(viewMove)
    }

    // MARK: Animations
    
    private static func animateMove(checker: Checker, to: CGPoint, completion: @escaping () -> Void) {
        checker.run(
            SKAction.sequence([
                SKAction.setLayer(Layer.moving, onTarget: checker),
                SKAction.move(to: to, duration: moveDuration),
                SKAction.setLayer(Layer.checkers, onTarget: checker)
            ]),
            completion: completion
        )
    }
    
    private static func animateCapture(checker: Checker) {
        // We're being removed because we were captured. Delay the fade, so the capturing piece
        // has time to reach our space.
        checker.run(
            SKAction.sequence([
                SKAction.wait(forDuration: (moveDuration / 3.0)),
                SKAction.fadeOut(withDuration: ((2.0 * moveDuration) / 3.0)),
                SKAction.removeFromParent()
            ])
        )
    }
    
    // MARK: Convert between logical and screen positions
    
    private func convertMove(_ move: Move) -> GameBoard.Move {
        return .init(
            from: positions.position(game.toMove, index: move.from),
            to: positions.position(game.toMove, index: move.to),
            userData: move
        )
    }
}
