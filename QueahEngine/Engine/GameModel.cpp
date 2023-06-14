//
// Copyright 2023 Stephen E. Bensley
//
// This file is licensed under the MIT License. You may obtain a copy of the
// license at https://github.com/stephenbensley/obatgonu/blob/main/LICENSE.
//

#include "GameModel.h"
#include "BinaryIo.h"
#include "ToString.h"
#include <sstream>

GameModel::GameModel() noexcept
{
   tracker_.visit(position_, to_move_);
}

PlayerIndex GameModel::to_move() const noexcept
{
   return to_move_;
}

GamePosition GameModel::position() const noexcept
{
   return position_;
}

int GameModel::num_moves() const noexcept
{
   return (num_half_moves_ + 1) / 2;
}

bool GameModel::is_terminal() const noexcept
{
   return position_.is_terminal();
}

int GameModel::repetitions() const noexcept
{
   return repetitions(position_, to_move_);
}
                     
int GameModel::repetitions(GamePosition position, PlayerIndex to_move) const noexcept
{
   return tracker_.repetitions(position, to_move);
}

std::string GameModel::to_string() const
{
   return ::to_string(position_, to_move_);
}

void GameModel::make_move(Move move)
{
   assert(position_.is_legal_move(move));
   position_.make_move(move);
   to_move_ = other_player(to_move_);
   tracker_.visit(position_, to_move_);
   ++num_half_moves_;
   
}

void GameModel::reset() noexcept
{
   to_move_ = 0;
   position_ = GamePosition::start;
   num_half_moves_ = 0;
   tracker_.reset();
   tracker_.visit(position_, to_move_);
}

bool GameModel::load(std::istringstream& istrm)
{
   GameModel tmp;
   if (!read_pod(istrm, tmp.to_move_)) {
      return false;
   }
   uint32_t id;
   if (!read_pod(istrm, id)) {
      return false;
   }
   tmp.position_ = GamePosition(id);
   if (!read_pod(istrm, num_half_moves_)) {
      return false;
   }
   if (!tracker_.load(istrm)) {
      return false;
   }
   if (!read_complete(istrm)) {
      return false;
   }
   std::swap(*this, tmp);
   return true;
}

void GameModel::save(std::ostringstream& ostrm) const
{
   write_pod(ostrm, to_move_);
   write_pod(ostrm, position_.id());
   write_pod(ostrm, num_half_moves_);
   tracker_.save(ostrm);
}
