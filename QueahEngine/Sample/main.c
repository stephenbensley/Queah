//
// Copyright 2023 Stephen E. Bensley
//
// This file is licensed under the MIT License. You may obtain a copy of the
// license at https://github.com/stephenbensley/Queah/blob/main/LICENSE.
//

#include "QueahEngine.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

const char* get_outcome(const QueahGame* game)
{
   if (queah_game_repetitions(game) >= 3) {
      return "Draw";
   }
   if (queah_game_is_over(game)) {
      return queah_game_player_to_move(game) ? "White wins" : "Black wins";
   }
   return NULL;
}

int main(int argc, const char * argv[])
{
   int result = EXIT_SUCCESS;
   QueahGame* game = NULL;
   QueahAI* ai = NULL;
   char buf[256];
   int buflen = sizeof(buf);
   QueahMove move;
   const char* outcome;
   int num_moves;
   
   game = queah_game_create();
   if (game == NULL) {
      printf("Failed to create game object.");
      result = EXIT_FAILURE;
      goto cleanup;
   }

   ai = queah_ai_create("queah.dat");
   if (ai == NULL) {
      printf("Failed to create AI object.");
      result = EXIT_FAILURE;
      goto cleanup;
   }

   queah_game_to_string(game, buf, buflen);
   puts(buf);
   
   do {
      queah_ai_get_move(ai, game, &move);
      queah_game_make_move(game, move, NULL);
      queah_game_to_string(game, buf, buflen);
      puts(buf);
      outcome = get_outcome(game);
   } while (!outcome);
   
   num_moves = queah_game_moves_completed(game);
   printf("%s in %d moves.\n", outcome, num_moves);

cleanup:
   queah_ai_destroy(ai);
   queah_game_destroy(game);
   return result;
}
