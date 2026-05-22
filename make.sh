#!/bin/bash

bison -d -v -r all parser.y
flex mylexer.l
gcc -o mycompiler lex.yy.c parser.tab.c cgen.c -lfl -lm
