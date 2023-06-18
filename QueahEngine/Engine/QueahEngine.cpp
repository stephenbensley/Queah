//
// Copyright 2023 Stephen E. Bensley
//
// This file is licensed under the MIT License. You may obtain a copy of the
// license at https://github.com/stephenbensley/Queah/blob/main/LICENSE.
//

#include "QueahEngine.h"
#include "PositionEvaluator.h"
#include <sstream>

static_assert(QUEAH_NUM_SPACES_ON_BOARD == num_spaces_on_board);
static_assert(QUEAH_MAX_PIECES_ON_BOARD == max_pieces_on_board);
static_assert(QUEAH_MAX_PIECES_IN_RESERVE == max_pieces_in_reserve);
static_assert(QUEAH_INVALID_INDEX == invalid_index);

QueahGame* queah_game_create(void)
{
   try {
      return new GameModel();
   }
   catch (...)
   {
      return nullptr;
   }
}

void queah_game_destroy(QueahGame* game)
{
   delete static_cast<GameModel*>(game);
}

void queah_game_get_pieces(const QueahGame* game, int player, int* buf, int* buflen)
{
   if ((game == nullptr) ||
       !is_valid_player(player) ||
       (buf == nullptr) ||
       (buflen == nullptr) ||
       (*buflen <= 0)) {
      return;
   }
   auto model = static_cast<const GameModel*>(game);
   
   auto [white, black] = model->position().by_player(model->to_move());
   auto pos = player ? black : white;
   
   auto capacity = *buflen;
   int count = 0;
   for (auto i = 0; i < num_spaces_on_board; ++i) {
      if (pos.occupies(i)) {
         buf[count] = i;
         if (++count == capacity) {
            break;
         }
      }
   }
   *buflen = count;
}

int queah_game_reserve_count(const QueahGame* game, int player)
{
   if ((game == nullptr) || !is_valid_player(player)) {
      return -1;
   }
   auto model = static_cast<const GameModel*>(game);
   
   auto [white, black] = model->position().by_player(model->to_move());
   auto pos = player ? black : white;
   return pos.reserve_count();
}

int queah_game_player_to_move(const QueahGame* game)
{
   if (game == nullptr) {
      return -1;
   }
   auto model = static_cast<const GameModel*>(game);
   return static_cast<int>(model->to_move());
}

int queah_game_is_over(const QueahGame* game)
{
   if (game == nullptr) {
      return -1;
   }
   auto model = static_cast<const GameModel*>(game);
   return model->is_over() ? 1 : 0;
}

int queah_game_repetitions(const QueahGame* game)
{
   if (game == nullptr) {
      return -1;
   }
   auto model = static_cast<const GameModel*>(game);
   return model->repetitions();
}

int queah_game_moves_completed(const QueahGame* game)
{
   if (game == nullptr) {
      return -1;
   }
   auto model = static_cast<const GameModel*>(game);
   return model->moves_completed();
}

void queah_game_get_moves(const QueahGame* game, QueahMove* buf, int* buflen)
{
   if ((game == nullptr) ||
       (buf == nullptr) ||
       (buflen == nullptr) ||
       (*buflen <= 0)) {
      return;
   }
   auto model = static_cast<const GameModel*>(game);
   
   auto capacity = *buflen;
   int count = 0;
   for (auto move : model->position().moves()) {
      buf[count].from = move.from;
      buf[count].to = move.to;
      if (++count == capacity) {
         break;
      }
   }
   *buflen = count;
}

int queah_game_make_move(QueahGame* game, QueahMove move, int* captured)
{
   if (game == nullptr) {
      return -1;
   }
   GameModel* model = static_cast<GameModel*>(game);
   
   Move match = { invalid_index, invalid_index, invalid_index };
   for (auto m : model->position().moves()) {
      if ((m.from == move.from) && (m.to == move.to)) {
         match = m;
         break;
      }
   }
   if (match.to == invalid_index) {
      return -1;
   }
   
   try {
      model->make_move(match);
      if (captured != nullptr) {
         *captured = match.capturing;
      }
   }
   catch (...)
   {
      return -1;
   }
   return 0;
}

void queah_game_reset(QueahGame* game)
{
   if (game == nullptr) {
      return;
   }
   GameModel* model = static_cast<GameModel*>(game);
   model->reset();
}

void queah_game_to_string(const QueahGame* game, char* buf, int buflen)
{
   if ((game == nullptr) || (buf == nullptr) || (buflen <= 0)) {
      return;
   }
   auto model = static_cast<const GameModel*>(game);
   auto sz = model->to_string();
   auto len = sz.copy(buf, buflen - 1);
   buf[len] = '\0';
}

int queah_game_encode(const QueahGame* game, char* buf, int* buflen)
{
   if ((game == nullptr) ||
       (buf == nullptr) ||
       (buflen == nullptr) ||
       (*buflen <= 0)) {
      return -1;
   }
   auto model = static_cast<const GameModel*>(game);
   
   try
   {
      std::ostringstream ostrm;
      model->encode(ostrm);
      auto len = ostrm.str().copy(buf, *buflen);
      *buflen = static_cast<int>(len);
   }
   catch (...)
   {
      return -1;
   }
   return 0;
}

int queah_game_decode(QueahGame* game, const char* buf, int buflen)
{
   if ((game == nullptr) || (buf == nullptr) | (buflen <= 0)) {
      return -1;
   }
   auto model = static_cast<GameModel*>(game);
  
   try
   {
      std::string sz(buf, buflen);
      std::istringstream istrm(sz);
      if (!model->decode(istrm)) {
         return -1;
      }
   }
   catch (...)
   {
      return -1;
   }
   return 0;
}

QueahAI* queah_ai_create(const char* datafile)
{
   if (datafile == nullptr) {
      return nullptr;
   }
   try {
      auto ptr = std::make_unique<PositionEvaluator>();
      if (!ptr->load(datafile)) {
         return nullptr;
      }
      return ptr.release();
   }
   catch (...)
   {
      return nullptr;
   }
}

void queah_ai_destroy(QueahAI* ai)
{
   delete static_cast<PositionEvaluator*>(ai);
}

void queah_ai_get_move(const QueahAI* ai,
                       const QueahGame* game,
                       QueahMove* move)
{
   if ((ai == nullptr) || (game == nullptr) || (move == nullptr)) {
      return;
   }
   auto eval = static_cast<const PositionEvaluator*>(ai);
   auto model = static_cast<const GameModel*>(game);
   
   auto m = eval->get_best_move(*model);
   move->from = m.from;
   move->to = m.to;
}
