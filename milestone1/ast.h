#pragma once
#include <vector>

using namespace std;
 
class AST {
    public:
        int data;
        int key;
        vector<AST*> children;

        AST(int data, int key);
        ~AST();

        void add_child(AST* child);

        vector<AST*>* get_children();
};

void cleanup();

void printTree(AST* ast, int level);

AST* leaf(int data, int key);

AST* unary(int data, AST* child);

AST* binary(int data, AST* L_child, AST* R_child);
