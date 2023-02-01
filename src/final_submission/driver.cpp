/* Driver.cpp */


#include <fstream>
#include <memory>

#include "driver.hpp"
#include "checker.hpp"
#include "code-gen.hpp"


Driver::~Driver() 
{
    // Resets the unique pointers.n
    // Equivalent to destruction
    lexer.reset();
    parser.reset();
}

bool Driver::start(std::istream &in) 
{
    // If the stream is bad or if the stream is at EOF
    // Return 1
    if (!in.good() && in.eof()) {
        return 1;
    }
    bool res = parse(in);
    if (!res){
        //this is where you call semantic checker

        // print tree
        // printTree(tree, 0);
        // postorder(tree, pass1);
        doPasses(tree);
        // printSig(tree, 0);
        // print_map();
        traverse(tree);
    }

    return res;
}

// Calls yylex and returns the token.
// Called by the parser for every token
// Prints out the token if needed. Can be a flag or a global debug var.
int Driver::getToken(JCC::Parser::semantic_type *yylval, JCC::Parser::location_type *location)
{
    int tok = lexer->yylex(yylval, location);
    std::cout << "Token: " << (JCC::Parser::token::token_kind_type)tok << "\n";
    return tok;
}


bool Driver::parse(std::istream &in) 
{
    lexer = createLexer(&in);

    // Pass this driver as an argument.
    parser = std::make_unique<JCC::Parser>(lexer, *this);
   
    if( parser->parse() != 0 )
    {
        std::cerr << "Parse failed!!\n";
        return 1;
    }

    return 0;
}