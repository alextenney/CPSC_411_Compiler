#include <vector>
#include <stddef.h>
#include "ast.h"
#include <iostream>

using namespace std;


AST::AST(int data, int key) {
    this->data = data;
    this->key = key;
}

AST::~AST() {}

void AST::add_child(AST* child) {
    this->children.push_back(child);
}

vector<AST*>* AST::get_children() {
    return &this->children;
}

void cleanup(AST* ast) {
    for (AST* child : *ast->get_children()) {
        cleanup(child);
    }
    delete ast;
}

void printTree(AST* ast, int level) {
    cout << string(level, ' ') << "Data: " << ast->data << endl; 

    for (AST* child : *ast->get_children()) {
        printTree(child, level + 2);
    }
}

AST* leaf(int data, int key) {
    AST* leaf_ast = new AST(data, key);
    
    return leaf_ast;
}

AST* unary(int data, AST* child) {
    AST* unary_ast = new AST(data, 0);
    unary_ast->add_child(child);

    return unary_ast;
}

AST * binary(int data, AST* L_child, AST* R_child) {
    AST* binary_ast = new AST(data, 0);
    binary_ast->add_child(L_child);
    binary_ast->add_child(R_child);

    return binary_ast;
}
