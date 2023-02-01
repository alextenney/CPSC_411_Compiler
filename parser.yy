/* Simple C++ Parser Example */

/* Need to have this line, if generating a c++ parser */
%skeleton "lalr1.cc"
%require "3.7"

// Generate header files
%defines

// Namespace where the parser class is. Default: yy
%define api.namespace {JCC} 

// Name of the parser class. Default: parser
%define api.parser.class {Parser} 

// Enable location tracking
%locations 

/* Any type that is used in union should be included or decalred here 
    (in the requires qualifier) 
*/
%code requires{
    // Used for parse-param
    #include <memory>
    #include "ast.h"

    // Forward Declaration.
    // Compiler outputs error otherwise
    namespace JCC {
        class CCLexer;
    }

}

/* Add a parameter to parse function. */
%parse-param {std::unique_ptr<JCC::CCLexer> &lexer}

/* Any other includes or C/C++ code can go in %code and 
    bison will place it somewhere optimal */
%code {
    #include <iostream>
    #include <fstream>
    #include "scanner.hpp"
    #include "ast.h"
    
    // Undefine the normal yylex.
    // Bison will search for a yylex function in the global namespace
    // But one doesn't exist! It's in the lexer class. 
    // So define yylex.
    #undef yylex
    #define yylex lexer->yylex
}

/* Prefix all tokens with T_ */
%define api.token.prefix {T_}

/* Semantic type (YYSTYPE) */
%union{
    int ival;
    AST* astval;
};

/* Tokens 
    The character representations can only be used inside bison
*/
%token ADD "+"
%token SUB "-"
%token DIV "/"
%token MULT "*"
%token MOD "%"
%token OPAREN "("
%token CPAREN ")"

/* NUM has an attribute and is of type ival (int in union) */
%token <ival> NUM "number"

/* Define the start symbol */
%start S

/* The symbols E and F are of type int and return an int */
%type <astval> E F

%%

S	: E		        {printTree($1, 0);}
	;

E	: E "+" F		{$$ = binary(0, $1, $3);}
	| E MULT F	    {$$ = binary(1, $1, $3);}
	| E DIV F		{$$ = binary(2, $1, $3);}
	| E MOD F		{$$ = binary(3, $1, $3);}
	| E SUB F		{$$ = binary(4, $1, $3);}
    | "(" E ")"     {$$ = $2;}
	| F				{$$ = $1;}
	;

F	: NUM			{$$ = leaf($1, $1);}


%%

/* Parser will call this function when it fails to parse */
/* Tip: You can store the current token in the lexer to output meaningful error messages */
void JCC::Parser::error(const location_type &loc, const std::string &errmsg)
{
   std::cerr << "Error: " << errmsg << " at " << loc << "\n";
}

