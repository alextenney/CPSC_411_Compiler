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
        class Lexer;
    }

}

/* Add a parameter to parse function. */
%parse-param {std::unique_ptr<JCC::Lexer> &lexer}

/* Any other includes or C/C++ code can go in %code and 
    bison will place it somewhere optimal */
%code {
    #include <iostream>
    #include <fstream>
    #include <string>
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
    char* sval;
};

/* Tokens 
    The character representations can only be used inside bison
*/
%token ADD "+"
%token SUB "-"
%token DIV "/"
%token MULT "*"
%token ASS "="
%token MOD "%"
%token LBRAC "("
%token RBRAC ")"
%token GT ">"
%token LT "<"
%token GE "<="
%token LE ">+"
%token LCURL "{"
%token RCURL "}"
%token SEMI ";"
%token COMM ","
%token FAC "!"
%token NEQ "!="
%token AND "&&"
%token OR "||"
%token IF "if"
%token WHILE "while"
%token ELSE "else"
%token RET "return"
%token BREAK "break"
%token INT "int"
%token BOOL "boolean"
%token VOID "void"
%token <sval> ID "identifier"

/* NUM has an attribute and is of type ival (int in union) */
%token <ival> NUM "number"

/* Define the start symbol */
%start S

/* The symbols E and F are of type int and return an int */
%type <astval> E F

%%

S	: E		        {printTree($1, 0);}
	;

E	: ID ASS E      {std::string s ("="); $$ = binary(s, leaf($1, $1), $3);}
    | E ADD F		{std::string s ("+"); $$ = binary(s, $1, $3);}
	| E MULT F	    {std::string s ("*"); $$ = binary(s, $1, $3);}
	| E DIV F		{std::string s ("/"); $$ = binary(s, $1, $3);}
	| E MOD F		{std::string s ("%"); $$ = binary(s, $1, $3);}
	| E SUB F		{std::string s ("-"); $$ = binary(s, $1, $3);}
    | LBRAC E RBRAC     {$$ = $2;}
	| F				{$$ = $1;}
	;

F	: NUM			{std::string s = std::to_string($1); $$ = leaf(s, s);}

%%

/* Parser will call this function when it fails to parse */
/* Tip: You can store the current token in the lexer to output meaningful error messages */
void JCC::Parser::error(const location_type &loc, const std::string &errmsg)
{
   std::cerr << "Error: " << errmsg << " at " << loc << "\n";
}
