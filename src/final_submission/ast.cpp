#include <vector>
#include <stddef.h>
#include "ast.h"
#include <iostream>
#include <string>
#include <map>

//
//  The AST Class gives the ability to add data to an 
//  Abstract Syntax Tree, of which is later used in the 
//  Semantic Checker.
//
//  add_child() -> adds a single child to a node fo the AST
//  add_children() -> adds a vector of children to a node of the AST
//  add_sibiling() -> adds a single sibling to a node of the AST
//  add_siblings() -> adds a vector of siblings to a node of the AST
//  printTree() -> recursively prints the tree for the purpose of MS2
//  traverseTree() -> traverses the tree to preform Semmatic Checks
//
//

#include <vector>
#include <stddef.h>
#include "ast.h"
#include <iostream>
#include <string>
#include <map>


using namespace std;

ASTGroup::ASTGroup() {}

ASTGroup::~ASTGroup() {}

void ASTGroup::add_ast(AST* ast) {
    this->group.push_back(ast);
}

void ASTGroup::add_ast_index(AST* ast, int index) {
    auto it = this->group.begin() + index;
    this->group.insert(it, ast);
}

vector<AST*>* ASTGroup::get_group() {
    return &this->group;
}

AST::AST(string token_id) {
    this->token_id = token_id;
}

AST::~AST() {}

void AST::set_token_id(string type){
    this->token_id = type;
}

void AST::add_child(AST* child) {
    this->children.push_back(child);
}

void AST::add_data(string key, string value) {
    this->data.insert(std::pair<string, string>(key, value));
}

void AST::add_data(string key, int value) {
    string s = std::to_string(value);
    this->data.insert(std::pair<string, string>(key, s));
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
    std::cout << string(level, ' ');
    std::cout << ast->token_id << " {";

    map<string, string>::iterator i;
    for (i = ast->data.begin(); i != ast->data.end(); i++) {
        std::cout << "'" << i->first << "'" << ": " << "'" << i->second << "'";

        if (next(i) == ast->data.end()) {
            std::cout << "}";
        } else {
            std::cout << ", ";
        }
    }
    cout << "SIG: " << ast->sig;
    std::cout << std::endl;

    for (AST* child : *ast->get_children()) {
        printTree(child, level + 2);
    }
}

void printSig(AST* ast, int level) {
    std::cout << string(level, ' ');
    std::cout << ast->token_id << " {";

    std::cout << "{'sig': '" << ast->sig << "'}";
    std::cout << std::endl;

    for (AST* child : *ast->get_children()) {
        printSig(child, level + 2);
    }
}

ASTGroup* new_astgroup() {
    ASTGroup * new_ast_group = new ASTGroup();

    return new_ast_group;
}

ASTGroup* add_asts(ASTGroup* astgroup, vector<AST*> & asts) {
    for (AST* ast : asts) {
        astgroup->add_ast(ast);
    }
    return astgroup;
}

ASTGroup* merge_astgroup(ASTGroup* a, ASTGroup* b) {
    add_asts(a, *b->get_group());
    return a;
}

AST * add_children(AST* root, vector<AST*> & children) {
    for (AST* child : children) {
        root->add_child(child);
    }
    return root;
}

AST * new_ast(string token_id) {
    AST* new_ast = new AST(token_id);

    return new_ast;
}
