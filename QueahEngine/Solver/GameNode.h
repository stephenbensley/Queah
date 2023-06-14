//
// Copyright 2023 Stephen E. Bensley
//
// This file is licensed under the MIT License. You may obtain a copy of the
// license at https://github.com/stephenbensley/obatgonu/blob/main/LICENSE.
//

#ifndef GameNode_h
#define GameNode_h

#include "GamePosition.h"
#include "PositionEvaluator.h"

// Represents a node in the game tree.
class GameNode
{
public:
   // Note: The constructor does *not* initialize the children. These must
   // be added manually through calls to insert_child. This is necessary to
   // properly collapse transpositions in the game tree.
   explicit GameNode(GamePosition pos) noexcept;

   GamePosition position() const noexcept;
   ValueType value() const noexcept;

   // Returns true if the node is terminal, i.e., the node has no children and
   // the game is over.
   bool terminal() const noexcept;
   // Returns the minimum value of all the child nodes. Must only be called for
   // non-terminal nodes.
   ValueType min_child_value() const noexcept;

   // Called when building the game tree. Duplicate children are ignored.
   void insert_child(GameNode* child);
   // Called when solving the game.
   void set_value(ValueType value) noexcept;
   
private:
   GamePosition pos_;
   ValueType value_ = 0;
   std::vector<GameNode*> children_;
};

#endif /* GameNode_h */
