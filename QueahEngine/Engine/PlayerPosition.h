//
// Copyright 2023 Stephen E. Bensley
//
// This file is licensed under the MIT License. You may obtain a copy of the
// license at https://github.com/stephenbensley/obatgonu/blob/main/LICENSE.
//

#ifndef PlayerPosition_h
#define PlayerPosition_h

#include "Board.h"

// Represents one player's position in the game.
class PlayerPosition
{
public:
   PlayerPosition(BitBoard on_board, int in_reserve) noexcept;
   explicit PlayerPosition(uint16_t id) noexcept;

   // Returns an integer uniquely identifying this player position.
   uint16_t id() const noexcept;
   // Returns the number of pieces on the board.
   int board_count() const noexcept;
   // Returns the number of pieces in reserve.
   int reserve_count() const noexcept;
   // Returns a BitBoard representing the locations of the player's pieces.
   BitBoard bitboard() const noexcept;

   // Returns true if the player can drop a piece on the board.
   bool can_drop() const noexcept;
   // Returns true if the player has a piece occupying the specified space.
   bool occupies(int space) const noexcept;

   // Moves one of the player's pieces. If from == reserve_index, drops a
   // piece from the reserve.
   void move(int from, int to) noexcept;
   // Removes one of the player's pieces.
   void remove(int from) noexcept;
   
   // Reflects the player's pieces horizontally.
   void mirror() noexcept;
   // Rotates the player's pieces clockwise.
   void rotate() noexcept;
   
private:
   // Places a piece on the specified space.
   void place(int index) noexcept;
   // Transposes the player's pieces according to the table.
   void transpose(const Transposition& table) noexcept;

   // Lower 13 bits contain the BitBoard; upper 3 bits contain the reserve
   // count.
   uint16_t value_;
};

#endif /* PlayerPosition_h */
