#!/bin/bash

#dimiourgia tou parser apo to arxeio parser.y me xrisi tou bison
bison -d -v -r all parser.y

#dimiourgia tou lexer apo to arxeio mylexer.l me xrisi tou flex
flex mylexer.l

# meteglottisi olwn twn arxeiwn kai dimiourgia tou ektelesimou mycompiler
gcc -o mycompiler lex.yy.c parser.tab.c cgen.c -lfl -lm
