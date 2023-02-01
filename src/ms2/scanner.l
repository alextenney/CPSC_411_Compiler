%option c++
%option yyclass="JCC::Lexer"
%option noyywrap

/* Declarations */
%{
    #include <iostream>
    #include <fstream>
    #include "scanner.hpp"
    #include "parser.hh"
    
    // The token this time is in the parser class
    // If no namespace and class is used, then the default is yy::Parser::token
    using Token = JCC::Parser::token;

    // Should have this if you're using C++
    // Defines yylex with parameters. Flex will produce this function.
    // semantic_type is YYSTYPE, the union defined in bison. 
    #undef  YY_DECL
    #define YY_DECL int JCC::Lexer::yylex(JCC::Parser::semantic_type *yylval, JCC::Parser::location_type *loc)
%}

/* Definitions here */
alpha       [a-zA-Z_]
digit       [0-9]

num     {digit}{digit}*
ID      {alpha}({alpha}|{digit})*

/* Comment States */
/* comments need to superscede all other rules, so they are a state*/
%x COMMENT

/* since strings have a lot of rules, they need to be a state */
%x STRING

%%

 /* Rules here */
 /* ignore whitespace and newlines, because we dont want to tokenize them */
[ \t\r]+    ;          
\n          loc->lines(); loc->step();

">"         return Token::T_GT;
"<"         return Token::T_LT;
">="        return Token::T_GE;
"<="        return Token::T_LE;
"+"         return Token::T_ADD;
"-"         return Token::T_SUB;
"/"         return Token::T_DIV;
"*"         return Token::T_MULT;
"="         return Token::T_ASS;
"%"         return Token::T_MOD;
"("         return Token::T_LBRAC;
")"         return Token::T_RBRAC;
"{"         return Token::T_LCURL;
"}"         return Token::T_RCURL;
";"         return Token::T_SEMI;
","         return Token::T_COMM;
"!"         return Token::T_FAC;
"!="        return Token::T_NEQ;
"&&"        return Token::T_AND;
"||"        return Token::T_OR;
"if"        return Token::T_IF;
"while"     return Token::T_WHILE;
"else"      return Token::T_ELSE;
"return"    return Token::T_RET;
"break"     return Token::T_BREAK;
"int"       return Token::T_INT;
"boolean"   return Token::T_BOOL;
"void"      return Token::T_VOID;
"true"      return Token::T_TRUE;
"false"     return Token::T_FALSE;

{num}       {yylval->ival = std::stoi(yytext);  return Token::T_NUM;}
{ID}        {yylval->sval = strdup(yytext); return Token::T_ID;}

\"		{yymore(); BEGIN(STRING); }

<STRING>\"	{BEGIN(INITIAL); return Token::T_STR;}
<STRING>\n	{fprintf(stderr, "error: newline in string\n"); exit(1);}

<STRING>\\[\\"]    {yymore();}
<STRING>\\n         { yymore(); }
<STRING>\\t         { yymore(); }
<STRING>\\f         { yymore(); }
<STRING>\\r         { yymore(); }
<STRING>\\'         { yymore(); }
<STRING>\\         { yymore(); }
<STRING>\0          {yymore();}

<STRING>.	{yymore();}

<STRING><<EOF>> {fprintf(stderr, "error: eof in string\n"); exit(1);}
<STRING>\\. {fprintf(stderr, "error: illegal escape in string\n"); exit(1);}


"//"             BEGIN(COMMENT);
<COMMENT>.
<COMMENT>\n     {BEGIN(INITIAL); }

.               {fprintf(stderr, "warning: illegal character\n");}

%% 


std::unique_ptr<JCC::Lexer> createLexer(std::istream* input) 
{
    return std::make_unique<JCC::Lexer>(input);
}