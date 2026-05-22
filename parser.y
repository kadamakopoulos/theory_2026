%{
    #include <stdio.h>
    #include "cgen.h"
    extern int yylex(void);

    extern FILE *yyget_in(void);
    extern int lineNum;
    #define YYERROR_VERBOSE

    int yylex(void);
    FILE * fp;

    int ca_count = 0; /* counter for compact array loop vars */
%}

%union {
    char* str;
}

%token <str> TK_GT
%token <str> TK_LT
%token <str> TK_GE
%token <str> TK_LE
%token <str> TK_NEQ
%token <str> TK_EQ
%token <str> TK_EQEQ
%token <str> TK_PLUSEQ
%token <str> TK_MINUSEQ
%token <str> TK_MULEQ
%token <str> TK_DIVEQ
%token <str> TK_MODEQ
%token <str> TK_AND
%token <str> TK_OR
%token <str> TK_NOT
%token <str> KW_RSTR
%token <str> KW_RINT
%token <str> KW_RSCALAR
%token <str> KW_WSTR
%token <str> KW_WINT
%token <str> KW_WSCALAR
%token <str> KW_WRITE
%token <str> TK_PLUS
%token <str> TK_MINUS
%token <str> TK_MUL
%token <str> TK_DIV
%token <str> TK_MOD
%token <str> TK_LBRACKET
%token <str> TK_RBRACKET
%token <str> TK_LPARENTH
%token <str> TK_RPARENTH
%token <str> TK_COLON
%token <str> TK_DOT
%token <str> TK_COMMA
%token <str> TK_SEMIC
%token <str> TK_ARROW
%token <str> TK_LARROW

%token <str> KW_INT
%token <str> KW_SCALAR
%token <str> KW_STR
%token <str> KW_BOOL
%token <str> KW_TRUE
%token <str> KW_FALSE
%token <str> KW_CONST
%token <str> KW_IF
%token <str> KW_ELSE
%token <str> KW_ENDIF
%token <str> KW_FOR
%token <str> KW_IN
%token <str> KW_ENDFOR
%token <str> KW_WHILE
%token <str> KW_ENDWHILE
%token <str> KW_BREAK
%token <str> KW_CONT
%token <str> KW_DEF
%token <str> KW_ENDDEF
%token <str> KW_MAIN
%token <str> KW_RETURN
%token <str> KW_COMP
%token <str> KW_ENDCOMP
%token <str> KW_OF

%token <str> TK_NUMBER
%token <str> TK_ID
%token <str> TK_REAL
%token <str> TK_CONST_STR
%token <str> TK_POW


%start input
%define parse.error detailed

%type <str> numericallExpr
%type <str> relationExpr
%type <str> logicExpr
%type <str> statements
%type <str> type
%type <str> expr
%type <str> decl
%type <str> funcDec
%type <str> typesumm
%type <str> args
%type <str> fArgs
%type <str> kW
%type <str> mStatments
%type <str> list
%type <str> defStatments
%type <str> recordDec
%type <str> recordBody
%type <str> compactArray


/* Operation Priorities */
%nonassoc TK_SEMIC
%right TK_EQ TK_PLUSEQ TK_MINUSEQ TK_MULEQ TK_DIVEQ TK_MODEQ
%left TK_OR
%left TK_AND
%right TK_NOT
%left TK_EQEQ TK_NEQ
%left TK_GT TK_LT TK_LE TK_GE
%left TK_PLUS TK_MINUS
%left TK_MUL TK_DIV TK_MOD
%right TK_POW
%left TK_LPARENTH TK_LBRACKET TK_DOT

%%
input:
    %empty
    |input list
    {
        printf("%s\n", $2);
        fprintf(fp,"%s\n", $2);
    }
    ;

list:
    expr TK_SEMIC
        { $$ = template("%s;", $1); }
    |statements
        { $$ = $1; }
    |funcDec
        { $$ = $1; }
    |recordDec
        { $$ = $1; }
    |decl TK_SEMIC
        { $$ = template("%s;", $1); }
    ;

/* ---- record (comp) declarations ---- */
recordDec:
    KW_COMP TK_ID TK_COLON recordBody KW_ENDCOMP TK_SEMIC
    {
        /* paragw typedef struct opws zitatai apo tin ekfonisi */
        $$ = template("typedef struct %s {\n%s} %s;\n", $2, $4, $2);
    }
    ;

