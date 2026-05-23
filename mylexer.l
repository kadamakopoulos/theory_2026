%{

#include "parser.tab.h"

#include <stdio.h>
#include <string.h>
#include <stdlib.h>

int lineNum = 1;

/*----@def table----*/
#define MAX_DEFS 100
char def_names[MAX_DEFS][256];
char def_values[MAX_DEFS][1024];
int  def_count = 0;

void add_def(char *name, char *val) {
    /* check if already exists and update */
    for(int i = 0; i < def_count; i++) {
        if(strcmp(def_names[i], name) == 0) {
            strcpy(def_values[i], val);
            return;
        }
    }
    strcpy(def_names[def_count], name);
    strcpy(def_values[def_count], val);
    def_count++;
}

char *find_def(char *name) {
    for(int i = def_count-1; i >= 0; i--) {
        if(strcmp(def_names[i], name) == 0)
            return def_values[i];
    }
    return NULL;
}

/* stack for @def expansions */
#define MAX_STACK 50
YY_BUFFER_STATE buf_stack[MAX_STACK];
int stack_top = 0;

%}

/*********************DEFINITIONS*************************/

ID              [a-zA-Z][0-9a-zA-Z_]*
DIGIT           [0-9]
NUMBER          {DIGIT}{DIGIT}*
INTPART         (0|[1-9]{DIGIT}*)
FRACPART        "."{DIGIT}+
EXPPART         ([eE][+-]?{INTPART})
REAL            {INTPART}{FRACPART}{EXPPART}?
CONST_STR       \"([^"\\\n]|\\.)*\"
MEMBER          "#"{ID}

%option noyywrap
%option yylineno

/*********************RULES*************************/
%%

"@def"[ \t]+{ID}[ \t]+[^\n]+ {
    /* handle @def macros */
    char *p = yytext + 4; /* skip @def */
    while(*p == ' ' || *p == '\t') p++;
    char name[256];
    int i = 0;
    while(*p && *p != ' ' && *p != '\t') name[i++] = *p++;
    name[i] = '\0';
    while(*p == ' ' || *p == '\t') p++;
    /* trim trailing whitespace */
    char val[1024];
    strcpy(val, p);
    int len = strlen(val);
    while(len > 0 && (val[len-1]=='\n'||val[len-1]=='\r'||val[len-1]==' '||val[len-1]=='\t'))
        val[--len] = '\0';
    add_def(name, val);
}

"readText"                  {yylval.str = strdup(yytext); return KW_RSTR;}
"readInt"                   {yylval.str = strdup(yytext); return KW_RINT;}
"readReal"                  {yylval.str = strdup(yytext); return KW_RSCALAR;}
"writeText"                 {yylval.str = strdup(yytext); return KW_WSTR;}
"writeInt"                  {yylval.str = strdup(yytext); return KW_WINT;}
"writeReal"                 {yylval.str = strdup(yytext); return KW_WSCALAR;}
"write"                     {yylval.str = strdup(yytext); return KW_WRITE;}
"int"                       {yylval.str = strdup("int"); return KW_INT;}
"real"                      {yylval.str = strdup("double"); return KW_SCALAR;}
"text"                      {yylval.str = strdup("StringType"); return KW_STR;}
"bool"                      {yylval.str = strdup("int"); return KW_BOOL;}
"True"                      {yylval.str = strdup("1"); return KW_TRUE;}
"False"                     {yylval.str = strdup("0"); return KW_FALSE;}
"const"                     {yylval.str = strdup(yytext); return KW_CONST;}
"if"                        {yylval.str = strdup(yytext); return KW_IF;}
"else"                      {yylval.str = strdup(yytext); return KW_ELSE;}
"fi"                        {yylval.str = strdup(yytext); return KW_ENDIF;}
"for"                       {yylval.str = strdup(yytext); return KW_FOR;}
"in"                        {yylval.str = strdup(yytext); return KW_IN;}
"rof"                       {yylval.str = strdup(yytext); return KW_ENDFOR;}
"while"                     {yylval.str = strdup(yytext); return KW_WHILE;}
"od"                        {yylval.str = strdup(yytext); return KW_ENDWHILE;}
"break"                     {yylval.str = strdup(yytext); return KW_BREAK;}
"continue"                  {yylval.str = strdup(yytext); return KW_CONT;}
"not"                       {yylval.str = strdup(yytext); return TK_NOT;}
"and"                       {yylval.str = strdup(yytext); return TK_AND;}
"or"                        {yylval.str = strdup(yytext); return TK_OR;}
"fun"                       {yylval.str = strdup(yytext); return KW_DEF;}
"nuf"                       {yylval.str = strdup(yytext); return KW_ENDDEF;}
"main"                      {yylval.str = strdup(yytext); return KW_MAIN;}
"return"                    {yylval.str = strdup(yytext); return KW_RETURN;}
"record"                    {yylval.str = strdup(yytext); return KW_COMP;}
"drocer"                    {yylval.str = strdup(yytext); return KW_ENDCOMP;}
"of"                        {yylval.str = strdup(yytext); return KW_OF;}

