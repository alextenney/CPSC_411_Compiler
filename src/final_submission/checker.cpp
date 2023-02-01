#include <fstream>
#include <memory>
#include <iostream>
#include <string>
#include <unordered_map>
#include <stack>
#include <utility>
#include <vector> 
#include <sstream>
#include "ast.h" 
#include "checker.hpp"

int main_total = 0;
int block_total = 0;
int return_total = 0;
bool needs_return = 0;
int break_total = 0;
std::unordered_map<std::string, std::unordered_map<std::string, struct record>> symbol_table;
// std::unordered_map<std::string, std::string> function_type_table;
std::vector<std::string> scope;
std::unordered_map<std::string, vector<vector<string>>> legal;

std::vector<std::string> returns;

void print_map(){
    for (auto const &pair: symbol_table) {
        std::cout << pair.first << std::endl;
        for (auto const &pair2: pair.second) {
            std::cout << "  " << pair2.first << " {sig: " << pair2.second.sig << ", type: " << pair2.second.type << "}" << std::endl;
        }
    }
}

void find_return(AST * node) {
    if (node->token_id == "return") {
        returns.push_back(node->sig);
    }
}

void populate_legal(){
    // ||
    legal.insert(make_pair("||", vector<vector<string>>{
        vector<string> {"boolean", "boolean", "boolean"}
    }));
    // &&
    legal.insert(make_pair("&&", vector<vector<string>>{
        vector<string> {"boolean", "boolean", "boolean"}
    }));
    // ==
    legal.insert(make_pair("==", vector<vector<string>>{
        vector<string> {"boolean", "boolean", "boolean"},
        vector<string> {"int", "int", "boolean"}
    }));
    // !=
    legal.insert(make_pair("!=", vector<vector<string>>{
        vector<string> {"boolean", "boolean", "boolean"},
        vector<string> {"int", "int", "boolean"}
    }));
    // =
    legal.insert(make_pair("=", vector<vector<string>>{
        vector<string> {"boolean", "boolean", "boolean"},
        vector<string> {"boolean", "bool", "boolean"},
        vector<string> {"bool", "boolean", "boolean"},
        vector<string> {"int", "int", "int"}
    }));
    // <
    legal.insert(make_pair("<", vector<vector<string>>{
        vector<string> {"int", "int", "boolean"},
    }));
    // >
    legal.insert(make_pair(">", vector<vector<string>>{
        vector<string> {"int", "int", "boolean"},
    }));
    // <=
    legal.insert(make_pair("<=", vector<vector<string>>{
        vector<string> {"int", "int", "boolean"},
    }));
    // >=
    legal.insert(make_pair(">=", vector<vector<string>>{
        vector<string> {"int", "int", "boolean"},
    }));
    // +
    legal.insert(make_pair("+", vector<vector<string>>{
        vector<string> {"int", "int", "int"},
    }));
    // *
    legal.insert(make_pair("*", vector<vector<string>>{
        vector<string> {"int", "int", "int"},
    }));
    // /
    legal.insert(make_pair("/", vector<vector<string>>{
        vector<string> {"int", "int", "int"},
    }));
    // %
    legal.insert(make_pair("%", vector<vector<string>>{
        vector<string> {"int", "int", "int"},
    }));
    // !
    legal.insert(make_pair("!", vector<vector<string>>{
        vector<string> {"boolean", "boolean"},
    }));
    // -
    legal.insert(make_pair("-", vector<vector<string>>{
        vector<string> {"int", "int", "int"},
        vector<string> {"int", "int"}
    }));
}

string check_legal(string operand, string child1, string child2="") {
    vector<vector<string>> a = legal[operand];

    // cout << "op:" << operand << " child1: " << child1 << " child2: " << child2 << endl;

    for (auto x1 : a) {
        if (x1.size() == 2 && child2 == "") {
            // Unary
            if (x1[0] == child1) {
                return x1[1];
            }
        } else if (x1.size() == 3 && child2 != "") {
            // Binary
            if (x1[0] == child1 && x1[1] == child2) {
                return x1[2];
            }
        }
    }

    return "";
}

string find_name(string name) {
    string return_string = "";

    if (symbol_table["global"].find(name) != symbol_table["global"].end()) {
        return "global";
    }
    
    for (auto it = scope.rbegin(); it != scope.rend(); it++) {
        if (symbol_table[*it].find(name) != symbol_table[*it].end()) {
            return_string = *it;
            break;
        }
    }

    return return_string;
}

