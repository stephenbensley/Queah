//
// Copyright 2023 Stephen E. Bensley
//
// This file is licensed under the MIT License. You may obtain a copy of the
// license at https://github.com/stephenbensley/Queah/blob/main/LICENSE.
//

#include "GameNode.h"
#include <algorithm>

GameNode::GameNode(GamePosition pos) noexcept
: pos_(pos)
{ }

GamePosition GameNode::position() const noexcept
{
   return pos_;
}

ValueType GameNode::value() const noexcept
{
   return value_;
}

bool GameNode::terminal() const noexcept
{
   return children_.empty();
}

ValueType GameNode::min_child_value() const noexcept
{
   auto i = std::min_element(children_.begin(),
                             children_.end(),
                             [](auto lhs, auto rhs) {
      return lhs->value() < rhs->value();
   });
   return (*i)->value();
}

void GameNode::insert_child(GameNode* child)
{
   if (std::find(children_.begin(),
                 children_.end(),
                 child) == children_.end()) {
      children_.push_back(child);
   }
}

void GameNode::set_value(ValueType value) noexcept
{
   assert(value_ == 0);
   assert(value != 0);
   value_ = value;
}