{CONST_STR}                 { yylval.str = strdup(yytext); return TK_CONST_STR; }
{REAL}                      { yylval.str = strdup(yytext); return TK_REAL; }
{NUMBER}                    { yylval.str = strdup(yytext); return TK_NUMBER; }

{MEMBER}                    { 
    /* member variable like #x -> pass as identifier without # */
    yylval.str = strdup(yytext+1);
    return TK_ID;
}

{ID}                        {
    /* check if it's a @def macro */
    char *val = find_def(yytext);
    if(val != NULL) {
        if(stack_top < MAX_STACK) {
            buf_stack[stack_top++] = YY_CURRENT_BUFFER;
            yy_scan_string(val);
        }
    } else {
        yylval.str = strdup(yytext);
        return TK_ID;
    }
}

"<-"                        {yylval.str = strdup(yytext); return TK_LARROW;}
"->"                        {yylval.str = strdup(yytext); return TK_ARROW;}
"**"                        {yylval.str = strdup(yytext); return TK_POW;}
"+="                        {yylval.str = strdup(yytext); return TK_PLUSEQ;}
"-="                        {yylval.str = strdup(yytext); return TK_MINUSEQ;}
"*="                        {yylval.str = strdup(yytext); return TK_MULEQ;}
"/="                        {yylval.str = strdup(yytext); return TK_DIVEQ;}
"%="                        {yylval.str = strdup(yytext); return TK_MODEQ;}
"=="                        {yylval.str = strdup(yytext); return TK_EQEQ;}
"<"                         {yylval.str = strdup(yytext); return TK_LT;}
">"                         {yylval.str = strdup(yytext); return TK_GT;}
"<="                        {yylval.str = strdup(yytext); return TK_LE;}
">="                        {yylval.str = strdup(yytext); return TK_GE;}
"!="                        {yylval.str = strdup(yytext); return TK_NEQ;}
"+"                         {yylval.str = strdup(yytext); return TK_PLUS;}
"-"                         {yylval.str = strdup(yytext); return TK_MINUS;}
"*"                         {yylval.str = strdup(yytext); return TK_MUL;}
"/"                         {yylval.str = strdup(yytext); return TK_DIV;}
"%"                         {yylval.str = strdup(yytext); return TK_MOD;}
"["                         {yylval.str = strdup(yytext); return TK_LBRACKET;}
"]"                         {yylval.str = strdup(yytext); return TK_RBRACKET;}
"("                         {yylval.str = strdup(yytext); return TK_LPARENTH;}
")"                         {yylval.str = strdup(yytext); return TK_RPARENTH;}
":"                         {yylval.str = strdup(yytext); return TK_COLON;}
"."                         {yylval.str = strdup(yytext); return TK_DOT;}
","                         {yylval.str = strdup(yytext); return TK_COMMA;}
";"                         {yylval.str = strdup(yytext); return TK_SEMIC;}
"="                         {yylval.str = strdup(yytext); return TK_EQ;}

"--"[^\n]*

[ \r\t]+
\n                          ++lineNum;

<<EOF>> {
    if(stack_top > 0) {
        yy_delete_buffer(YY_CURRENT_BUFFER);
        yy_switch_to_buffer(buf_stack[--stack_top]);
    } else {
        yyterminate();
    }
}

.                           { printf("Line %d Lexical Error: Unrecognized literal %s\n", lineNum, yytext); }

%%