void add_predefs(){

    std::unordered_map<std::string, struct record> predefs;

    predefs["getchar"] = {"f()", "int"};
    predefs["halt"] = {"f()", "void"};
    predefs["printb"] = {"f(boolean)", "void"};
    predefs["printc"] = {"f(int)", "void"};
    predefs["printi"] = {"f(int)", "void"};
    predefs["prints"] = {"f(string)", "void"};
    
    symbol_table["predef"] = predefs;
    scope.push_back("predef");

}


void pass1(AST * node){
    if (node->token_id == "funcDecl"){
        // string sig = "f(" + node->get_children()->at(1)->sig + ")";
        string sig = "f()";
        int type_index = 1;

        vector<AST *> * children = node->get_children();
        for (auto c : *children) {
            if (c->token_id == "formals") {
                sig = "f" + c->sig;
                type_index = 2;
                break;
            }
        }

        node->sig = sig;

        string type = node->get_children()->at(type_index)->token_id;
        if (type == "boolean") {
            type = "boolean";
        }

        record r = {sig, type};
        pair<string, struct record> record = make_pair((node->get_children()->at(0)->data["attr"]), r);
        symbol_table["global"].insert(record);
        //symbol_table[node->get_children()->at(0)->data["attr"]] = sig;
        // function_type_table[node->get_children()->at(0)->data["attr"]] = node->get_children()->at(2)->token_id;
    } else if (node->token_id == "globalVarDecl") {
        string sig = node->get_children()->at(0)->token_id;
        node->sig = sig;

        record r = {sig, node->get_children()->at(0)->token_id};
        pair<string, struct record> record = make_pair((node->get_children()->at(1)->data["attr"]), r);
        symbol_table["global"].insert(record);
        //symbol_table[node->get_children()->at(1)->data["attr"]] = node->get_children()->at(0)->token_id;
    } else if (node->token_id == "mainDecl") {
        main_total++;
        string sig = "f()";
        node->sig = sig;

        record r = {sig, "void"};
        pair<string, struct record> record = make_pair((node->get_children()->at(1)->data["attr"]), r);
        symbol_table["global"].insert(record);
        //symbol_table[node->get_children()->at(1)->data["attr"]] = "f()";

    } else if (node->token_id == "formal") {
        node->sig = node->get_children()->at(0)->sig;
    } else if (node->token_id == "formals") {
        if (node->get_children()->size() == 0){
            node->sig = "()";
        } else {
            string sig = "(";
            for (auto child : *node->get_children()) {
                sig += child->sig + ", ";
            }
            sig = sig.substr(0, sig.size() - 2);
            sig += ")";
            node->sig = sig;
        }
    } else if (node->token_id == "number") {
        node->sig = "int";

    } else if (node->token_id == "true") {
        node->sig = "boolean";

    } else if (node->token_id == "false") {
        node->sig = "boolean";

    } else if (node->token_id == "string") {
        node->sig = "string";

    } else if (node->token_id == "boolean"){
        node->sig = "boolean";

    } else if (node->token_id == "int") {
        node->sig = "int";

    } else if (node->token_id == "void") {
        node->sig = "void";

    }else if(node->token_id == "varDecl") {
        node->sig = node->get_children()->at(0)->sig;

    }
}

void pass2(AST * node, int direction){

    string stack_scope = "";

    if (!direction){

        if (node->token_id == "funcDecl"){

            stack_scope = node->get_children()->at(0)->data["attr"];
            scope.push_back(stack_scope);
         
        }

        else if (node->token_id == "block") {

            block_total++;

        } else if (node->token_id == "formal"){

            record r = {node->get_children()->at(0)->data["type"], ""};
            pair<string, struct record> record = make_pair((node->get_children()->at(1)->data["attr"]), r);
            symbol_table[scope.back()].insert(record);

        } else if (node->token_id == "actuals"){
            string sig;

            for (auto child : *node->get_children()) {
                if (child->token_id == "number"){
                    sig = "int";
                } else if (child->token_id == "true"){
                    sig = "boolean";
                } else if (child->token_id == "false"){
                    sig = "boolean";
                } else if (child->token_id == "string"){
                    sig = "string";
                }

                record r = {sig, ""};
                pair<string, struct record> record = make_pair(child->data["attr"], r);
                symbol_table[scope.back()].insert(record);
            } 
            
        }
        else if (node->token_id == "varDecl") {

            string variable_id = node->get_children()->at(1)->data["attr"];

            if (symbol_table[scope.back()].find(variable_id) != symbol_table[scope.back()].end()){
                std::cerr << "Variable or Function Already Defined. Line Number: " << node->data["lineno"] << std::endl;
                exit(1);
                
            } else if (block_total > 1){
                std::cerr << "Variable not in the outer most block " << std::endl;
                exit(1);
            } 

            string sig = node->get_children()->at(0)->sig;
            //node->sig = sig;

            record r = {sig, ""};
            pair<string, struct record> record = make_pair(variable_id, r);
            symbol_table[scope.back()].insert(record);
            

        } 

    } else {

        if (node->token_id == "funcDecl"){
            scope.pop_back();
        // 
        } else if (node->token_id == "block") {
            block_total--;
        } else if (node->token_id == "identifier"){
            string response = find_name(node->data["attr"]);

            if (response == ""){
                std::cerr << "undeclared variable" << std::endl;
                exit(1);
                
            }

            record * stab = &symbol_table[response][node->data["attr"]];
            
            node->stab = stab;

            string sig = symbol_table[find_name(node->data["attr"])][node->data["attr"]].sig;

            node->sig = sig;

        } 

    } 

}

