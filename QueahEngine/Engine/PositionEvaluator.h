//
// Copyright 2023 Stephen E. Bensley
//
// This file is licensed under the MIT License. You may obtain a copy of the
// license at https://github.com/stephenbensley/Queah/blob/main/LICENSE.
//

#ifndef PositionEvaluator_h
#define PositionEvaluator_h

#include "GameModel.h"
#include <cstdint>
#include <limits>
#include <vector>

// Value assigned to a position in the game. Assuming perfect play, a positive
// value indicates a win for the attacker; a negative value a win for the
// defender; and zero indicates a tie via endless repetition.
//
// The number of moves until end of game equals max_value - |value|.
using ValueType = int8_t;
constexpr int8_t max_value = std::numeric_limits<ValueType>::max();

// Binds a position to its value.
struct PositionValue {
   GamePosition position;
   ValueType value;
};
using PositionValues = std::vector<PositionValue>;

// Determines the best move for a GamePosition
class PositionEvaluator
{
public:
   PositionEvaluator() noexcept;
   // Positions are assumed to have been canonized.
   explicit PositionEvaluator(const PositionValues& data);
   
   // Evaluate the specified position.
   ValueType evaluate(GamePosition position) const noexcept;

   // Gets the best move for the specified game state.
   Move get_best_move(const GameModel& model) const noexcept;

   // Load/save the data from/to a file.
   bool load(const char* datafile);
   void save(const char* datafile) const noexcept;

private:
   // Stores all the values for a given BitBoard combination.
   struct Element {
      uint32_t key = 0;
      ValueType value[max_pieces_in_reserve + 1]
                     [max_pieces_in_reserve + 1] = { 0 };
   };
   
   // Computes a key that uniquely identifies the BitBoard combination.
   static uint32_t get_key(GamePosition position) noexcept;
   
   // vetor is kept sorted by key, so we can use binary search. This is done
   // to preserve memory on mobile devices (vs. using an unordered_map).
   std::vector<Element> elements_;
};

#endif /* PositionEvaluator_h */