recordBody:
    %empty
        { $$ = template(""); }
    |recordBody decl TK_SEMIC
        { $$ = template("%s    %s;\n", $1, $2); }
    |recordBody KW_DEF TK_ID TK_LPARENTH args TK_RPARENTH TK_ARROW type TK_COLON defStatments KW_RETURN expr TK_SEMIC KW_ENDDEF TK_SEMIC
        { $$ = template("%s    %s (*%s)(%s);\n", $1, $8, $3, $5); }
    |recordBody KW_DEF TK_ID TK_LPARENTH TK_RPARENTH TK_ARROW type TK_COLON defStatments KW_RETURN expr TK_SEMIC KW_ENDDEF TK_SEMIC
        { $$ = template("%s    %s (*%s)();\n", $1, $7, $3); }
    |recordBody KW_DEF TK_ID TK_LPARENTH args TK_RPARENTH TK_COLON defStatments KW_ENDDEF TK_SEMIC
        { $$ = template("%s    void (*%s)(%s);\n", $1, $3, $5); }
    |recordBody KW_DEF TK_ID TK_LPARENTH TK_RPARENTH TK_COLON defStatments KW_ENDDEF TK_SEMIC
        { $$ = template("%s    void (*%s)();\n", $1, $3); }
    ;

/* ---- read/write builtins ---- */


fArgs:
    expr
        { $$ = template("%s", $1); }
    |fArgs TK_COMMA expr
        { $$ = template("%s , %s", $1, $3); }
    ;

defStatments:
    %empty
        { $$ = template(""); }
    |defStatments statements
        { $$ = template("%s %s", $1, $2); }
    |defStatments decl TK_SEMIC
        { $$ = template("%s %s;", $1, $2); }
    ;

/* ---- compact array ---- */
compactArray:
    TK_ID TK_LARROW TK_LBRACKET expr KW_FOR TK_ID TK_COLON expr TK_RBRACKET TK_COLON type TK_SEMIC
    {
        /* arr <- [expr for elm:size] : type; */
        $$ = template("%s * %s = (%s*) malloc ( %s * sizeof ( %s ) ) ;\nfor ( int %s = 0 ; %s < %s ; ++%s ) { %s [ %s ] = %s ; }\n",
            $11, $1, $11, $8, $11,
            $6, $6, $8, $6,
            $1, $6, $4);
    }
    |TK_ID TK_LARROW TK_LBRACKET expr KW_FOR TK_ID TK_COLON type KW_IN TK_ID KW_OF expr TK_RBRACKET TK_COLON type TK_SEMIC
    {
        /* arr <- [expr for elm:type in array of size] : newtype; */
        char loopvar[64];
        sprintf(loopvar, "%s_i%d", $10, ca_count++);
        $$ = template("%s * %s = (%s*) malloc ( %s * sizeof ( %s ) ) ;\nfor ( int %s = 0 ; %s < %s ; ++%s ) { %s %s = %s [ %s ] ; %s [ %s ] = %s ; }\n",
            $15, $1, $15, $12, $15,
            loopvar, loopvar, $12, loopvar,
            $8, $6, $10, loopvar,
            $1, loopvar, $4);
    }
    ;

/* ---- function declarations ---- */
funcDec:
    KW_DEF TK_ID TK_LPARENTH args TK_RPARENTH TK_ARROW type TK_COLON defStatments KW_RETURN expr TK_SEMIC KW_ENDDEF TK_SEMIC
    {
        $$ = template("%s %s ( %s ) \n{ \n\t %s return %s ;} ", $7, $2, $4, $9, $11);
    }
    |KW_DEF TK_ID TK_LPARENTH args TK_RPARENTH TK_ARROW type TK_COLON defStatments KW_ENDDEF TK_SEMIC
    {
        $$ = template("%s %s ( %s ) \n{ \n\t %s} ", $7, $2, $4, $9);
    }

    |KW_DEF TK_ID TK_LPARENTH TK_RPARENTH TK_ARROW type TK_COLON defStatments KW_ENDDEF TK_SEMIC
    {
        $$ = template("%s %s ( ) \n{ \n\t %s} ", $6, $2, $8);
    }
    |KW_DEF TK_ID TK_LPARENTH args TK_RPARENTH TK_COLON defStatments KW_ENDDEF TK_SEMIC
    {
        $$ = template("void %s ( %s ) \n{ \n\t %s} ", $2, $4, $7);
    }
    |KW_DEF TK_ID TK_LPARENTH TK_RPARENTH TK_COLON defStatments KW_ENDDEF TK_SEMIC
    {
        $$ = template("void %s ( ) \n{ \n\t %s} ", $2, $6);
    }
    |KW_DEF KW_MAIN TK_LPARENTH TK_RPARENTH TK_COLON defStatments KW_ENDDEF TK_SEMIC
    {
        $$ = template("int main(int argc, char *argv[]) { \n %s \n} ", $6);
    }
    ;

args:
    TK_ID TK_LBRACKET TK_RBRACKET TK_COLON type
    {
        $$ = template("%s * %s", $5, $1);
    }
    |TK_ID TK_LBRACKET TK_NUMBER TK_RBRACKET TK_COLON type
    {
        $$ = template("%s * %s", $6, $1);
    }
    |TK_ID TK_COLON type
    {
        $$ = template("%s %s", $3, $1);
    }
    |args TK_COMMA args
    {
        $$ = template("%s , %s", $1, $3);
    }
    ;

