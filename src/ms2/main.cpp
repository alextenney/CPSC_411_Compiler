/********************************
 * Example C++ Parser
 * Written for CPSC 411 Tutorial
 * File: scanner.cpp
 * Shankar Ganesh
 * *****************************/


#include <cstdlib>
#include <cerrno>
#include <cstring>
#include <iostream>
#include <fstream>

#include "scanner.hpp"
#include "parser.hh"

int main(int argc, char **argv) {
    extern int yydebug;

    std::ifstream file;
    
    if (argc == 2)
    {
        file.open(argv[1]);

        if (!file.good())
        {
            std::cerr << "Error: " << strerror(errno) << "\n";
            return EXIT_FAILURE;
        }
    }

    auto lexer = createLexer(&file);
    auto parser = std::make_unique<JCC::Parser>(lexer);
    parser->set_debug_level(0);
   
    if( parser->parse() != 0 )
    {
        std::cerr << "Parse failed!!\n";
        if (file.is_open()) file.close();
        return 1;
    }
    
    if (file.is_open()) file.close();

    return 0;
}