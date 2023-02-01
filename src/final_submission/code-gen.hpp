#include <stdio.h>
#include <iostream>

#include "ast.h"

void get_char();

void prints();

void printi();

void halt();

void printb();

void printc();

void gen_pass1(AST * node, int direction);

void gen_pass2(AST * node, int direction);

string get_reg(AST * node);

string get_identifier_addr(string id);

void customTraverse(AST * root, void (*callback)(AST *, int));

void traverse(AST * root);

