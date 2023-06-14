//
// Copyright 2023 Stephen E. Bensley
//
// This file is licensed under the MIT License. You may obtain a copy of the
// license at https://github.com/stephenbensley/obatgonu/blob/main/LICENSE.
//

#ifndef ToString_h
#define ToString_h

#include <string>
#include "GamePosition.h"

std::string to_string(GamePosition pos, PlayerIndex to_move);

#endif /* ToString_h */