void pass3(AST * node){

    if (node->token_id == "stmtExpr") {
        node->sig = node->get_children()->at(0)->sig;
    }

    if (node->token_id == "funcCall"){

        string sig = "f(";
        if (node->get_children()->size() > 1) {
            for (auto child : *node->get_children()->at(1)->get_children()) {
                if (child->token_id == "funcCall"){
                    string id = child->get_children()->at(0)->data["attr"];
                    sig += symbol_table["global"][id].type + ", ";
                } else {
                    sig += child->sig + ", ";
                }
            }
            sig = sig.substr(0, sig.size() - 2);
        }
        sig += ")";

        node->sig = sig;
        string fsig_table = symbol_table[find_name(node->get_children()->at(0)->data["attr"])][node->get_children()->at(0)->data["attr"]].sig;

        if (node->sig != fsig_table){
            cerr << node->sig << " != " << fsig_table << endl;
            cerr << "The number/type of arguments in a function call doesn't match the function's declaration" << endl;
            exit(1);
        }

    }

    bool correct = false;
    for (auto const &p : legal) {
        if (p.first == node->token_id) {
            correct = true;
        }
    }
    if (!correct) return;

    if (node->get_children()->size() == 0) {
        return;
    }

    string sig = "";

    if ((node->token_id == "-" || node->token_id == "!") && node->get_children()->size() == 1) {
        if(node->get_children()->at(0)->token_id == "funcCall") {
            string lookup = node->get_children()->at(0)->get_children()->at(0)->data["attr"];
            string fsig_table = symbol_table[find_name(lookup)][lookup].type;
            sig = check_legal(node->token_id, fsig_table);
        }

        else {
            sig = check_legal(node->token_id, node->get_children()->at(0)->sig);
        }
    } else {

        if (node->get_children()->size() >= 2 && node->get_children()->at(0)->token_id == "funcCall" && node->get_children()->at(1)->token_id == "funcCall"){

            string lookup1 = node->get_children()->at(1)->get_children()->at(0)->data["attr"];
            //cout << lookup1 << endl;
            string fsig_table1 = symbol_table[find_name(lookup1)][lookup1].type;
            //cout << fsig_table1 << endl;

            string lookup2 = node->get_children()->at(0)->get_children()->at(0)->data["attr"];
            //cout << lookup2 << endl;
            string fsig_table2 = symbol_table[find_name(lookup2)][lookup2].type;
            //cout << fsig_table2 << endl;

            sig = check_legal(node->token_id, fsig_table2, fsig_table1);

        } else if(node->get_children()->size() >= 2 && node->get_children()->at(0)->token_id == "funcCall") {
            string lookup = node->get_children()->at(0)->get_children()->at(0)->data["attr"];
            string fsig_table = symbol_table[find_name(lookup)][lookup].type;
            //cout << lookup << endl;
            //cout << fsig_table << endl;

            sig = check_legal(node->token_id, fsig_table, node->get_children()->at(1)->sig);

        } else if (node->get_children()->size() >= 2 && node->get_children()->at(1)->token_id == "funcCall"){
            string lookup = node->get_children()->at(1)->get_children()->at(0)->data["attr"];
            string fsig_table = symbol_table[find_name(lookup)][lookup].type;

            sig = check_legal(node->token_id, node->get_children()->at(0)->sig, fsig_table);

        } else if (node->get_children()->size() >= 2) {
            sig = check_legal(node->token_id, node->get_children()->at(0)->sig, node->get_children()->at(1)->sig);

        }
    }

    if (sig != "") {
        node->sig = sig;
    } else {
        std::cerr << "type mismatch for " << node->token_id << std::endl;
        exit(1);
    }
}

