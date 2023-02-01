#include <fstream>
#include <memory>
#include <iostream>

#include "ast.h"

void print_map();

void pass1(AST * node);
void pass2(AST * node, int direction);
void pass3(AST * node);

void postorder(AST * root, void (*callback)(AST *));

void preorder(AST * root, void (*callback)(AST *, int));

void doPasses(AST * root);