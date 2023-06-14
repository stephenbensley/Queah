//
// Copyright 2023 Stephen E. Bensley
//
// This file is licensed under the MIT License. You may obtain a copy of the
// license at https://github.com/stephenbensley/obatgonu/blob/main/LICENSE.
//

#include "Solve.h"
#include <algorithm>
#include <iostream>

int main(int argc, const char * argv[])
{
   const char datafile[] = "queah.solution";
   
   std::cout << "Building nodes ..." << std::endl;
   auto nodes = build_nodes();
   std::cout << "Built " << nodes.size() << " nodes." << std::endl;
   
   std::cout << "Computing values ..." << std::endl;
   compute_values(nodes);
   auto count = std::count_if(nodes.begin(),
                              nodes.end(),
                              [](const auto& node) {
      return node->value() != 0;
   });
   std::cout << "Computed " << count << " nodes." << std::endl;

   std::cout << "Converting nodes ..." << std::endl;
   auto pos_vals = to_position_values(nodes);
   nodes.clear();
   std::cout << "Converted " << pos_vals.size() << " nodes." << std::endl;
   
   std::cout << "Saving results ..." << std::endl;
   PositionEvaluator eval(pos_vals);
   pos_vals.clear();
   eval.save(datafile);
   std::cout << "Done." << std::endl;
   
   if (!eval.load(datafile)) {
      std::cout << "Verification failed." << std::endl;
   }
   
   return 0;
}