void return_checks(AST * node){

    if (node->token_id == "return") {
        //set sig
        if (!node->get_children()->empty()) {
            if (node->get_children()->at(0)->token_id == "funcCall") {
                string lookup = node->get_children()->at(0)->get_children()->at(0)->data["attr"];
                node->sig = symbol_table[find_name(lookup)][lookup].type;
            } else {
                node->sig = node->get_children()->at(0)->sig;
            }
        } else {
            node->sig = "void";
        }

    } else if (node->token_id == "break") {
        break_total++;

    }
    
}

void pass4(AST * node, int direction){

    // return check

    if (!direction) {

        return_checks(node);

        if (node->token_id == "funcCall"){

            if (node->get_children()->at(0)->data["attr"] == "main"){

                std::cerr << "main function should not be called" << std::endl;
                exit(1);

            }
            

        } else if (node->token_id == "if" || node->token_id == "while"){
            AST * child = node->get_children()->at(0);
            
            string check = "";
            if (child->token_id == "funcCall") {
                string lookup = child->get_children()->at(0)->data["attr"];
                check = symbol_table[find_name(lookup)][lookup].type;
            } else {
                check = child->sig;
            }

            if (check != "boolean"){
                cerr << "An if- or while-condition must be of Boolean type." << endl;
                exit(1);
            }

        } 
  
    } else {
        if (node->token_id == "while") {
            break_total--;
        }else if (node->token_id == "block"){
            int type_index = 0;
            bool found_return = false;

            vector<AST *> * children = node->get_children();
            for (auto c : *children) {
                if (c->token_id == "return") {
                    found_return = true;
                    break;
                }
                type_index++;
            }

            if (found_return) {
                node->sig = node->get_children()->at(type_index)->sig;
            } else {
                node->sig = "void";
                // postorder(node, find_return);
                // if (!returns.empty()) {
                //     cout << "found in postorder" << endl;
                //     node->sig = returns.back();
                //     returns.pop_back();
                // } else {
                //     node->sig = "void";
                // }
            }


        }
        else if (node->token_id == "funcDecl") {
            // check this

            string func_name = node->get_children()->at(0)->data["attr"];

            //cout << func_name<< endl;
            //node->sig = node->get_children()->at(0)->sig;

            string lookup = node->get_children()->at(0)->data["attr"];
            string fsig_table = symbol_table[find_name(lookup)][lookup].type;

            //cout << "HERE: " << symbol_table[find_name("global")][lookup].sig << endl;
            if (fsig_table != "void"){

                return_total--;

            }

            string ret_val = "void";
            
            returns.clear();

            postorder(node, find_return);

            if (!returns.empty()) {
                ret_val = returns.back();
                returns.pop_back();
            }


            // if (fsig_table != node->get_children()->at(2)->sig){
            if (fsig_table != ret_val){
                std::cerr << fsig_table << "!=" << ret_val << std::endl;
                // std::cerr << fsig_table << "!=" << node->get_children()->at(2)->sig << std::endl;
                std::cerr << "function return type does not match expected" << std::endl;
                exit(1);

            }

        } else if (node->token_id == "stmtExpr") {

            node->sig = node->get_children()->at(0)->sig;
        }
    }


}

void postorder(AST * root, void (*callback)(AST *)){

    for (auto a : *root->get_children()){
        postorder(a, callback);
    }

    callback(root);
}

void preorder(AST * root, void (*callback)(AST *, int)){
    callback(root, 0);
    for (auto a : *root->get_children()){
        preorder(a, callback);
    }
    callback(root, 1);
}

void doPasses(AST * root) {
    postorder(root, pass1);

    // Do main check here;
    if (main_total != 1){
        if (main_total > 1){
            std::cerr << "multiple main functions declared" << std::endl;
        } else if (main_total < 1) {
            std::cerr << "missing main function delclaration" << std::endl;
        }
        exit(1);
    } 

    add_predefs();
    scope.push_back("global");

    preorder(root, pass2);  

    populate_legal();
    postorder(root, pass3);
    preorder(root,pass4);
    if (return_total > 0){
        cerr << "return found not inside a function, or in a function with no return expected" << endl;
        exit(1);
    }
    else if (break_total > 0){
        cerr << "break found when not expected" << endl;
        exit(1);
    }
}