kW:
    KW_RETURN expr TK_SEMIC
        { $$ = template("return %s ;", $2); free($2); }
    |KW_RETURN TK_SEMIC
        { $$ = template("return ;"); }
    |KW_CONT TK_SEMIC
        { $$ = template("continue ;"); }
    |KW_BREAK TK_SEMIC
        { $$ = template("break ;"); }
    ;

mStatments:
    %empty
        { $$ = template(""); }
    |mStatments statements
        { $$ = template("%s %s", $1, $2); }
    |mStatments compactArray
        { $$ = template("%s %s", $1, $2); }
    ;



statements:
    kW
        { $$ = $1; }
    |TK_ID TK_EQ expr TK_SEMIC
        { $$ = template("%s = %s ;", $1, $3); }
    |TK_ID TK_PLUSEQ expr TK_SEMIC
        { $$ = template("%s += %s ;", $1, $3); }
    |TK_ID TK_MINUSEQ expr TK_SEMIC
        { $$ = template("%s -= %s ;", $1, $3); }
    |TK_ID TK_MULEQ expr TK_SEMIC
        { $$ = template("%s *= %s ;", $1, $3); }
    |TK_ID TK_DIVEQ expr TK_SEMIC
        { $$ = template("%s /= %s ;", $1, $3); }
    |TK_ID TK_MODEQ expr TK_SEMIC
        { $$ = template("%s %%= %s ;", $1, $3); }
    |TK_ID TK_LBRACKET expr TK_RBRACKET TK_EQ expr TK_SEMIC
        { $$ = template("%s [ %s ] = %s ;", $1, $3, $6); }
    |KW_IF TK_LPARENTH expr TK_RPARENTH TK_COLON mStatments KW_ENDIF TK_SEMIC
        { $$ = template("if ( %s ) \n{ \n\t%s } ", $3, $6); }
    |KW_IF TK_LPARENTH expr TK_RPARENTH TK_COLON mStatments KW_ELSE TK_COLON mStatments KW_ENDIF TK_SEMIC
        { $$ = template("if ( %s ) \n{ \n\t%s } else \n{ \n\t%s } ", $3, $6, $9); }
    |KW_FOR TK_ID KW_IN TK_LBRACKET expr TK_COLON expr TK_RBRACKET TK_COLON mStatments KW_ENDFOR TK_SEMIC
        { $$ = template("for ( int %s = %s ; %s <= %s ; ++%s ) \n{ \n\t%s } ", $2, $5, $2, $7, $2, $10); }
    |KW_FOR TK_ID KW_IN TK_LBRACKET expr TK_COLON expr TK_COLON expr TK_RBRACKET TK_COLON mStatments KW_ENDFOR TK_SEMIC
        { $$ = template("for ( int %s = %s ; %s <= %s ; %s += %s ) \n{ \n\t%s } ", $2, $5, $2, $7, $2, $9, $12); }
    |KW_WHILE TK_LPARENTH expr TK_RPARENTH TK_COLON mStatments KW_ENDWHILE TK_SEMIC
        { $$ = template("while ( %s ) { %s } ", $3, $6); }
    |TK_ID TK_EQ KW_TRUE TK_SEMIC
        { $$ = template("%s = 1 ;", $1); }
    |TK_ID TK_EQ KW_FALSE TK_SEMIC
        { $$ = template("%s = 0 ;", $1); }
    |compactArray
        { $$ = $1; }
    |KW_WSTR TK_LPARENTH expr TK_RPARENTH TK_SEMIC
        { $$ = template("%s ( %s ) ;", $1, $3); }
    |KW_WINT TK_LPARENTH expr TK_RPARENTH TK_SEMIC
        { $$ = template("%s ( %s ) ;", $1, $3); }
    |KW_WSCALAR TK_LPARENTH expr TK_RPARENTH TK_SEMIC
        { $$ = template("%s ( %s ) ;", $1, $3); }
    |KW_WRITE TK_LPARENTH fArgs TK_RPARENTH TK_SEMIC
        { $$ = template("write ( %s ) ;", $3); }
    |TK_ID TK_LPARENTH TK_RPARENTH TK_SEMIC
        { $$ = template("%s ( ) ;", $1); }
    |TK_ID TK_LPARENTH fArgs TK_RPARENTH TK_SEMIC
        { $$ = template("%s ( %s ) ;", $1, $3); }
    ;

