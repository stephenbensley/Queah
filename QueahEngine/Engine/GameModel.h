//
// Copyright 2023 Stephen E. Bensley
//
// This file is licensed under the MIT License. You may obtain a copy of the
// license at https://github.com/stephenbensley/Queah/blob/main/LICENSE.
//

#ifndef GameModel_h
#define GameModel_h

#include "GamePosition.h"
#include "PositionTracker.h"
#include <string>

// Tracks all the state associated with a game of Queah
class GameModel
{
public:
   GameModel() noexcept;

   // Current game position.
   GamePosition position() const noexcept;
   // Next player to move.
   PlayerIndex to_move() const noexcept;
   
   // Is the game over?
   bool is_over() const noexcept;
   // Number of times this game position has occurred.
   int repetitions() const noexcept;
   // Number of times an arbitrary game position has occurred.
   int repetitions(GamePosition position, PlayerIndex to_move) const noexcept;
   // Number of moves completed. Moves are counted like chess.
   int moves_completed() const noexcept;
 
   // Updates the games making the specified move.
   void make_move(Move move);
 
   // Reset and begin a new game.
   void reset() noexcept;
   
   // Returns a string representation of the current game state.
   std::string to_string() const;
   
   // Encode/decode the model to/from a buffer.
   void encode(std::ostringstream& ostrm) const;
   bool decode(std::istringstream& istrm);

private:
   GamePosition position_ = GamePosition::start;
   PlayerIndex to_move_ = 0;
   PositionTracker tracker_;
   int num_half_moves_ = 0;
};

#endif /* GameModel_h */
