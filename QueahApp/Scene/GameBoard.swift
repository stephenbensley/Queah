//
// Copyright 2023 Stephen E. Bensley
//
// This file is licensed under the MIT License. You may obtain a copy of the
// license at https://github.com/stephenbensley/Queah/blob/main/LICENSE.
//

import SpriteKit

// Represents the Queah game board.
final class GameBoard: SKSpriteNode {
    // Index in the array is the same as index used by the engine
    private let spaces: [BoardSpace]
    
    init() {
        self.spaces = (0..<Queah.spaceCount).map { BoardSpace(index: $0) }
        
        let texture = SKTexture(imageNamed: "game-board")
        super.init(texture: texture, color: .clear, size: texture.size())

        self.zPosition = Layer.gameBoard.rawValue
        spaces.forEach { addChild($0) }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupPieces(model: GameModel) {
        for index in model.pieces(for: .white) {
            addChild(GamePiece(player: .white, location: BoardLocation(.inPlay, index)))
        }
        for index in model.pieces(for: .black) {
            addChild(GamePiece(player: .black, location: BoardLocation(.inPlay, index)))
        }
        for index in 0 ..< model.reserveCount(for: .white) {
            addChild(GamePiece(player: .white, location: BoardLocation(.whiteReserve, index)))
        }
        for index in 0 ..< model.reserveCount(for: .black) {
            addChild(GamePiece(player: .black, location: BoardLocation(.blackReserve, index)))
        }
    }
    
    func deselectAllSpaces() {
        spaces.forEach { $0.selected = false }
    }
    
    func selectSpace(index: Int) {
        spaces[index].selected = true
    }
    
    func makeMove(from: BoardLocation,
                  to: BoardLocation,
                  completion block: @escaping () -> Void) {
        findPiece(at: from)!.makeMove(to: to, completion: block);
    }
    
    func removePiece(from: BoardLocation) {
        findPiece(at: from)!.remove()
    }
    
    func findPiece(at location: BoardLocation) -> GamePiece? {
        children.compactMap({ $0 as? GamePiece }).first(where: { $0.location == location })
    }
}
