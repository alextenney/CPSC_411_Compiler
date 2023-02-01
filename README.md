# CPSC 411 - J-- Compiler

The following compiler was made for CPSC 411 at the University of Calgary, conducted by Dr. John Aycock. In this course, a small language which happens to be a subset of Java, called J-- was designed in order for the students of the class to make a compiler for. The compiler uses the Assembly language of Mips, and was implemented using compiler tools Flex and Bison.  

## Prerequisites

* A g++ compiler, as well as the language C++ installed localled on the machine
* Flex
* Bison

## Marking

For my final submission, all MIPs code outputted from their respective test cases is found in `src/final_submission/final_output`, and all the outputs of those MIPs programs being ran on the lab machines can be found in `src/final_submission/mips_output`. 

I believe I pass 16/21 test cases. All except gen.t34, gen.t38, art-life.j--, art-sieve.j-- and art-select.j-- should produce correct output.

## Installation

In order to install the compiler, one simply must clone the current git repo and run `make` when in the `src/final_submission` folder on a linux machine. The executable will be named `main`.

## Usage

The compiler is used much like any other language compiler. Run `./main <file>` on any J-- program, and the compiler will create equivalent MIPS code, which is printed to standard out. This code could then be copied to a file, and compiled and ran using spim.

## Author

Written by: Alexandra Tenney (30042397)

## Testing

Testing was done both locally on my own machine (running Manjaro Linux, which is an Arch-based OS), and on the lab machines. The compiler should make, and run on both kinds of machines. No testing was done on Mac or Windows Os'. 

## Known Bugs

1. A variable's identifier must be unique, no matter the type.
  * an example of this bug can be found when running gen.t38

2. Registers occassionally run out when used on larger programs. 
  * an example of this bug can be found when running art-life.j--
