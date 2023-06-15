//
// Copyright 2023 Stephen E. Bensley
//
// This file is licensed under the MIT License. You may obtain a copy of the
// license at https://github.com/stephenbensley/Queah/blob/main/LICENSE.
//

#include "Solve.h"
#include "GameNode.h"
#include <unordered_map>

using NodeMap = std::unordered_map<uint32_t, GameNodePtr>;

// Finds the node in the map or adds a new node to the map if the node doesn't
// already exist. Returns a shallow pointer to the node. The map has node
// ownership.
GameNode* find_or_create(NodeMap& nodes, GamePosition pos);

// Assigns values to all terminal nodes.
int compute_values_pass0(const GameNodePtrs& nodes) noexcept;
// Assigns values to all nodes that can reach a terminal node in 'n' moves
// with perfect play.
int compute_values_passn(const GameNodePtrs& nodes, int n) noexcept;

GameNodePtrs build_nodes()
{
   // Creating the root node will recursively create all reachable nodes.
   NodeMap nodes;
   find_or_create(nodes, GamePosition::start);
   
   // Move the nodes from a map to a vector.
   GameNodePtrs result;
   result.reserve(nodes.size());
   for (auto& n : nodes) {
      result.push_back(std::move(n.second));
   }
   return result;
}

void compute_values(const GameNodePtrs& nodes) noexcept
{
   auto updated = compute_values_pass0(nodes);
   if (updated > 0) {
      // Keep iterating until we stop making progress.
      for (auto pass = 1; compute_values_passn(nodes, pass) != 0; ++pass)
      { }
   }
}

PositionValues to_position_values(const GameNodePtrs& nodes)
{
   PositionValues result;
   result.reserve(nodes.size());
   for (const auto& node : nodes) {
      result.push_back({ node->position(), node->value() });
   }
   return result;
}

GameNode* find_or_create(NodeMap& nodes, GamePosition pos)
{
   // The canonical id is used to index nodes.
   auto key = pos.canonical();
   auto id = key.id();
   
   // If it's already in the map, we're done.
   auto i = nodes.find(id);
   if (i != nodes.end()) {
      return i->second.get();
   }
   
   // Create a new node and retrieve its pointer.
   auto [j, success] = nodes.insert({ id, std::make_unique<GameNode>(key) });
   assert(success);
   auto node = j->second.get();
   
   // Recursively find and insert the children. Note: We must insert the parent
   // node before creating the children since there may be loops in the graph.
   for (auto m : key.moves()) {
      node->insert_child(find_or_create(nodes, key.try_move(m)));
   }
   
   // Return a pointer to the newly inserted node.
   return node;
}

int compute_values_pass0(const GameNodePtrs& nodes) noexcept
{
   int updated = 0;
   for (const auto& node : nodes) {
      if (node->terminal()) {
         // A terminal node means that the attacker has no moves and thus has
         // lost the game, so the value is always negative.
         node->set_value(-max_value);
         ++updated;
      }
   }
   return updated;
}

int compute_values_passn(const GameNodePtrs& nodes, int n) noexcept
{
   // Max value assigned on the previous pass.
   auto prev_max = max_value - (n - 1);
   int updated = 0;
   for (const auto& node : nodes) {
      // Ignore nodes that already have a value assigned.
      if (node->value() == 0) {
         auto min_child = node->min_child_value();
         if (min_child == prev_max) {
            // All children are wins for the opponent, so the attacker can't
            // avoid losing.
            assert(-min_child < std::numeric_limits<ValueType>::max());
            node->set_value(-min_child + 1);
            ++updated;
         } else if (min_child == -prev_max) {
            // At least one child is a loss for the opponent. Thus, the
            // attacker can win by making that move.
            assert(-min_child > std::numeric_limits<ValueType>::min());
            node->set_value(-min_child - 1);
            ++updated;
         }
      }
   }
   return updated;
}
