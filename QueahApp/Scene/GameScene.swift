//
// Copyright 2023 Stephen E. Bensley
//
// This file is licensed under the MIT License. You may obtain a copy of the
// license at https://github.com/stephenbensley/Queah/blob/main/LICENSE.
//

import SpriteKit
import SwiftUI
import QueahEngine

extension CGSize {
    var aspectRatio: CGFloat {
        return height / width
    }
}

enum Layer: CGFloat {
    case gameBoard
    case boardSpace
    case gamePiece
    case gamePieceMoving
    case gameOver
    case gameOutcome
}

// Renders the game for the user.
class GameScene: SKScene {
    // Used to return the app to the main menu
    @Binding var mainView: ViewType
    // Next three members are copied from the model. They are referenced so frequently, that
    // it's convenient to copy them out of the QueahModel struct.
    private let game: QueahGame
    private let ai: QueahAI
    private var playerType: [PlayerType]
    // Sprites that make up the game.
    private let board = GameBoard()
    private let menuButton = MenuButton()
    // Indicates if we're currently accepting moves from a human player.
    private var acceptInput: Bool = false
    // Tracks the currently selected game piece -- if any
    private var selected: GamePiece? = nil
    // The legal moves for the current game position when a human is playing.
    private var legalMoves: [QueahMove] = []
    
    init(viewType: Binding<ViewType>, size: CGSize, model: QueahModel) {
        self._mainView = viewType
        self.game = model.game
        self.ai = model.ai
        self.playerType = model.playerType
        super.init(size: GameScene.adjustAspect(frame: size))
        
        self.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        self.backgroundColor = UIColor(QueahColor.background)
        self.scaleMode = .aspectFit
        
        board.setupPieces(model: game)
        addChild(board)
        
        menuButton.position = CGPoint(x: 0, y: -310)
        addChild(menuButton)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private static func adjustAspect(frame: CGSize) -> CGSize {
        // This is the minimal window into the game. We want this portion of the graphics to
        // fill as much of the screen as possible without being clipped.
        var size = CGSize(width: 390, height: 750)

        // Aspect ratio of the GameView
        let viewAspectRatio = frame.aspectRatio
        
        if viewAspectRatio > size.aspectRatio {
            // View is skinnier, so stretch the height
            size.height = size.width * viewAspectRatio
        } else {
            // View is fatter, so stretch the width
            size.width = size.height / viewAspectRatio
        }
        
        return size
    }
    
    override func didMove(to view: SKView) {
        nextMove()
    }
    
    private func nextMove() -> Void {
        if game.isOver() || (game.repetitions() == 3) {
            return gameOver()
        }
        
        switch playerType[game.playertoMove().rawValue] {
        case .human:
            nextHumanMove()
        case .computer:
            // Introduce a slight delay, so the computer appears to think for a bit.
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [unowned self] in
                self.nextComputerMove()
            }
        }
    }
    
    private func gameOver() -> Void {
        let text = {
            if game.isOver() {
                switch game.playertoMove() {
                case .white:
                    return "Black wins!"
                case .black:
                    return "White wins!"
                }
            } else {
                return "Draw by repetition."
            }
        }()
        
        let background = SKShapeNode(rectOf: CGSize(width: 300, height: 100), cornerRadius: 20)
        background.alpha = 0.0
        background.fillColor = UIColor(QueahColor.background)
        background.lineWidth = 5
        background.zPosition = Layer.gameOver.rawValue
        addChild(background)
        
        let movingText = SKLabelNode(text: text)
        movingText.fontName = "Helvetica-Bold"
        movingText.fontSize = 24
        movingText.verticalAlignmentMode = .center
        movingText.zPosition = Layer.gameOver.rawValue
        background.addChild(movingText)
        
        let stationaryText = SKLabelNode(text: text)
        stationaryText.fontName = movingText.fontName
        stationaryText.fontSize = movingText.fontSize
        stationaryText.isHidden = true
        stationaryText.position = CGPoint(x: 0, y: 290)
        stationaryText.verticalAlignmentMode = .center
        stationaryText.zPosition = Layer.gameOutcome.rawValue
        addChild(stationaryText)
        
        background.run(SKAction.sequence([
            SKAction.fadeIn(withDuration: 0.25),
            SKAction.wait(forDuration: 2.0),
            SKAction.moveTo(y: 290, duration: 0.35),
            SKAction.fadeOut(withDuration: 0.50),
            SKAction.removeFromParent()
        ]))
        
        stationaryText.run(SKAction.sequence([
            SKAction.wait(forDuration: 2.6),
            SKAction.unhide()
        ]))
    }
    
