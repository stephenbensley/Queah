//
// Copyright 2023 Stephen E. Bensley
//
// This file is licensed under the MIT License. You may obtain a copy of the
// license at https://github.com/stephenbensley/obatgonu/blob/main/LICENSE.
//

#include "ToString.h"

// Strings used to represent the spaces on the board.
constexpr char white_piece[] = "O ";
constexpr char black_piece[] = "X ";
constexpr char empty_space[] = "- ";
constexpr char blank_space[] = "  ";

// Returns a character indicating whether the player is next to move.
char move_indicator(PlayerIndex player, PlayerIndex to_move) noexcept
{
   return (player == to_move) ? '*' : ' ';
}

// Returns a string representing a space on the board.
std::string_view to_string(PlayerPosition white,
                           PlayerPosition black,
                           int index) noexcept
{
   if (white.occupies(index)) {
      return white_piece;
   }
   if (black.occupies(index)) {
      return black_piece;
   }
   return empty_space;
}

std::string to_string(GamePosition pos, PlayerIndex to_move)
{
   std::string result;
   auto [white, black] = pos.by_player(to_move);
   
   // Header line with reserve counts and an indicator of who moves next.
   result += "W:";
   result += std::to_string(white.reserve_count());
   result += move_indicator(0, to_move);
   result += " B:";
   result += std::to_string(black.reserve_count());
   result += move_indicator(1, to_move);
   result += '\n';
   
   // Although there are only 13 spaces in the game, we represent it as a
   // 5x5 board (similar to a checkboard).
   for (auto i = 0; i < 25; ++i) {
      if (i % 2 == 0) {
         // Even squares are in play and could be occupied.
         result += to_string(white, black, (24 - i)/2);
      } else {
         // Odd squares are always blank.
         result += blank_space;
      }
      // Add a newline at the end of each row.
      if ((i % 5) == 4) {
         result += '\n';
      }
   }
   
   return result;
}
