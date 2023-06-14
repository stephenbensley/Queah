//
// Copyright 2023 Stephen E. Bensley
//
// This file is licensed under the MIT License. You may obtain a copy of the
// license at https://github.com/stephenbensley/obatgonu/blob/main/LICENSE.
//

import Foundation
import SpriteKit

class GameBoard: SKSpriteNode {
    private var spaces: [BoardSpace] = []
    
    static private let whiteStart: [Int] = [ 0,  1,  3,  4]
    static private let blackStart: [Int] = [ 8,  9, 11, 12]
    
    init() {
        let texture = SKTexture(imageNamed: "board")
        super.init(texture: texture, color: .clear, size: texture.size())
        self.zPosition = Layer.gameBoard.rawValue
        
        for index in 0 ..< numSpacesOnBoard {
            let space = BoardSpace(index: index)
            spaces.append(space)
            addChild(space)
        }
        
        setupPieces()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func reset() -> Void {
        deselectAllSpaces()
        clearPieces()
        setupPieces()
    }
    
    private func clearPieces() -> Void {
        for child in children {
            if let piece = child as? GamePiece {
                piece.remove()
            }
        }
    }
    
    private func setupPieces() -> Void {
        for index in GameBoard.whiteStart {
            addChild(GamePiece(player: .white, location: BoardLocation(.inPlay, index)))
        }
        for index in GameBoard.blackStart {
            addChild(GamePiece(player: .black, location: BoardLocation(.inPlay, index)))
        }
        for index in 0..<maxPiecesInReserve {
            addChild(GamePiece(player: .white, location: BoardLocation(.whiteReserve, index)))
        }
        for index in 0..<maxPiecesInReserve {
            addChild(GamePiece(player: .black, location: BoardLocation(.blackReserve, index)))
        }
    }
    
    func deselectAllSpaces() -> Void {
        spaces.forEach { $0.select(selected: false) }
    }
    
    func selectSpace(index: Int) -> Void {
        spaces[index].select(selected: true)
    }
    
    func makeMove(from: BoardLocation,
                  to: BoardLocation,
                  completion block: @escaping () -> Void) -> Void {
        findPiece(at: from)!.makeMove(to: to, completion: block);
    }
    
    func removePiece(from: BoardLocation) -> Void {
        findPiece(at: from)!.remove()
    }
    
    func findPiece(at location: BoardLocation) -> GamePiece? {
        for child in children {
            if let piece = child as? GamePiece {
                if piece.location == location {
                    return piece
                }
            }
        }
        return nil
    }
    
    private func findSpace(at index: Int) -> BoardSpace {
        return spaces[index]
    }
}
