//
// Copyright 2023 Stephen E. Bensley
//
// This file is licensed under the MIT License. You may obtain a copy of the
// license at https://github.com/stephenbensley/Queah/blob/main/LICENSE.
//

#include "GameModel.h"
#include "BinaryIo.h"
#include "ToString.h"
#include <sstream>

GameModel::GameModel() noexcept
{
   // Mark the starting position as having been visited.
   tracker_.visit(position_, to_move_);
}

GamePosition GameModel::position() const noexcept
{
   return position_;
}

PlayerIndex GameModel::to_move() const noexcept
{
   return to_move_;
}

bool GameModel::is_over() const noexcept
{
   return position_.is_over();
}

int GameModel::repetitions() const noexcept
{
   return repetitions(position_, to_move_);
}
                     
int GameModel::repetitions(GamePosition position, PlayerIndex to_move) const noexcept
{
   return tracker_.repetitions(position, to_move);
}

int GameModel::moves_completed() const noexcept
{
   return (num_half_moves_ + 1) / 2;
}

void GameModel::make_move(Move move)
{
   position_.make_move(move);
   to_move_ = other_player(to_move_);
   tracker_.visit(position_, to_move_);
   ++num_half_moves_;
   
}

void GameModel::reset() noexcept
{
   position_ = GamePosition::start;
   to_move_ = 0;
   tracker_.reset();
   num_half_moves_ = 0;
   
   tracker_.visit(position_, to_move_);
}

std::string GameModel::to_string() const
{
   return ::to_string(position_, to_move_);
}

void GameModel::encode(std::ostringstream& ostrm) const
{
   write_pod(ostrm, position_.id());
   write_pod(ostrm, to_move_);
   tracker_.encode(ostrm);
   write_pod(ostrm, num_half_moves_);
}

bool GameModel::decode(std::istringstream& istrm)
{
   GameModel tmp;
   uint32_t id;
   if (!read_pod(istrm, id)) {
      return false;
   }
   tmp.position_ = GamePosition(id);
   if (!read_pod(istrm, tmp.to_move_)) {
      return false;
   }
   if (!tmp.tracker_.decode(istrm)) {
      return false;
   }
   if (!read_pod(istrm, tmp.num_half_moves_)) {
      return false;
   }
   if (!read_complete(istrm)) {
      return false;
   }
   std::swap(*this, tmp);
   return true;
}
