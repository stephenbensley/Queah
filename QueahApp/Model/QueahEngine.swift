//
// Copyright 2023 Stephen E. Bensley
//
// This file is licensed under the MIT License. You may obtain a copy of the
// license at https://github.com/stephenbensley/Queah/blob/main/LICENSE.
//

import Foundation
import QueahEngine

let numSpacesOnBoard = Int(QUEAH_NUM_SPACES_ON_BOARD)
let maxPiecesOnBoard = Int(QUEAH_MAX_PIECES_ON_BOARD)
let maxPiecesInReserve =  Int(QUEAH_MAX_PIECES_IN_RESERVE)
let invalidIndex = Int(QUEAH_INVALID_INDEX)

// Must be in sync with the #defines in QueahEngine.h
enum PlayerColor: Int {
    case white = 0
    case black = 1
}

extension QueahMove {
    init(from: Int, to: Int) {
        self.init(from: Int32(from), to: Int32(to))
    }
}

class QueahGame {
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
    
    func getPieces(player: PlayerColor) -> [Int] {
        var buffer = [Int32](repeating: 0, count: maxPiecesOnBoard)
        var bufLen = Int32(buffer.count)
        queah_game_get_pieces(game, Int32(player.rawValue), &buffer, &bufLen)
        
        var result = [Int]()
        for index in 0 ..< Int(bufLen) {
            result.append(Int(buffer[index]))
        }
        return result
    }
    
    func reserveCount(player: PlayerColor) -> Int {
        return Int(queah_game_reserve_count(game, Int32(player.rawValue)))
    }
    
    func playertoMove() -> PlayerColor {
        let result = queah_game_player_to_move(game)
        return PlayerColor(rawValue: Int(result))!
    }
    
    func isOver() -> Bool {
        let result = queah_game_is_over(game)
        return result != 0
    }
   
    func repetitions() -> Int {
        return Int(queah_game_repetitions(game))
    }
    
    func movesCompleted() -> Int {
        return Int(queah_game_moves_completed(game))
    }
    
    func getMoves() -> [QueahMove] {
        // I believe 23 is the theoretical max, but no harm in a safety margin.
        // W:6* B:0
        // -   -   -
        //   O   O
        // -   -   -
        //   O   O
        // -   -   X
        var buffer = [QueahMove](repeating: QueahMove(), count: 32)
        var bufLen = Int32(buffer.count)
        queah_game_get_moves(game, &buffer, &bufLen)
        buffer.removeLast(buffer.count - Int(bufLen))
        return buffer
    }
    
    func makeMove(move: QueahMove) -> Int {
        var captured: Int32 = 0
        let result = queah_game_make_move(game, move, &captured)
        assert(result == 0)
        return Int(captured)
    }

    func reset() -> Void {
        queah_game_reset(game)
    }
    
    func toString() -> String {
        var buffer = [CChar](repeating: 0, count: 256)
        queah_game_to_string(game, &buffer, Int32(buffer.count))
        return String(cString: buffer)
    }
    
    func encode() -> Data {
        // Usage is ~ 40 * moves_completed. 16k is plenty.
        var buffer = [CChar](repeating: 0, count: 0x4000)
        var bufLen = Int32(buffer.count)
        let result = queah_game_encode(game, &buffer, &bufLen)
        assert(result == 0)
        return Data(bytes: &buffer, count: Int(bufLen))
    }
    
    func decode(data: Data) -> Bool {
         let result = data.withUnsafeBytes {
            queah_game_decode(game,
                              $0.baseAddress!.assumingMemoryBound(to: CChar.self),
                              Int32($0.count))
        }
        return result == 0
     }
}

class QueahAI {
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
    
    func getMove(game: QueahGame) -> QueahMove {
        var move = QueahMove()
        queah_ai_get_move(ai, game.handle, &move)
        return move
    }
}
