/* Simple C++ Parser Example */

%debug

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
    ASTGroup* astgroupval;
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
%token <sval> SEMI ";"
%token <astval> COMM ","
%token <astval> FAC "!"
%token <astval> NEQ "!="
%token <astval> AND "&&"
%token <astval> OR "||"
%token <astval> IF "if"
%token <astval> WHILE "while"
%token <astval> ELSE "else"
%token <sval> RET "return"
%token <astval> BREAK "break"
%token <ival> INT "int"
%token <sval> BOOL "boolean"
%token <sval> VOID "void"
%token <sval> TRUE "true"
%token <sval> FALSE "false"
%token <astval> STR "string"
%token <sval> ID "identifier"

/* NUM has an attribute and is of type ival (int in union) */
%token <ival> NUM "number"

/* Define the start symbol */
%start start

%type <astgroupval> functionheader functiondeclarator mainfunctiondeclarator blockstatements

/* The symbols E and F are of type int and return an int */
%type <astval> literal type globaldeclarations globaldeclaration variabledeclaration identifier functiondeclaration mainfunctiondeclaration block blockstatement statement statementexpression primary argumentlist functioninvocation postfixexpression unaryexpression multiplicativeexpression additiveexpression relationalexpression equalityexpression conditionalandexpression conditionalorexpression assignmentexpression assignment expression formalparameterlist formalparameter

%%

start           : %empty                {AST* a = new_ast("program");
                                        a->add_data("type","program");
                                        vector<AST*> v = {};
                                        a = add_children(a, v);
                                        printTree(a, 0);}
                | globaldeclarations    { AST* a = new_ast("program");
                                        a->add_data("type","program");
                                        vector<AST*> v = {$1};
                                        a = add_children(a, v);
                                        printTree(a, 0);}
                ;

literal         : NUM       {std::string s = std::to_string($1); 
                            AST* a = new_ast("number");
                            a->add_data("lineno", @1.begin.line);
                            a->add_data("type","number");
                            a->add_data("attr",s);
                            $$ =a;}
                | STR       {$$ = $1;}
                | TRUE      {AST* a = new_ast("true");
                            a->add_data("type","true");
                            a->add_data("attr","None");
                            $$ =a;
                            }
                | FALSE     {AST* a = new_ast("false");
                            a->add_data("type","false");
                            a->add_data("attr","None");
                            $$ =a;}
                ;

type            : BOOL      {
                                AST* a = new_ast("bool");
                                a->add_data("lineno", @1.begin.line);
                                a->add_data("attr","None");
                                a->add_data("type","bool");
                                $$ = a;
                            }    
                | INT       {
                                AST* a = new_ast("int");
                                a->add_data("lineno", @1.begin.line);
                                a->add_data("attr","None");
                                a->add_data("type","int");
                                $$ = a;
                            }
                ;

globaldeclarations      : globaldeclaration {$$ = $1;}
                        | globaldeclarations globaldeclaration  {$$ = $1;}
                        ;

globaldeclaration       : variabledeclaration   {$$ = $1;}
                        | functiondeclaration   {$$ = $1;}
                        | mainfunctiondeclaration   {$$ = $1;}
                        ;

variabledeclaration     : type identifier SEMI  {AST* a = new_ast("varDecl");
                                                a->add_data("type","varDecl");
                                                vector<AST*> v0 = {$1, $2};
                                                add_children(a, v0);
                                                 $$ = a;}
                        ;

identifier              : ID    {AST* a = new_ast("identifier");
                                a->add_data("attr", $1);
                                a->add_data("type","identifier");
                                $$ = a;}
                        ;

functiondeclaration     : functionheader block  {
                            AST* functiondecl = new_ast("funcDecl");
                            functiondecl->add_data("type","funcDecl");
                            add_children(functiondecl, *$1->get_group());
                            vector<AST*> v0 = {$2};
                            add_children(functiondecl, v0);

                            $$ = functiondecl;
                        }
                        ;

functionheader          : type functiondeclarator   {
                            vector<AST*> v = {$1};
                            $$ = add_asts($2, v);
                        }
                        | VOID functiondeclarator   {
                            AST* a = new_ast("void");
                            a->add_data("attr","None");
                            a->add_data("type","void");
                            vector<AST*> v = {a};
                            $$ = add_asts($2, v);
                        }
                        ;

functiondeclarator      : identifier LBRAC formalparameterlist RBRAC    {

                            ASTGroup* a = new_astgroup();
                            AST* b = new_ast("formals");
                            b->add_data("type","formals");
                            b->add_child($3);
                            vector<AST*> v = {$1, b};
                            $$ = add_asts(a, v);
                        }
                        | identifier LBRAC RBRAC    {
                            ASTGroup* a = new_astgroup();
                            vector<AST*> v = {$1};
                            $$ = add_asts(a, v);
                        }
                        ;

