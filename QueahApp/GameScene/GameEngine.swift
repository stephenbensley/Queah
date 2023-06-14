//
// Copyright 2023 Stephen E. Bensley
//
// This file is licensed under the MIT License. You may obtain a copy of the
// license at https://github.com/stephenbensley/obatgonu/blob/main/LICENSE.
//

import Foundation
import QueahEngine

let numSpacesOnBoard: Int = Int(QUEAH_NUM_SPACES_ON_BOARD)
let maxPiecesOnBoard: Int = Int(QUEAH_MAX_PIECES_ON_BOARD)
let maxPiecesInReserve: Int =  Int(QUEAH_MAX_PIECES_IN_RESERVE)
let invalidIndex: Int = Int(QUEAH_INVALID_INDEX)

enum PlayerColor: Int {
    case white = 0
    case black = 1
}

struct GameMove {
    let from: Int
    let to: Int
    
    init(from: Int, to: Int) {
        self.from = from
        self.to = to
    }
    
    init(move: QueahMove) {
        self.from = Int(move.from)
        self.to = Int(move.to)
    }
    
    var asQueahMove: QueahMove {
        return QueahMove(from: Int32(from), to: Int32(to))
    }
}

class GameModel {
    private var game: UnsafeMutableRawPointer?
    
    init() {
        game = queah_game_create()
        if game == nil {
            fatalError("Failed to create Queah game.")
        }
    }
    
    deinit {
        queah_game_destroy(game)
    }
    
    var handle: UnsafeMutableRawPointer? {
        return game
    }
    
    func isOver() -> Bool {
        let result = queah_game_is_over(game)
        return result != 0
    }
    
    func newGame() -> Void {
        queah_game_destroy(game)
        game = queah_game_create()
        if game == nil {
            fatalError("Failed to create Queah game.")
        }
    }
    
    func playertoMove() -> PlayerColor {
        let result = queah_game_player_to_move(game)
        return PlayerColor(rawValue: Int(result))!
    }
    
    func repetitions() -> Int {
        return Int(queah_game_repetitions(game))
    }
    
    func reserveCount(player: PlayerColor) -> Int {
        return Int(queah_game_reserve_count(game, Int32(player.rawValue)))
    }
                   
    func getMoves() -> [GameMove] {
        var buffer = [QueahMove](repeating: QueahMove(), count: numSpacesOnBoard)
        var bufLen = Int32(buffer.count)
        queah_game_get_moves(game, &buffer, &bufLen)
        
        var result = [GameMove]()
        for index in 0..<Int(bufLen) {
            result.append(GameMove(move: buffer[index]))
        }
        return result
    }
    
    func makeMove(move: GameMove) -> Int {
        var captured: Int32 = 0
        let result = queah_game_make_move(game, move.asQueahMove, &captured)
        assert(result == 0)
        return Int(captured)
    }
}

class GameAI {
    private var ai: UnsafeMutableRawPointer?
    
    init() {
        guard let url = Bundle.main.url(forResource: "queah", withExtension: "dat") else {
            fatalError("Failed to locate queah.dat in bundle.")
        }
        ai = queah_ai_create(url.path)
        if ai == nil {
            fatalError("Failed to create Queah AI.")
        }
    }
    
    deinit {
        queah_ai_destroy(ai)
    }
    
    func getMove(game: GameModel) -> GameMove {
        var move = QueahMove()
        queah_ai_get_move(ai, game.handle, &move)
        return GameMove(move: move)
    }
}
