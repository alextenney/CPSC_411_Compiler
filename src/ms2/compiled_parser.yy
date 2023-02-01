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
%token <astval> ADD "+"
%token <astval> SUB "-"
%token <astval> DIV "/"
%token <astval> MULT "*"
%token <astval> ASS "="
%token <astval> MOD "%"
%token <astval> LBRAC "("
%token <astval> RBRAC ")"
%token <astval> GT ">"
%token <astval> LT "<"
%token <astval> GE "<="
%token <astval> LE ">+"
%token <astval> LCURL "{"
%token <astval> RCURL "}"
%token <astval> SEMI ";"
%token <astval> COMM ","
%token <astval> FAC "!"
%token <astval> NEQ "!="
%token <astval> AND "&&"
%token <astval> OR "||"
%token <astval> IF "if"
%token <astval> WHILE "while"
%token <astval> ELSE "else"
%token <astval> RET "return"
%token <astval> BREAK "break"
%token <astval> INT "int"
%token <astval> BOOL "boolean"
%token <astval> VOID "void"
%token <astval> TRUE "true"
%token <astval> FALSE "false"
%token <astval> STR "string"
%token <astval> ID "identifier"

/* NUM has an attribute and is of type ival (int in union) */
%token <ival> NUM "number"

/* Define the start symbol */
%start start

/* The symbols E and F are of type int and return an int */
%type <astval> literal type globaldeclarations globaldeclaration variabledeclaration identifier functiondeclaration functionheader functiondeclarator formalparameterlist mainfunctiondeclaration mainfunctiondeclarator block blockstatements blockstatement statement statementexpression primary argumentlist functioninvocation postfixexpression unaryexpression multiplicativeexpression additiveexpression relationalexpression equalityexpression conditionalandexpression conditionalorexpression assignmentexpression assignment expression

%%

start           : /* empty */           {}
                | globaldeclarations    {}
                ;

literal         : NUM       {}
                | STR       {}
                | TRUE      {}
                | FALSE     {}
                ;

type            : BOOL      {}    
                | INT       {}
                ;

globaldeclarations      : globaldeclaration
                        | globaldeclarations globaldeclaration
                        ;

globaldeclaration       : variabledeclaration
                        | functiondeclaration
                        | mainfunctiondeclaration
                        ;

variabledeclaration     : type identifier SEMI
                        ;

identifier              : ID    {}
                        ;

functiondeclaration     : functionheader block
                        ;

functionheader          : type functiondeclarator
                        | VOID functiondeclarator
                        ;

functiondeclarator      : identifier LBRAC formalparameterlist RBRAC
                        | identifier LBRAC RBRAC
                        ;

formalparameterlist     : formalparameter
                        | formalparameterlist COMM formalparameter
                        ;

formalparameter         : type identifier
                        ;

mainfunctiondeclaration : mainfunctiondeclarator block
                        ;

mainfunctiondeclarator  : identifier LBRAC RBRAC
                        ;

block                   : LCURL blockstatements RCURL
                        | LCURL RCURL
                        ;

blockstatements         : blockstatement
                        | blockstatements blockstatement
                        ;

blockstatement          : variabledeclaration
                        | statement
                        ;

statement               : block
                        | SEMI
                        | statementexpression SEMI
                        | BREAK SEMI
                        | RET expression SEMI
                        | RET SEMI
                        | IF LBRAC expression RBRAC statement
                        | IF LBRAC expression RBRAC statement ELSE statement
                        | WHILE LBRAC expression RBRAC statement
                        ;

statementexpression     : assignment
                        | functioninvocation
                        ;

primary                 : literal
                        | LBRAC expression RBRAC
                        | functioninvocation
                        ;

argumentlist            : expression
                        | argumentlist COMM expression
                        ;

functioninvocation      : identifier LBRAC argumentlist RBRAC
                        | identifier LBRAC RBRAC
                        ;

postfixexpression       : primary
                        | identifier
                        ;

unaryexpression         : '-' unaryexpression {}
                        | FAC unaryexpression  {}
                        | postfixexpression
                        ;

multiplicativeexpression: unaryexpression
                        | multiplicativeexpression MULT unaryexpression     {}
                        | multiplicativeexpression DIV unaryexpression
                        | multiplicativeexpression MOD unaryexpression
                        ;

additiveexpression      : multiplicativeexpression
                        | additiveexpression ADD multiplicativeexpression
                        | additiveexpression '-' multiplicativeexpression
                        ;

relationalexpression    : additiveexpression
                        | relationalexpression LT additiveexpression
                        | relationalexpression GT additiveexpression
                        | relationalexpression LE additiveexpression
                        | relationalexpression GE additiveexpression
                        ;

equalityexpression      : relationalexpression
                        | equalityexpression ASS relationalexpression
                        | equalityexpression NEQ relationalexpression
                        ;

conditionalandexpression: equalityexpression
                        | conditionalandexpression AND equalityexpression
                        ;

conditionalorexpression : conditionalandexpression
                        | conditionalorexpression OR conditionalandexpression
                        ;

assignmentexpression    : conditionalorexpression
                        | assignment
                        ;

assignment              : identifier ASS assignmentexpression
                        ;

expression              : assignmentexpression
                        ;

%%

/* Parser will call this function when it fails to parse */
/* Tip: You can store the current token in the lexer to output meaningful error messages */
void JCC::Parser::error(const location_type &loc, const std::string &errmsg)
{
   std::cerr << "Error: " << errmsg << " at " << loc << "\n";
}