formalparameterlist     : formalparameter   {$$ = $1;}
                        | formalparameterlist COMM formalparameter  {$$ = $1;}
                        ;

formalparameter         : type identifier   {AST* a = new_ast("formal");
                                            vector<AST*> v = {$1, $2};
                                            $$ = add_children(a, v);}
                        ;

mainfunctiondeclaration : mainfunctiondeclarator block  { AST* functiondecl = new_ast("mainDecl");
                                                        functiondecl->add_data("type","mainDecl");
                                                        AST* b = new_ast("void");
                                                        b->add_data("type","void");$1->add_ast_index(b, 0);
                                                        add_children(functiondecl, *$1->get_group());
                                                        vector<AST*> v0 = {$2};
                                                        add_children(functiondecl, v0);
                                                        
                                                        $$ = functiondecl;
                                                        }
                        ;

mainfunctiondeclarator  : identifier LBRAC RBRAC    {
                                                        // Not done.
                                                        ASTGroup* a = new_astgroup();
                                                        AST* b = new_ast("identifier");
                                                        b->add_data("attr", "main");
                                                        b->add_data("type","identifier");
                                                        vector<AST*> v= {b};
                                                        add_asts(a, v);

                                                        $$ = a;
                                                    }
                        ;

block                   : LCURL blockstatements RCURL   { AST* a = new_ast("block");
                                                            a->add_data("type","block");
                                                            $$ = add_children(a, *$2->get_group());
                                                        }
                        | LCURL RCURL   {$$ = $1;}
                        ;

blockstatements         : blockstatement    {
                                                ASTGroup* ag = new_astgroup();
                                                ag->add_ast($1);
                                                $$ = ag;
                                            }
                        | blockstatements blockstatement    {
                                                                $1->add_ast($2);
                                                                $$ = $1;
                                                            }
                        ;

blockstatement          : variabledeclaration   {$$ = $1;}
                        | statement {$$ = $1;}
                        ;

statement               : block {$$ = $1;}
                        | SEMI  {AST* a = new_ast("nullStmt");
                                a->add_data("lineno", @1.begin.line);
                                a->add_data("type","nullStmt");
                                $$ =a;}
                        | statementexpression SEMI  {$$ = $1;}
                        | BREAK SEMI    {$$ = $1;}
                        | RET expression SEMI   {
                            AST * a = new_ast("return");
                            a->add_data("type","return");
                            vector<AST*> v = {$2};
                            $$ = add_children(a, v);
                        }
                        | RET SEMI  {
                            // This is wrong!
                            AST* a = new_ast($1); 
                            $$ = a;
                        }
                        | IF LBRAC expression RBRAC statement   {AST * a = new_ast("if");
                        a->add_data("type","if");
                        vector<AST*> v = {$3};
                        add_children(a, v);
                        $$ = a;
                        }
                        | IF LBRAC expression RBRAC statement ELSE statement    {$$ = $1;}
                        | WHILE LBRAC expression RBRAC statement    {AST * a = new_ast("while");
                        a->add_data("type","while");
                        vector<AST*> v = {$3};
                        add_children(a, v);
                        $$ = a;}
                        ;

statementexpression     : assignment    {$$ = $1;}
                        | functioninvocation    {$$ = $1;}
                        ;

primary                 : literal   {$$ = $1;}
                        | LBRAC expression RBRAC    {$$ = $2;}
                        | functioninvocation    {$$ = $1;}
                        ;

argumentlist            : expression    {$$ = $1;}
                        | argumentlist COMM expression  {$$ = $1;}
                        ;

functioninvocation      : identifier LBRAC argumentlist RBRAC   {$$ = $1;}
                        | identifier LBRAC RBRAC    {$$ = $1;}
                        ;

postfixexpression       : primary   {$$ = $1;}
                        | identifier    {$$ = $1;}
                        ;

unaryexpression         : '-' unaryexpression {AST * a = new_ast("-");
                                                a->add_data("type","-");
                                                vector<AST*> v = {$2};
                                                $$ = add_children(a, v);
                                            }
                        | FAC unaryexpression  {AST * a = new_ast("!");
                                                a->add_data("type","!");
                                                vector<AST*> v = {$2};
                                                $$ = add_children(a, v);}
                        | postfixexpression {$$ = $1;}
                        ;

