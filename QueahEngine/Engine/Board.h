//
// Copyright 2023 Stephen E. Bensley
//
// This file is licensed under the MIT License. You may obtain a copy of the
// license at https://github.com/stephenbensley/Queah/blob/main/LICENSE.
//

#ifndef Board_h
#define Board_h

#include <array>
#include <cstdint>

constexpr int num_players = 2;
constexpr int num_spaces_on_board = 13;
constexpr int num_move_directions = 4;
constexpr int max_pieces_on_board = 4;
constexpr int max_pieces_in_reserve = 6;

using PlayerIndex = int;

// Special index used to indicate any of the following:
// 1) No move is available in that direction.
// 2) No capture is possible.
// 3) The piece  is coming from the reserve, not the board.
constexpr int invalid_index = -1;

// Space indices:
// 12   11   10
//    9    8
//  7    6    5
//    4    3
//  2    1    0

// Direction  indices:
//  2   3
//    X
//  1   0

// Bit fields are used to indicate the piece locations. A BitBoard represents
// all the pieces of one player.
using BitBoard = uint16_t;

// Starting positions for players
constexpr BitBoard bitboard_start_player0 = 0b000'00'000'11'011;
constexpr BitBoard bitboard_start_player1 = 0b110'11'000'00'000;

// Table defining a 1:1 transposition of the spaces on the board
using Transposition = std::array<int, num_spaces_on_board>;

// Reflect the board horizontally
constexpr Transposition mirror_table = {
  2, 1, 0, 4, 3, 7, 6, 5, 9, 8, 12, 11, 10
};

// Rotate the board clockwise
constexpr Transposition rotate_table = {
  10, 5, 0, 8, 3, 11, 6, 1, 9, 4, 12, 7, 2
};

// Represents the neighboring spaces in a particular direction
struct Neighbor {
   // Index of the adjacent space or -1 if it doesn't exist.
   int adjacent;
   // Index of the space that can be jumped to or -1 if it doesn't exist.
   int jump_to;
};

// Neighbors for each possible direction.
using Neighbors = std::array<Neighbor, num_move_directions>;
// Neighbors for every space on the board.
using NeighborsForSpace = std::array<Neighbors, num_spaces_on_board>;

constexpr NeighborsForSpace neighbors_for_space =
{{
   {{{ -1, -1 }, { -1, -1 }, {  3,  6 }, { -1, -1 }}}, //  0
   {{{ -1, -1 }, { -1, -1 }, {  4,  7 }, {  3,  5 }}}, //  1
   {{{ -1, -1 }, { -1, -1 }, { -1, -1 }, {  4,  6 }}}, //  2
   {{{  0, -1 }, {  1, -1 }, {  6,  9 }, {  5, -1 }}}, //  3
   {{{  1, -1 }, {  2, -1 }, {  7, -1 }, {  6,  8 }}}, //  4
   {{{ -1, -1 }, {  3,  1 }, {  8, 11 }, { -1, -1 }}}, //  5
   {{{  3,  0 }, {  4,  2 }, {  9, 12 }, {  8, 10 }}}, //  6
   {{{  4,  1 }, { -1, -1 }, { -1, -1 }, {  9, 11 }}}, //  7
   {{{  5, -1 }, {  6,  4 }, { 11, -1 }, { 10, -1 }}}, //  8
   {{{  6,  3 }, {  7, -1 }, { 12, -1 }, { 11, -1 }}}, //  9
   {{{ -1, -1 }, {  8,  6 }, { -1, -1 }, { -1, -1 }}}, // 10
   {{{  8,  5 }, {  9,  7 }, { -1, -1 }, { -1, -1 }}}, // 11
   {{{  9,  6 }, { -1, -1 }, { -1, -1 }, { -1, -1 }}}  // 12
}};

// Returns true if the player index is in range.
inline bool is_valid_player(PlayerIndex idx) noexcept
{
   return (idx >= 0) && (idx < num_players);
}

// Returns the other player in the game. Useful for switching sides after a
// move.
inline PlayerIndex other_player(PlayerIndex idx) noexcept
{
   static_assert(num_players == 2);
   return idx ? 0 : 1;
}

// Returns true if the index is in range.
inline bool is_valid_index(int index) noexcept
{
   return (index >= 0) && (index < num_spaces_on_board);
}

#endif /* Board_h */
