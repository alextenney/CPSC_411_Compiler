/* The basis of the following code was */
/* sourced from the Shankar Ganesh's example titled */
/* titled https://pages.cpsc.ucalgary.ca/~sankarasubramanian.g/411/files/flex-cpp.zip */

#include <FlexLexer.h>
#include "scanner.hpp"
#include <cstdlib>
#include <cerrno>
#include <cstring>
#include <string>


int main(int argc, char **argv) {

    // the following code simple streams through a file inputed as an argument when the scanner is run

    std::istream *input = &std::cin;

    std::ifstream file;

    if (argc == 2) {
        file.open(argv[1]);;

        if (!file.is_open()) {
            std::cerr << "\033[1m\033[31mfatal error: \x1B[0mFailed to open file " << argv[1] << std::endl;
            std::cerr << std::strerror(errno) << std::endl;
            return EXIT_FAILURE;
        }

        input = &file;
    }

    // Create lexer object
    auto lexer = createLexer(input);
    int tok;

    // while ((tok = lexer->yylex()) != 0) {
    //     std::string a(lexer->YYText(), lexer->YYLeng());
    //     std::cout << "line: " << lexer->getLine() << " token: " << getName(tok) << " Lexeme: " << a << "\n";
    // }

    auto parser = std::make_unique<JCC::Parser>(lexer);
   
    if( parser->parse() != 0 )
    {
        std::cerr << "Parse failed!!\n";
        if (file.is_open()) file.close();
        return 1;
    }

    if (file.is_open()) file.close();

    return EXIT_SUCCESS;
}
