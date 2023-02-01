 /* The basis of the following code was */
 /* sourced from the Shankar Ganesh's example titled */
 /* titled https://pages.cpsc.ucalgary.ca/~sankarasubramanian.g/411/files/flex-cpp.zip */
 /* some code sourced from: https://stackoverflow.com/questions/5418181/flex-lex-encoding-strings-with-escaped-characters */ 

%option c++
%option yyclass="JCC::CCLexer"
%option yylineno
%option noyywrap

/* Declarations */
%{
    // Declarations go here
    #include <iostream>
    #include <fstream>
    #include "scanner.hpp"
    #include <stdio.h>
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
\n          ;

">"         return T_GT;
"<"         return T_LT;
">="        return T_GE;
"<="        return T_LE;
"+"         return T_ADD;
"-"         return T_SUB;
"/"         return T_DIV;
"*"         return T_MULT;
"="         return T_ASS;
"%"         return T_MOD;
"("         return T_LBRAC;
")"         return T_RBRAC;
"{"         return T_LCURL;
"}"         return T_RCURL;
";"         return T_SEMI;
","         return T_COMM;
"!"         return T_FAC;
"!="        return T_NEQ;
"&&"        return T_AND;
"||"        return T_OR;
"if"        return T_IF;
"while"     return T_WHILE;
"else"      return T_ELSE;
"return"    return T_RET;
"break"     return T_BREAK;
"int"       return T_INT;
"boolean"   return T_BOOL;
"Void"      return T_VOID;

{ID}        return T_ID;
{num}       return T_NUM;

\"		{yymore(); BEGIN(STRING); }

<STRING>\"	{BEGIN(INITIAL); return T_STR;}
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

/* User routines here*/

/* int yyFlexLexer::yywrap() { return 1; } */

/* Creates and returns unique pointer to lexer */
std::unique_ptr<JCC::CCLexer> createLexer(std::istream* input) {
    return std::make_unique<JCC::CCLexer>(input);
}