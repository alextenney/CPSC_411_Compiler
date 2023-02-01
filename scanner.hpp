/* The basis of the following code was */
 /* sourced from the Shankar Ganesh's example titled */
 /* titled https://pages.cpsc.ucalgary.ca/~sankarasubramanian.g/411/files/flex-cpp.zip */
 
#ifndef SCANNER_HPP
#define SCANNER_HPP

#include <iostream>
#include <fstream>
#include <memory>

#if ! defined(yyFlexLexerOnce)
#include <FlexLexer.h>
#endif

#include "parser.hh"
#include "location.hh"

// Token enum
enum {
    T_ID = 1,
    T_NUM,
    T_ADD,
    T_SUB,
    T_DIV,
    T_MULT,
    T_LT,
    T_GT,
    T_GE,
    T_LE,
    T_ASS,
    T_MOD,
    T_LBRAC,
    T_RBRAC,
    T_LCURL,
    T_RCURL,
    T_SEMI,
    T_COMM,
    T_FAC,
    T_NEQ,
    T_AND,
    T_OR,
    T_STR,
    T_INT,
    T_BOOL,
    T_IF,
    T_ELSE,
    T_WHILE,
    T_RET,
    T_BREAK,
    T_VOID
};

// Lexer class. Inherits yyFlexLexer
namespace JCC{
    class CCLexer : public yyFlexLexer {
        public:

        // Can also shoose to specify ostream, but not necessary
        CCLexer(std::istream *in) : yyFlexLexer(in) { yylineno = 1; }
        
        virtual ~CCLexer() = default;

        // Flex will produce this function.
        // BUT YOU MUST HAVE THE PROTOTYPE IN THE CLASS
        virtual int yylex(JCC::Parser::semantic_type *yylval, JCC::Parser::location_type *location);

    };
}
// Prototype. Defined in scanner.l
std::unique_ptr<JCC::CCLexer> createLexer(std::istream* input);


inline char const* getName(int tok){
	switch (tok)
    {

    case T_ID:
        return "ID";

    case T_NUM:
        return "NUM";

    case T_ADD:
        return "+";

    case T_SUB:
        return "-";

    case T_DIV:
        return "/";

    case T_MULT:
        return "*";

    case T_LT:
        return "<";

    case T_GT:
        return ">";

    case T_LE:
        return "<=";
    
    case T_GE:
        return ">=";

    case T_ASS:
        return "=";

    case T_MOD:
        return "%"; 

    case T_LBRAC:
        return "(";

    case T_RBRAC:
        return ")";

    case T_LCURL:
        return "{";
    
    case T_RCURL:
        return "}";

    case T_SEMI:
        return ";";

    case T_COMM:
        return ",";

    case T_FAC:
        return "!";

    case T_NEQ:
        return "!=";

    case T_AND:
        return "&&";

    case T_OR:
        return "||";

    case T_STR:
        return "STR";

    case T_INT:
        return "INT";

    case T_BOOL:
        return "BOOL";

    case T_IF:
        return "IF";

    case T_ELSE:
        return "IF-ELSE";

    
    case T_WHILE:
        return "WHILE";

    case T_RET:
        return "RETURN";
    
    case T_BREAK:
        return "BREAK";

    case T_VOID:
        return "VOID";

    default:
        return "";
    }
}

#endif
