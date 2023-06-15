//
// Copyright 2023 Stephen E. Bensley
//
// This file is licensed under the MIT License. You may obtain a copy of the
// license at https://github.com/stephenbensley/Queah/blob/main/LICENSE.
//

#ifndef PositionTracker_h
#define PositionTracker_h

#include "GamePosition.h"
#include <unordered_map>

// Tracks the number of times a game position has been reached.
class PositionTracker
{
public:
   // Returns the number of times the position has been seen.
   int repetitions(GamePosition position, PlayerIndex to_move) const noexcept;
   
   // Increments the repetition count.
   void visit(GamePosition position, PlayerIndex to_move);
   
   // Resets all counts to start a new game.
   void reset() noexcept;
   
   // Load/save the data from/to a buffer.
   bool load(std::istringstream& istrm);
   void save(std::ostringstream& ostrm) const;

private:
   static uint64_t get_key(GamePosition position, PlayerIndex to_move) noexcept;
   
   std::unordered_map<uint64_t, int> counts_;
};

#endif /* PositionTracker_h */
