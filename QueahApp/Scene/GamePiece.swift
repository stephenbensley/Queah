//
// Copyright 2023 Stephen E. Bensley
//
// This file is licensed under the MIT License. You may obtain a copy of the
// license at https://github.com/stephenbensley/Queah/blob/main/LICENSE.
//

import Foundation
import SpriteKit

class GamePiece: SKSpriteNode {
    let player: PlayerColor
    private var loc: BoardLocation
    
    static let whiteUnselected = SKTexture(imageNamed: "white-piece-unselected")
    static let blackUnselected = SKTexture(imageNamed: "black-piece-unselected")
    static let whiteSelected = SKTexture(imageNamed: "white-piece-selected")
    static let blackSelected = SKTexture(imageNamed: "black-piece-selected")

    static let moveDuration: CGFloat = 0.6
    
    init(player: PlayerColor, location: BoardLocation) {
        self.player = player
        self.loc = location
        let texture = GamePiece.getTexture(player: player)
        super.init(texture: texture, color: .clear, size: texture.size())
        self.position = location.center
        self.zPosition = Layer.gamePiece.rawValue
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
        
    var location: BoardLocation {
        return loc
    }
    
    func makeMove(to: BoardLocation, completion block: @escaping () -> Void) -> Void {
        self.loc = to
        run(SKAction.sequence([
            SKAction.run { [unowned self] in self.zPosition = Layer.gamePieceMoving.rawValue },
            SKAction.move(to: to.center, duration: GamePiece.moveDuration),
            SKAction.run { [unowned self] in self.zPosition = Layer.gamePiece.rawValue }
        ]),  completion: block)
    }
    
    func remove() -> Void {
        run(SKAction.sequence([
            SKAction.wait(forDuration: (GamePiece.moveDuration / 3.0)),
            SKAction.fadeOut(withDuration: ((2.0 * GamePiece.moveDuration) / 3.0)),
            SKAction.removeFromParent()
        ]))
    }
    
    func select(selected: Bool) -> Void {
        self.texture = GamePiece.getTexture(player: player, selected: selected)
    }
    
    private static func getTexture(player: PlayerColor, selected: Bool = false) -> SKTexture {
        switch player {
        case .white:
            return selected ? whiteSelected: whiteUnselected
        case .black:
            return selected ? blackSelected: blackUnselected
        }
    }
}
