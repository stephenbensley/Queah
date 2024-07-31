//
// Copyright 2024 Stephen E. Bensley
//
// This file is licensed under the MIT License. You may obtain a copy of the
// license at https://github.com/stephenbensley/Queah/blob/main/LICENSE.
//

// Represents a node in the game tree.
final class GameNode: Equatable {
    // There may be cycles in the game tree, so we need to track children by unowned references.
    struct NodeRef: Equatable {
        unowned let p: GameNode
    }

    let position: GamePosition
    var value: GameValue = 0
    private var children = [NodeRef]()
    
    // Note: The initializer does *not* initialize the children. These must be added manually
    // through calls to insert. This is necessary to properly collapse transpositions in the
    // game tree. Similarly, value is not set until after the entire tree has been built.
    init(position: GamePosition) {
        self.position = position
    }
    
    // Returns true if the node is terminal, i.e., the node has no children and the game is over.
    var terminal: Bool { return children.isEmpty }
    
    // Returns the minimum value of all the child nodes.
    var minChildValue: GameValue { children.min(by: { $0.p.value < $1.p.value })?.p.value ?? 0 }
    
    // Called when building the game tree. Duplicate children are ignored.
    func insert(child: GameNode) {
        let ref = NodeRef(p: child)
        if !children.contains(ref) {
            children.append(ref)
        }
    }
    
    static func == (lhs: GameNode, rhs: GameNode) -> Bool {
        lhs.position == rhs.position
    }
}
