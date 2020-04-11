# LabProject
This project designs a compiler capable of performing number manipulations and boolean comparisons while also generating the three address code into a separate text file.

INPUT IS TAKEN FROM equations.txt

FOR COMPILING USE BELOW INSTRUCTIONS
lex callex.l
yacc calyacc.y
gcc y.tab.c -ll -ly
./a.out

Output is printed on the terminal. Three address code is generated in file intcode.txt.
