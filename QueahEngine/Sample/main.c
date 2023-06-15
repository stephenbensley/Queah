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

int main(int argc, const char * argv[])
{
   int result = EXIT_SUCCESS;
   QueahGame* game = NULL;
   QueahAI* ai = NULL;
   char buf[1024];
   int buflen = sizeof(buf);
   QueahMove move;
   int num_moves;
   const char* winner;
   
   game = queah_game_create();
   if (game == NULL) {
      printf("Failed to create game object.");
      result = EXIT_FAILURE;
      goto cleanup;
   }
   
   memset(buf, 0, sizeof(buf));
   result = queah_game_encode(game, buf, &buflen);
   result = queah_game_decode(game, buf, buflen);
   buflen = sizeof(buf);
   
   ai = queah_ai_create("queah.dat");
   if (ai == NULL) {
      printf("Failed to create AI object.");
      result = EXIT_FAILURE;
      goto cleanup;
   }

   queah_game_to_string(game, buf, buflen);
   puts(buf);
   
   while (!queah_game_is_over(game)) {
      queah_ai_get_move(ai, game, &move);
      queah_game_make_move(game, move, NULL);
      queah_game_to_string(game, buf, buflen);
      puts(buf);
   }
   
   winner = queah_game_player_to_move(game) ? "White" : "Black";
   num_moves = queah_game_moves_completed(game);
   printf("%s wins in %d moves.\n", winner, num_moves);

cleanup:
   queah_ai_destroy(ai);
   queah_game_destroy(game);
   return result;
}