multiplicativeexpression: unaryexpression   {$$ = $1;}
                        | multiplicativeexpression MULT unaryexpression     {AST* a = new_ast("*");
                        a->add_data("type","*");
                        a->add_data("lineno", @1.begin.line);
                        vector<AST*> v = {$1, $3};
                        $$ = add_children(a, v);}
                        | multiplicativeexpression DIV unaryexpression  {AST* a = new_ast("/");
                        a->add_data("type","/");
                        a->add_data("lineno", @1.begin.line);
                        vector<AST*> v = {$1, $3};
                        $$ = add_children(a, v);}
                        | multiplicativeexpression MOD unaryexpression  {AST* a = new_ast("%");
                        a->add_data("type","%");
                        a->add_data("lineno", @1.begin.line);
                        vector<AST*> v = {$1, $3};
                        $$ = add_children(a, v);}
                        ;

additiveexpression      : multiplicativeexpression  {$$ = $1;}
                        | additiveexpression ADD multiplicativeexpression   {AST* a = new_ast("+");
                        a->add_data("type","+");
                        a->add_data("lineno", @1.begin.line);
                        vector<AST*> v = {$1, $3};
                        $$ = add_children(a, v);
                        }
                        | additiveexpression '-' multiplicativeexpression   {AST* a = new_ast("-");
                        a->add_data("type","-");
                        a->add_data("lineno", @1.begin.line);
                        vector<AST*> v = {$1, $3};
                        $$ = add_children(a, v);}
                        ;

relationalexpression    : additiveexpression    {$$ = $1;}
                        | relationalexpression LT additiveexpression    {AST* a = new_ast("<");
                        a->add_data("type","<");
                        a->add_data("lineno", @1.begin.line);
                        vector<AST*> v = {$1, $3};
                        $$ = add_children(a, v);}
                        | relationalexpression GT additiveexpression    {AST* a = new_ast(">");
                        a->add_data("type",">");
                        a->add_data("lineno", @1.begin.line);
                        vector<AST*> v = {$1, $3};
                        $$ = add_children(a, v);}
                        | relationalexpression LE additiveexpression    {AST* a = new_ast("<=");
                        a->add_data("type","<=");
                        a->add_data("lineno", @1.begin.line);
                        vector<AST*> v = {$1, $3};
                        $$ = add_children(a, v);}
                        | relationalexpression GE additiveexpression    {AST* a = new_ast(">=");
                        a->add_data("type",">=");
                        a->add_data("lineno", @1.begin.line);
                        vector<AST*> v = {$1, $3};
                        $$ = add_children(a, v);}
                        ;

equalityexpression      : relationalexpression  {$$ = $1;}
                        | equalityexpression ASS relationalexpression   {AST* a = new_ast("=");
                        a->add_data("type","=");
                        a->add_data("lineno", @1.begin.line);
                        vector<AST*> v = {$1, $3};
                        $$ = add_children(a, v);}
                        | equalityexpression NEQ relationalexpression   {AST* a = new_ast("!=");
                        a->add_data("type","!=");
                        a->add_data("lineno", @1.begin.line);
                        vector<AST*> v = {$1, $3};
                        $$ = add_children(a, v);}
                        ;

conditionalandexpression: equalityexpression    {$$ = $1;}
                        | conditionalandexpression AND equalityexpression   {AST* a = new_ast("&&");
                        a->add_data("type","&&");
                        a->add_data("lineno", @1.begin.line);
                        vector<AST*> v = {$1, $3};
                        $$ = add_children(a, v);}
                        ;

conditionalorexpression : conditionalandexpression  {$$ = $1;}
                        | conditionalorexpression OR conditionalandexpression   {AST* a = new_ast("||");
                        a->add_data("type","||");
                        a->add_data("lineno", @1.begin.line);
                        vector<AST*> v = {$1, $3};
                        $$ = add_children(a, v);}
                        ;

assignmentexpression    : conditionalorexpression   {$$ = $1;}
                        | assignment    { $$ = $1;}
                        ;

assignment              : identifier ASS assignmentexpression   {
                                                                AST * a = new_ast("stmtExpr");
                                                                AST * b = new_ast("=");
                                                                b->add_data("lineno", @1.begin.line);
                                                                b->add_data("type","=");
                                                                a->add_data("lineno", @1.begin.line);
                                                                a->add_data("type","stmtExpr");
                                                                vector<AST*> v = {b};
                                                                vector<AST*> v2 = {$1, $3};
                                                                add_children(b, v2);
                                                                $$ = add_children(a, v);}
                        ;

expression              : assignmentexpression  {$$ = $1;}
                        ;

%%

/* Parser will call this function when it fails to parse */
/* Tip: You can store the current token in the lexer to output meaningful error messages */
void JCC::Parser::error(const location_type &loc, const std::string &errmsg)
{
   std::cerr << "Error: " << errmsg << " at " << loc << "\n";
}
