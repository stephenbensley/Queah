//
// Copyright 2023 Stephen E. Bensley
//
// This file is licensed under the MIT License. You may obtain a copy of the
// license at https://github.com/stephenbensley/Queah/blob/main/LICENSE.
//

#include "PositionEvaluator.h"
#include "BinaryIo.h"
#include <algorithm>
#include <fstream>
#include <unordered_map>

// Possible move being evaluated for play.
struct Candidate {
   Move move;
   ValueType value;
   int repetitions;
};
using Candidates = std::vector<Candidate>;

// Sorts from most desirable to least desirable.
bool operator<(const Candidate& lhs, const Candidate& rhs) noexcept;

PositionEvaluator::PositionEvaluator() noexcept
{
   std::srand(static_cast<unsigned int>(std::time(nullptr)));
}

PositionEvaluator::PositionEvaluator(const PositionValues& data)
: PositionEvaluator()
{
   // Coalesce all the entries with the same BitBoard combination.
   std::unordered_map<uint32_t, Element> by_key;
   for (const auto& d : data) {
      const auto key = get_key(d.position);
      const auto idx1 = d.position.attacker().reserve_count();
      const auto idx2 = d.position.defender().reserve_count();
      auto& entry = by_key[key];
      entry.key = key;
      entry.value[idx1][idx2] = d.value;
   }
   
   // Copy the elements into a vector.
   elements_.reserve(by_key.size());
   for (const auto& i : by_key) {
      elements_.push_back(i.second);
   }
   
   // Sort the vector, so we can use binary search for lookups.
   std::sort(elements_.begin(),
             elements_.end(),
             [](const auto& lhs, const auto& rhs) {
      return lhs.key < rhs.key;
   });
}

Move PositionEvaluator::get_best_move(const GameModel& model) const noexcept
{
   const auto other = other_player(model.to_move());
   
   // Collect & evaluate all the candidate moves.
   Candidates candidates;
   for (auto m : model.position().moves()) {
      auto next_pos = model.position().try_move(m);
      candidates.push_back({
         m,
         evaluate(next_pos),
         model.repetitions(next_pos, other)
      });
   }
   assert(!candidates.empty());
   
   // Sort the candidates
   std::sort(candidates.begin(), candidates.end());
   
   // Count how many moves are tied for first.
   auto i = std::upper_bound(candidates.begin(),
                             candidates.end(),
                             candidates[0]);
   auto count = std::distance(candidates.begin(), i);
   assert(count > 0);
   
   // Select randomly from the equally desirable moves.
   return candidates[rand() % count].move;
}

bool PositionEvaluator::load(const char* datafile)
{
   std::ifstream istrm(datafile, std::ios::binary);
   if (!istrm.is_open()) {
      return false;
   }
   std::vector<Element> tmp;
   if (!read_pod_vector(istrm, tmp)) {
      return false;
   }
   if (!read_complete(istrm)) {
      return false;
   }
   elements_.swap(tmp);
   return true;
}

void PositionEvaluator::save(const char* datafile) const noexcept
{
   std::ofstream ostrm(datafile, std::ios::binary | std::ios::trunc);
   write_pod_vector(ostrm, elements_);
}

ValueType PositionEvaluator::evaluate(GamePosition position) const noexcept
{
   const auto key = get_key(position.canonical());
   const auto idx1 = position.attacker().reserve_count();
   const auto idx2 = position.defender().reserve_count();
   
   // Find the matching entry.
   auto i = std::lower_bound(elements_.begin(),
                             elements_.end(),
                             key,
                             [](const auto& lhs, auto key) {
      return lhs.key < key;
   });
   
   // All reachable game positions are in the table, so we should always have
   // an exact match.
   assert((i != elements_.end()) && (i->key == key));
   return i->value[idx1][idx2];
}

uint32_t PositionEvaluator::get_key(GamePosition position) noexcept
{
   uint32_t hi = position.attacker().bitboard();
   uint32_t lo = position.defender().bitboard();
   return (hi << 16u) | lo;
 }

// Sorts from most desirable to least desirable.
bool operator<(const Candidate& lhs, const Candidate& rhs) noexcept
{
   return (lhs.value < rhs.value) ||
          ((lhs.value == rhs.value) && (lhs.repetitions < rhs.repetitions));
}
