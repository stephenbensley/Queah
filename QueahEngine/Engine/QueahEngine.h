//
// Copyright 2023 Stephen E. Bensley
//
// This file is licensed under the MIT License. You may obtain a copy of the
// license at https://github.com/stephenbensley/Goosey/blob/main/LICENSE.
//

#ifndef QueahEngine_h
#define QueahEngine_h

#ifdef __cplusplus
extern "C" {
#endif

// Spaces on the board are indexed as follows:
// 12   11   10
//    9    8
//  7    6    5
//    4    3
//  2    1    0
#define QUEAH_NUM_SPACES_ON_BOARD    13
#define QUEAH_MAX_PIECES_ON_BOARD     4
#define QUEAH_MAX_PIECES_IN_RESERVE   6

// Special index used to indicate any of the following:
// 1) Move is from the reserve, not the board.
// 2) No capture occurred.
#define QUEAH_INVALID_INDEX -1

// White player moves first.
#define QUEAH_PLAYER_WHITE   0
#define QUEAH_PLAYER_BLACK   1

// Stores a move. If 'from' is QUEAH_INVALID_INDEX, this is a drop.
struct QueahMove_ {
   int from;
   int to;
};
typedef struct QueahMove_ QueahMove;

// Create/destory a Queah game.
typedef void QueahGame;
QueahGame* queah_game_create(void);
void queah_game_destroy(QueahGame* game);

// Returnes the indices of the player's pieces on the board.
void queah_game_get_pieces(const QueahGame* game, int player, int* buf, int* buflen);
// Returns the number of pieces still in reserve
int queah_game_reserve_count(const QueahGame* game, int player);
// Returns the player whose turn it is.
int queah_game_player_to_move(const QueahGame* game);

// Returns '1' if the game is over; '0' otherwise.
int queah_game_is_over(const QueahGame* game);
// Returns the number of times the current game position has occurred.
int queah_game_repetitions(const QueahGame* game);
// Returns the number of moves completed so far.
int queah_game_moves_completed(const QueahGame* game);

// Gets all legal moves for the current game state.
void queah_game_get_moves(const QueahGame* game, QueahMove* buf, int* buflen);
// Make the move. Returns the index of any captured piece or QUEAH_INVALID_INDEX
// if no piece was captured. Returns 0 on success or -1 otherwise.
int queah_game_make_move(QueahGame* game, QueahMove move, int* captured);

// Resets the game to its initial state and begins a new game.
void queah_game_reset(QueahGame* game);

// Gets a string representation of the current game state.
void queah_game_to_string(const QueahGame* game, char* buf, int buflen);
// Encodes the game state to a buffer.
int queah_game_encode(const QueahGame* game, char* buf, int* buflen);
// Decodes the game state from a buffer.
int queah_game_decode(QueahGame* game, char* buf, int buflen);

// Create/destroy an AI that plays a perfect game of Queah
typedef void QueahAI;
QueahAI* queah_ai_create(const char* datafile);
void queah_ai_destroy(QueahAI* ai);

// Gets the best move for the current state.
void queah_ai_get_move(const QueahAI* ai, const QueahGame* game, QueahMove* move);

#ifdef __cplusplus
}
#endif
#endif /* QueahEngine_h */
