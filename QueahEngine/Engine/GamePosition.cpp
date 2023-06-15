//
// Copyright 2023 Stephen E. Bensley
//
// This file is licensed under the MIT License. You may obtain a copy of the
// license at https://github.com/stephenbensley/Queah/blob/main/LICENSE.
//

#include "GamePosition.h"
#include <algorithm>
#include <cassert>

bool operator==(Move lhs, Move rhs) noexcept
{
   return (lhs.to == rhs.to) &&
          (lhs.from == rhs.from) &&
          (lhs.capturing == rhs.capturing);
}

GamePosition::GamePosition(PlayerPosition attacker,
                           PlayerPosition defender) noexcept
: attacker_(attacker), defender_(defender)
{ }

GamePosition::GamePosition(uint32_t id) noexcept
: attacker_(id >> 16u), defender_(id & 0xffff)
{ }

uint32_t GamePosition::id() const noexcept
{
   return (static_cast<uint32_t>(attacker_.id()) << 16u) | defender_.id();
}

PlayerPosition GamePosition::attacker() const noexcept
{
   return attacker_;
}

PlayerPosition GamePosition::defender() const noexcept
{
   return defender_;
}

std::pair<PlayerPosition, PlayerPosition>
GamePosition::by_player(PlayerIndex to_move) const noexcept
{
   if (to_move == 0) {
      return { attacker_, defender_ };
   } else {
      return { defender_, attacker_ };
   }
}

bool GamePosition::is_terminal() const
{
   return moves().empty();
}

Moves GamePosition::moves() const
{
   auto moves = drops();
   auto caps = captures();
   if (!caps.empty()) {
      moves += caps;
   } else {
      // Captures are forced, so only add simple_moves if no captures are
      // available.
      moves += simple_moves();
   }
   return moves;
}

bool GamePosition::is_legal_move(Move move) const
{
   auto legal = moves();
   return std::find(legal.begin(), legal.end(), move) != legal.end();
}

void GamePosition::make_move(Move move) noexcept
{
   attacker_.move(move.from, move.to);
   if (is_valid_index(move.capturing)) {
      defender_.remove(move.capturing);
   }
   reverse();
}

GamePosition GamePosition::try_move(Move move) const noexcept
{
   GamePosition result(*this);
   result.make_move(move);
   return result;
}

GamePosition GamePosition::canonical() const noexcept
{
   GamePosition result(*this);
   GamePosition candidate(*this);
   
   // Try all three other rotations.
   for (auto i = 1; i < num_move_directions; ++i) {
      candidate.rotate();
      result = std::min(result, candidate);
   }
   
   // Mirror the board.
   candidate.mirror();
   result = std::min(result, candidate);
   
   // Now try the three mirrored rotations.
   for (auto i = 1; i < num_move_directions; ++i) {
      candidate.rotate();
      result = std::min(result, candidate);
   }

   return result;
}

const GamePosition GamePosition::start {
   PlayerPosition(bitboard_start_player0, max_pieces_in_reserve),
   PlayerPosition(bitboard_start_player1, max_pieces_in_reserve)
};

bool GamePosition::occupied(int index) const
{
   return attacker_.occupies(index) || defender_.occupies(index);
}

Moves GamePosition::simple_moves() const
{
   Moves result;
   for (auto i = 0; i < num_spaces_on_board; ++i) {
      if (attacker_.occupies(i)) {
         for (auto neighbor : neighbors_for_space[i]) {
            // If the adjacent space is empty, then we can move.
            if (is_valid_index(neighbor.adjacent) &&
                !occupied(neighbor.adjacent)) {
               result.push_back({ i, neighbor.adjacent, invalid_index });;
            }
         }
      }
   }
   return result;
}

Moves GamePosition::captures() const
{
   Moves result;
   for (auto i = 0; i < num_spaces_on_board; ++i) {
      if (attacker_.occupies(i)) {
         for (auto neighbor : neighbors_for_space[i]) {
            // If the jump_to space is empty and the adjacent space is occupied
            // by an opposing piece, then we can capture.
            if (is_valid_index(neighbor.jump_to) &&
                !occupied(neighbor.jump_to) &&
                defender_.occupies(neighbor.adjacent)) {
               result.push_back({ i, neighbor.jump_to, neighbor.adjacent });
            }
         }
      }
   }
   return result;
}

Moves GamePosition::drops() const
{
   Moves result;
   if (attacker_.can_drop()) {
      for (auto i = 0; i < num_spaces_on_board; ++i) {
         if (!occupied(i)) {
            result.push_back({ invalid_index, i, invalid_index });
         }
      }
   }
   return result;
}

void GamePosition::reverse() noexcept
{
   std::swap(attacker_, defender_);
}

void GamePosition::mirror() noexcept
{
   attacker_.mirror();
   defender_.mirror();
}

void GamePosition::rotate() noexcept
{
   attacker_.rotate();
   defender_.rotate();
}

bool operator<(GamePosition lhs, GamePosition rhs) noexcept
{
   return lhs.id() < rhs.id();
}

bool operator==(GamePosition lhs, GamePosition rhs) noexcept
{
   return lhs.id() == rhs.id();
}

Moves& operator+=(Moves& lhs, const Moves& rhs) noexcept
{
   lhs.insert(lhs.end(), rhs.begin(), rhs.end());
   return lhs;
}
