#pragma once
#include <vector>
#include <string>
#include <map>

using namespace std;

struct record{
string sig;
string type;
};

class AST {
    public:
        string token_id;
        map<string, string> data;
        vector<AST*> children;
        string sig = "";
        string reg = "";
        string parent_id = "";
        record * stab = nullptr;

        AST(string token_id);
        ~AST();

        void set_token_id(string type);

        void add_child(AST* child);

        void add_data(string key, string value);

        void add_data(string key, int value);

        vector<AST*>* get_children();
};

class ASTGroup {
    public: 
        vector<AST*> group;

        ASTGroup();
        ~ASTGroup();

        void add_ast(AST* ast);

        void add_ast_index(AST* ast, int index);

        vector<AST*>* get_group();
};

void cleanup();

void printTree(AST* ast, int level);
void printSig(AST* ast, int level);

ASTGroup * new_astgroup();

ASTGroup* add_asts(ASTGroup* astgroup, vector<AST*> & asts);

ASTGroup* merge_astgroup(ASTGroup* a, ASTGroup* b);

AST * add_children(AST* root, vector<AST*> & children);

AST * new_ast(string token_id);


// AST* leaf(string data, string key);

// AST* unary(string data, AST* child);

// AST* binary(string data, AST* L_child, AST* R_child);
