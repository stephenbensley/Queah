//
// Copyright 2023 Stephen E. Bensley
//
// This file is licensed under the MIT License. You may obtain a copy of the
// license at https://github.com/stephenbensley/Queah/blob/main/LICENSE.
//

#ifndef Solve_h
#define Solve_h

#include "GameNode.h"
#include <memory>
#include <vector>

using GameNodePtr = std::unique_ptr<GameNode>;
using GameNodePtrs = std::vector<GameNodePtr>;

// Constructs all the nodes in the game tree.
GameNodePtrs build_nodes();

// Computes the values of all the game positions.
void compute_values(const GameNodePtrs& nodes) noexcept;

// Converts GameNodePtrs to PositionValues.
PositionValues to_position_values(const GameNodePtrs& nodes);

#endif /* Solve_h */