    private func nextHumanMove() -> Void {
        acceptInput = true
        legalMoves = game.getMoves()
        assert(!legalMoves.isEmpty)
        let from = legalMoves[0].from
        if from != invalidIndex {
            // If the user can only move one piece, select it for them.
            if legalMoves.allSatisfy({ $0.from == from }) {
                onPieceTouched(piece: board.findPiece(at: BoardLocation(.inPlay, from))!)
            }
        }
    }
    
    private func nextComputerMove() -> Void {
        let move = ai.getMove(game: game)
        let from = {
            // If the computer is dropping a piece, pick the actual reserve piece to drop.
            if move.from == invalidIndex {
                switch game.playertoMove() {
                case .white:
                    return BoardLocation(.whiteReserve, game.reserveCount(player: .white) - 1)
                case .black:
                    return BoardLocation(.blackReserve, game.reserveCount(player: .black) - 1)
                }
            } else {
                return BoardLocation(.inPlay, move.from)
            }
        }()
        makeMove(from: from, to: BoardLocation(.inPlay, move.to))
    }
    
    private func makeMove(from: BoardLocation, to: BoardLocation) -> Void {
        let captured = game.makeMove(move: QueahMove(from: from.engineIndex, to: to.engineIndex))
        board.makeMove(from: from, to: to) { [unowned self] in
            self.nextMove()
        }
        if captured != invalidIndex {
            board.removePiece(from: BoardLocation(.inPlay, captured))
        }
    }
    
    private func onPieceTouched(piece: GamePiece) -> Void {
        // If the player touched his opponent's piece, ignore.
        guard piece.player == game.playertoMove() else {
            return
        }
        // If he touched the the piece that's already selected, it's a no-op.
        guard piece != selected else {
            return
        }
        
        // Clear the existing selection.
        if let selected = self.selected {
            selected.select(selected: false)
            board.deselectAllSpaces()
        }
        
        // Highlight the new selection
        selected = piece
        piece.select(selected: true)
        
        // Highlight all the moves for the new selection.
        legalMoves.forEach {
            if $0.from == piece.location.engineIndex {
                board.selectSpace(index: Int($0.to))
            }
        }
    }
    
    private func onSpaceTouched(space: BoardSpace) -> Void {
        // Touching an empty space does nothing unless a piece has been selected.
        guard let from = selected else {
            return
        }
        
        // Check if this is a legal move.
        guard legalMoves.contains(where: {
            $0.from == from.location.engineIndex &&
            $0.to == space.location.engineIndex
        }) else {
            return
        }
        
        // Clear the selection since the player's turn is over.
        from.select(selected: false)
        selected = nil
        board.deselectAllSpaces()
        legalMoves = []
        
        // Stop accepting input.
        acceptInput = false
        
        // Execute the selected move.
        makeMove(from: from.location, to: space.location)
        
    }
    
    func touchDown(atPoint pos: CGPoint) {
        // We don't act on the menu button until it's released, but we highlight it
        // as soon as it's pressed.
        if menuButton.contains(pos) {
            assert(!menuButton.highlighted)
            menuButton.highlighted = true
        }
        
        guard acceptInput else {
            return
        }
        
        let node = atPoint(pos)
        if let piece = node as? GamePiece {
            onPieceTouched(piece: piece)
        } else if let space = node as? BoardSpace {
            onSpaceTouched(space: space)
        }
    }
    
    func touchMoved(atPoint pos: CGPoint) {
        // If they dragged off the button, deselect.
        if menuButton.highlighted && !menuButton.contains(pos) {
            menuButton.highlighted = false
        }
    }
    
    func touchUp(atPoint pos: CGPoint) {
        // If they released the button, take action.
        if menuButton.highlighted && menuButton.contains(pos) {
            menuButton.highlighted = false
            mainView = .menu
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchDown(atPoint: t.location(in: self))}
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchMoved(atPoint: t.location(in: self))}
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchUp(atPoint: t.location(in: self))}
    }
}
