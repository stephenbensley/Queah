//
// Copyright 2023 Stephen E. Bensley
//
// This file is licensed under the MIT License. You may obtain a copy of the
// license at https://github.com/stephenbensley/Queah/blob/main/LICENSE.
//

import Foundation
import SpriteKit

class GameBoard: SKSpriteNode {
    private var spaces: [BoardSpace] = []
    
    init() {
        let texture = SKTexture(imageNamed: "game-board")
        super.init(texture: texture, color: .clear, size: texture.size())
        self.zPosition = Layer.gameBoard.rawValue
        
        for index in 0 ..< numSpacesOnBoard {
            let space = BoardSpace(index: index)
            spaces.append(space)
            addChild(space)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupPieces(model: QueahGame) -> Void {
        for index in model.getPieces(player: .white) {
            addChild(GamePiece(player: .white, location: BoardLocation(.inPlay, index)))
        }
        for index in model.getPieces(player: .black) {
            addChild(GamePiece(player: .black, location: BoardLocation(.inPlay, index)))
        }
        for index in 0 ..< model.reserveCount(player: .white) {
            addChild(GamePiece(player: .white, location: BoardLocation(.whiteReserve, index)))
        }
        for index in 0 ..< model.reserveCount(player: .black) {
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
