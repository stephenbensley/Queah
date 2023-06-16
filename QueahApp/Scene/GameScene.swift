//
// Copyright 2023 Stephen E. Bensley
//
// This file is licensed under the MIT License. You may obtain a copy of the
// license at https://github.com/stephenbensley/Queah/blob/main/LICENSE.
//

import SpriteKit
import SwiftUI
import QueahEngine

#if os(iOS)
typealias QColor = UIColor
#elseif os(macOS)
typealias QColor = NSColor
#endif

class MenuButton: SKNode {
    init(text: String) {
        super.init()
        
        let bg = SKShapeNode(rectOf: CGSize(width: 125, height: 50), cornerRadius: 10)
        bg.lineWidth = 1.5
        addChild(bg)
        
        let text = SKLabelNode(text: text)
        text.fontName = "Helvetica-Bold"
        text.fontSize = 20
        text.verticalAlignmentMode = .center
        bg.addChild(text)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

enum Layer: CGFloat {
    case gameBoard
    case boardSpace
    case gamePiece
    case gamePieceMoving
}

class GameScene: SKScene {
    @Binding var mainView: ViewType
    private let game: QueahGame
    private let ai: QueahAI
    private var playerType: [PlayerType]
    private let status = SKLabelNode()
    private let board = GameBoard()
    private let menuButton = MenuButton(text: "Main Menu")
    private var acceptInput: Bool = false
    private var selected: GamePiece? = nil
    private var legalMoves: [QueahMove] = []
    
    init(viewType: Binding<ViewType>, size: CGSize, model: QueahModel) {
        self._mainView = viewType
        self.game = model.game
        self.ai = model.ai
        self.playerType = model.playerType
        super.init(size: GameScene.adjustAspect(frame: size))

        self.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        self.backgroundColor = QColor(red: 105/255,
                                      green: 157/255,
                                      blue: 181/255,
                                      alpha: 1.0)
        self.scaleMode = .aspectFit
        
        status.position = CGPoint(x: 0, y: 290)
        status.fontName = "Helvetica-Bold"
        status.fontSize = 24
        
        board.setupPieces(model: game)
        menuButton.position = CGPoint(x: 0, y: -310)

        addChild(status)
        addChild(board)
        addChild(menuButton)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private static func adjustAspect(frame: CGSize) -> CGSize {
        var width = CGFloat(390)
        var height = CGFloat(700)
        let idealAspect = height / width
        
        let actualAspect = frame.height / frame.width
        
        if actualAspect > idealAspect {
            height = width * actualAspect
        } else {
            width = height / actualAspect
        }
        
        return CGSize(width: width, height: height)
    }
    
    override func didMove(to view: SKView) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            self?.nextMove()
        }
    }
    
    private func nextMove() -> Void {
        if game.isOver() || (game.repetitions() == 3) {
            return gameOver()
        }
        
        switch playerType[game.playertoMove().rawValue] {
        case .human:
            nextHumanMove()
        case .computer:
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [unowned self] in
                self.nextComputerMove()
            }
        }
    }
    
    private func gameOver() -> Void {
        status.text = {
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
    }
    
    private func nextHumanMove() -> Void {
        acceptInput = true
        legalMoves = game.getMoves()
        assert(!legalMoves.isEmpty)
        let from = legalMoves[0].from
        if from != invalidIndex {
            if legalMoves.allSatisfy({ $0.from == from }) {
                onPieceTouched(piece: board.findPiece(at: BoardLocation(.inPlay, from))!)
            }
        }
    }
    
    private func nextComputerMove() -> Void {
        let move = ai.getMove(game: game)
        let from = {
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
        guard piece.player == game.playertoMove() else {
            return
        }
        guard piece != selected else {
            return
        }
        
        if let selected = self.selected {
            selected.select(selected: false)
            board.deselectAllSpaces()
        }
        
        selected = piece
        piece.select(selected: true)
        legalMoves.forEach {
            if $0.from == piece.location.engineIndex {
                board.selectSpace(index: Int($0.to))
            }
        }
    }
    
    private func onSpaceTouched(space: BoardSpace) -> Void {
        guard let from = selected else {
            return
        }
        
        if legalMoves.contains(where: {
            $0.from == from.location.engineIndex &&
            $0.to == space.location.engineIndex
        }) {
            from.select(selected: false)
            selected = nil
            legalMoves = []
            board.deselectAllSpaces()
            acceptInput = false
            makeMove(from: from.location, to: space.location)
        }
    }
    
    func touchDown(atPoint pos: CGPoint) {
        guard acceptInput else {
            return
        }
        if menuButton.contains(pos) {
            mainView = .menu
            return
        }
        let node = atPoint(pos)
        if let piece = node as? GamePiece {
            onPieceTouched(piece: piece)
        } else if let space = node as? BoardSpace {
            onSpaceTouched(space: space)
        }
    }
    
#if os(iOS)
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchDown(atPoint: t.location(in: self))}
    }
#elseif os(macOS)
    override func mouseDown(with event: NSEvent) {
        self.touchDown(atPoint: event.location(in: self))
    }
#endif
}
