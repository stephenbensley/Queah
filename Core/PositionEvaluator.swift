//
// Copyright 2024 Stephen E. Bensley
//
// This file is licensed under the MIT License. You may obtain a copy of the
// license at https://github.com/stephenbensley/Queah/blob/main/LICENSE.
//

import Foundation
import UtiliKit

// Type used for storing game values. A game never takes more than 91 half-moves, so 8 bits is
// plenty. Using an Int8 reduces both disk and memory footprint.
typealias GameValue = Int8

extension Array where Element: Hashable {
    // Remove duplicate elements from the array.
    func deduplicated() -> [Element] {
        var seen = Set<Element>()
        return filter { seen.insert($0).inserted }
    }
}

// Stores the cached position values to allow rapid evaluation of game states.
final class PositionEvaluator {
    // All reachable values of GamePosition.boardId in sorted order
    private let ids: [UInt32]
    // This is conceptually a 3D array where the dimensions are:
    //     1. Index of boardId in the ids array
    //     2. attacker's reserve count
    //     3. defender's reserve count
    // It is stored as a 1D array to reduce both disk and memory footprint.
    private var values: [GameValue]
    
    // Fixed dimensions of the values array.
    static let dim = Queah.maxReserveCount + 1
    static let dimSq = dim * dim
    
    var count: Int { ids.count }
    
    init(nodes: borrowing [GameNode]) {
        ids = nodes.map( { $0.position.boardId }).deduplicated().sorted()
        values = [Int8](repeating: 0, count: ids.count * Self.dimSq)
        nodes.forEach { setValue(position: $0.position, value: $0.value) }
    }

    // Create a PositionEvaluator from binary data. Using JSON would increase file size 4x.
    init?(data: borrowing Data) {
        // Storage needed for each position.
        let positionSize = MemoryLayout<UInt32>.size + Self.dimSq * MemoryLayout<GameValue>.size
        // Compute how many positions are present in the data
        let count = data.count / positionSize
        // Better not be any left over.
        if data.count % positionSize != 0 {
            return nil
        }
        // Find the division between ids and values.
        let div = MemoryLayout<UInt32>.size * count
        
        self.ids = data.subdata(in: 0..<div).withUnsafeBytes {
            [UInt32]($0.bindMemory(to: UInt32.self))
        }
        self.values = data.subdata(in: div..<data.count).withUnsafeBytes {
            [GameValue]($0.bindMemory(to: GameValue.self))
        }
    }
    
    convenience init?(forResource: String, withExtension: String) {
        guard let url = Bundle.main.url(
            forResource: forResource,
            withExtension: withExtension
        ) else {
            return nil
        }
        guard let data = try? Data(contentsOf: url) else {
            return nil
        }
        self.init(data: data)
    }

    func encode() -> Data {
        let idsData = ids.withUnsafeBytes { Data($0) }
        let valuesData = values.withUnsafeBytes { Data($0) }
        return idsData + valuesData
     }
    
    func evaluate(position: GamePosition) -> GameValue {
        values[index(position.canonical)]
    }
    
    private func index(_ position: GamePosition) -> Int {
        // Compute the indices into the 3D array
        let idx1 = ids.bsearch(for: position.boardId)!
        let idx2 = position.attacker.reserveCount
        let idx3 = position.defender.reserveCount
        // Now compute the final offset
        return (Self.dimSq * idx1) + (Self.dim * idx2) + idx3
    }

    private func setValue(position: GamePosition, value: GameValue) {
        values[index(position)] = value
    }
}