decl:
    TK_ID TK_LBRACKET TK_NUMBER TK_RBRACKET TK_COLON type
        { $$ = template("%s %s [ %s ]", $6, $1, $3); }
    |TK_ID TK_COLON type
        { $$ = template("%s %s", $3, $1); }
    |TK_ID TK_LBRACKET TK_RBRACKET TK_COLON type
        { $$ = template("%s * %s", $5, $1); }
    |TK_ID TK_COMMA decl
        { $$ = template("%s , %s", $3, $1); }
    |KW_CONST TK_ID TK_EQ expr TK_COLON type
        { $$ = template("const %s %s = %s", $6, $2, $4); }
    ;

expr:
    logicExpr
        { $$ = $1; }
    |numericallExpr
        { $$ = $1; }
    |relationExpr
        { $$ = $1; }
    ;

relationExpr:
    expr TK_GE expr
        { $$ = template("%s >= %s", $1, $3); }
    |expr TK_GT expr
        { $$ = template("%s > %s", $1, $3); }
    |expr TK_LE expr
        { $$ = template("%s <= %s", $1, $3); }
    |expr TK_LT expr
        { $$ = template("%s < %s", $1, $3); }
    |expr TK_NEQ expr
        { $$ = template("%s != %s", $1, $3); }
    |expr TK_EQEQ expr
        { $$ = template("%s == %s", $1, $3); }
    ;

logicExpr:
    expr TK_AND expr
        { $$ = template("%s && %s", $1, $3); }
    |expr TK_OR expr
        { $$ = template("%s || %s", $1, $3); }
    |TK_NOT expr
        { $$ = template("! %s", $2); }
    ;

numericallExpr:
    typesumm
        { $$ = $1; }
    |expr TK_PLUS expr
        { $$ = template("%s + %s", $1, $3); }
    |expr TK_MINUS expr
        { $$ = template("%s - %s", $1, $3); }
    |expr TK_MUL expr
        { $$ = template("%s * %s", $1, $3); }
    |expr TK_DIV expr
        { $$ = template("%s / %s", $1, $3); }
    |expr TK_MOD expr
        { $$ = template("%s %% %s", $1, $3); }
    |expr TK_POW expr
        { $$ = template("pow ( %s , %s )", $1, $3); }
    |TK_LPARENTH expr TK_RPARENTH
        { $$ = template("( %s )", $2); }
    |TK_MINUS expr
        { $$ = template("- %s", $2); }
    ;

typesumm:
    TK_NUMBER    { $$ = $1; }
    |TK_ID       { $$ = $1; }
    |TK_REAL     { $$ = $1; }
    |KW_TRUE     { $$ = $1; }
    |KW_FALSE    { $$ = $1; }
    |TK_CONST_STR { $$ = $1; }
    |TK_ID TK_LBRACKET expr TK_RBRACKET
        { $$ = template("%s [ %s ]", $1, $3); }
    |TK_ID TK_DOT TK_ID
        { $$ = template("%s . %s", $1, $3); }
    |TK_ID TK_DOT TK_ID TK_LPARENTH TK_RPARENTH
        { $$ = template("%s . %s ( )", $1, $3); }
    |TK_ID TK_DOT TK_ID TK_LPARENTH fArgs TK_RPARENTH
        { $$ = template("%s . %s ( %s )", $1, $3, $5); }
    |TK_ID TK_LPARENTH TK_RPARENTH
        { $$ = template("%s ( )", $1); }
    |TK_ID TK_LPARENTH fArgs TK_RPARENTH
        { $$ = template("%s ( %s )", $1, $3); }
    |KW_RSTR TK_LPARENTH TK_RPARENTH
        { $$ = template("%s ( )", $1); }
    |KW_RSCALAR TK_LPARENTH TK_RPARENTH
        { $$ = template("%s ( )", $1); }
    |KW_RINT TK_LPARENTH TK_RPARENTH
        { $$ = template("%s ( )", $1); }
    |KW_WSTR TK_LPARENTH expr TK_RPARENTH
        { $$ = template("%s ( %s )", $1, $3); }
    |KW_WINT TK_LPARENTH expr TK_RPARENTH
        { $$ = template("%s ( %s )", $1, $3); }
    |KW_WSCALAR TK_LPARENTH expr TK_RPARENTH
        { $$ = template("%s ( %s )", $1, $3); }
    |KW_WRITE TK_LPARENTH fArgs TK_RPARENTH
        { $$ = template("write ( %s )", $3); }
    ;

type:
    KW_SCALAR  { $$ = template("double"); }
    |KW_INT    { $$ = template("int"); }
    |KW_STR    { $$ = template("StringType"); }
    |KW_BOOL   { $$ = template("int"); }
    |TK_ID     { $$ = template("%s", $1); }
    ;

%%
int main ()
{
    fp = fopen("parser.c","w");
    fprintf(fp, "#include \"kappalib.h\"\n");
    int result = yyparse();
    if ( result == 0 )
        printf("Accepted!\n");
    else
        printf("Rejected!\n");

    fclose(fp);
    return result;
}
