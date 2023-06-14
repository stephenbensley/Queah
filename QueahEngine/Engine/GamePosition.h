//
// Copyright 2023 Stephen E. Bensley
//
// This file is licensed under the MIT License. You may obtain a copy of the
// license at https://github.com/stephenbensley/obatgonu/blob/main/LICENSE.
//

#ifndef GamePosition_h
#define GamePosition_h

#include "PlayerPosition.h"
#include <vector>

// Represents a game move. If from == reserve_index, this is a drop. If
// capturing is an invalid index, no capture occurs.
struct Move {
   int from;
   int to;
   int capturing;
};
using Moves = std::vector<Move>;

bool operator==(Move lhs, Move rhs) noexcept;

// Represents the state of the game.
class GamePosition
{
public:
   GamePosition(PlayerPosition attacker, PlayerPosition defender) noexcept;
   explicit GamePosition(uint32_t id) noexcept;
   
   // Returns an integer uniquely identifying this position.
   uint32_t id() const noexcept;

   PlayerPosition attacker() const noexcept;
   PlayerPosition defender() const noexcept;
   // Returns the positions for player 0 and player 1.
   std::pair<PlayerPosition, PlayerPosition>
   by_player(PlayerIndex to_move) const noexcept;
   
   // Returns true if the game is over.
   bool is_terminal() const;
   // Returns all legal moves from the position.
   Moves moves() const;
   // Returns true if the move is allowed from this position.
   bool is_legal_move(Move move) const;

   // Updates the position according to the move.
   void make_move(Move move) noexcept;
   // Determines the result of a move without actually changing the position.
   GamePosition try_move(Move move) const noexcept;
   
   // Returns the canonical format of the move. Useful for collapsing game
   // positions that are strategically identical.
   GamePosition canonical() const noexcept;
   
   // Starting position for the game.
   static const GamePosition start;
   
private:
   // Returns true if either player occupies the space.
   bool occupied(int index) const;
   
   // All legal non-capturing moves.
   Moves simple_moves() const;
   // All legal capturing moves.
   Moves captures() const;
   // All legal drops.
   Moves drops() const;

   // Reverse the attacker and defender.
   void reverse() noexcept;
   // Reflects the board horizontally.
   void mirror() noexcept;
   // Rotates the player's pieces clockwise.
   void rotate() noexcept;

   // Player with the next move.
   PlayerPosition attacker_;
   // Player without the next move.
   PlayerPosition defender_;
};

// Allows GamePositions to be sorted etc.
bool operator<(GamePosition lhs, GamePosition rhs) noexcept;
bool operator==(GamePosition lhs, GamePosition rhs) noexcept;

// Useful for collecting moves.
Moves& operator+=(Moves& lhs, const Moves& rhs) noexcept;

#endif /* GamePosition_h */
