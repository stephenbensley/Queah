//
// Copyright 2023 Stephen E. Bensley
//
// This file is licensed under the MIT License. You may obtain a copy of the
// license at https://github.com/stephenbensley/Queah/blob/main/LICENSE.
//

#include "PlayerPosition.h"
#include <cassert>

PlayerPosition::PlayerPosition(BitBoard on_board, int in_reserve) noexcept
: value_(on_board | (in_reserve << num_spaces_on_board))
{ }

PlayerPosition::PlayerPosition(uint16_t id) noexcept
: value_(id)
{ }

uint16_t PlayerPosition::id() const noexcept
{
   return value_;
}

int PlayerPosition::board_count() const noexcept
{
   // From K&R exercise 2-9
   auto count = 0;
   for (auto v = bitboard(); v != 0; v &= (v-1)) {
      ++count;
   }
   return count;
}

int PlayerPosition::reserve_count() const noexcept
{
   return value_ >> num_spaces_on_board;
}

BitBoard PlayerPosition::bitboard() const noexcept
{
   return value_ & ((1u << num_spaces_on_board) - 1);
}

bool PlayerPosition::can_drop() const noexcept
{
   return (board_count() < max_pieces_on_board) && (reserve_count() > 0);
}

bool PlayerPosition::occupies(int space) const noexcept
{
   assert(is_valid_index(space));
   return (value_ & (1u << space)) != 0;
}

void PlayerPosition::move(int from, int to) noexcept
{
   if (from == invalid_index) {
      assert(reserve_count() > 0);
      value_ -= (1u << num_spaces_on_board);
   } else {
      remove(from);
   }
   place(to);
}

void PlayerPosition::remove(int from) noexcept
{
   assert(is_valid_index(from));
   assert(occupies(from));
   value_ &= ~(1u << from);
}

void PlayerPosition::mirror() noexcept
{
   transpose(mirror_table);
}

void PlayerPosition::rotate() noexcept
{
   transpose(rotate_table);
}

void PlayerPosition::place(int index) noexcept
{
   assert(is_valid_index(index));
   assert(!occupies(index));
   value_ |= (1u << index);
}

void PlayerPosition::transpose(const Transposition& table) noexcept
{
   PlayerPosition dst(0, reserve_count());
   for (auto i = 0; i < num_spaces_on_board; ++i) {
      if (occupies(i)) {
         dst.place(table[i]);
      }
   }
   *this = dst;
}
