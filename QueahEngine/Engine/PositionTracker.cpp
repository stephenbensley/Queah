//
// Copyright 2023 Stephen E. Bensley
//
// This file is licensed under the MIT License. You may obtain a copy of the
// license at https://github.com/stephenbensley/Queah/blob/main/LICENSE.
//

#include "PositionTracker.h"
#include "BinaryIo.h"
#include <sstream>

int PositionTracker::repetitions(GamePosition position,
                                 PlayerIndex to_move) const noexcept
{
   auto i = counts_.find(get_key(position, to_move));
   if (i == counts_.end()) {
      return 0;
   }
   return i->second;
}

void PositionTracker::visit(GamePosition position, PlayerIndex to_move)
{
   counts_[get_key(position, to_move)] += 1;
}

void PositionTracker::reset() noexcept
{
   counts_.clear();
}

void PositionTracker::encode(std::ostringstream& ostrm) const
{
   write_pod_map(ostrm, counts_);
}

bool PositionTracker::decode(std::istringstream& istrm)
{
   return read_pod_map(istrm, counts_);
}

uint64_t PositionTracker::get_key(GamePosition position,
                                  PlayerIndex to_move) noexcept
{
   uint64_t key = position.id();
   if (to_move != 0) {
      key |= 0x100000000ull;
   }
   return key;
}
