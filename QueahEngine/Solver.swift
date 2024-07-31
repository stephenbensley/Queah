//
// Copyright 2024 Stephen E. Bensley
//
// This file is licensed under the MIT License. You may obtain a copy of the
// license at https://github.com/stephenbensley/Queah/blob/main/LICENSE.
//

// Solves the game of Queah
final class Solver {
    // GameNodes indexed by id
    private var nodes = [UInt32: GameNode]()
    
    // Private since public entry point is the static solve function.
    private init() { }
    
    static func solve() -> PositionEvaluator {
        Solver().solve()
    }
    
    private func solve() -> PositionEvaluator {
        // Creating the root node will recursively create all reachable nodes.
        let _ = findOrCreate(position: GamePosition.start)
        
        // Use retrograde analysis to fill in the values. Start with pass 0
        var pass = 0
        var updated = computeValuesPass0()
        
        // Then keep iterating until we stop making progress.
        while updated > 0 {
            pass += 1
            updated = computeValuesPassN(n: pass)
        }
        
        // Convert to a position evaluator.
        return PositionEvaluator(nodes: Array(nodes.values))
    }
    
    private func findOrCreate(position: GamePosition) -> GameNode {
        // The canonical id is used to index nodes.
        let canonical = position.canonical()
        let id = canonical.id
        
        // If it's already in the dictionary, we're done.
        if let node = nodes[id] {
            return node
        }
        
        // Create a new node
        let node = GameNode(position: canonical)
        nodes[id] = node
        
        // Recursively find and insert the children. Note: We must insert the parent node before
        // creating the children since there may be loops in the graph.
        canonical.moves.forEach {
            node.insert(child: findOrCreate(position: canonical.tryMove(move: $0)))
        }
        
        return node
    }
    
    private func computeValuesPass0() -> Int {
        var updated = 0
        for (_, node) in nodes where node.terminal {
            // A terminal node means that the attacker has no moves and thus has lost the game, so
            // the value is always negative.
            node.value = -GameValue.max
            updated += 1
        }
        return updated
    }
    
    private func computeValuesPassN(n: Int) -> Int {
        // Max value assigned on the previous pass.
        let prevMax = GameValue.max - GameValue(n - 1)
        var updated = 0
        // Ignore nodes that already have a value assigned.
        for (_, node) in nodes where node.value == 0 {
            let minChildValue = node.minChildValue
            if minChildValue == prevMax {
                // All children are wins for the opponent, so the attacker can't avoid losing.
                node.value = -minChildValue + 1
                updated += 1
            } else if minChildValue == -prevMax {
                // At least one child is a loss for the opponent. Thus, the attacker can win by
                // making that move.
                node.value = -minChildValue - 1
                updated += 1
            }
        }
        return updated
    }
}
