#include <assert.h>
#include <stdarg.h>
#include <stdio.h>
#include <string.h>

#include "cgen.h"

//o arithmos grammes gia ta minimata sfalmatos
extern int lineNum;

//anoigei ena string stream sti mnimi - xrisimopoieitai apo tin template() 
void ssopen(sstream *S) { S->stream = open_memstream(&S->buffer, &S->bufsize); }

//epistrefei to periexomeno tou stream ws string 
char *ssvalue(sstream *S) {
  fflush(S->stream);
  return S->buffer;
}

//kleinei to stream otan teleiwnei i xrisi tou 
void ssclose(sstream *S) { fclose(S->stream); }

//antikathistai ena xaraktira me allon mesa se string - den to xrisimopoiw polu
char *replaceChar(char* const source, char toBeReplaced, char replacer) {
	for (int i = 0; i < strlen(source); ++i) {
		if (source[i] == toBeReplaced) {
			source[i] = replacer;
		}
	}
	return source;
}

//i pio simantiki synartisi - doulevei san printf alla epistrefei string
//tin xrisimopoiw se kathe kanona tou parser gia na xtizomai ton C kwdika 
char *template(const char *pat, ...) {
  sstream S;
  ssopen(&S);

  va_list arg;
  va_start(arg, pat);
  vfprintf(S.stream, pat, arg);
  va_end(arg);

  char *ret = ssvalue(&S);
  ssclose(&S);
  return ret;
}

/*
        Report errors
*/
//emfanizei minima sfalmatos me ton arithmo gramis
//kaleitai automatika apo ton parser otan vriskei syntaktiko lathos
void yyerror(char const *pat, ...) {
  va_list arg;
  fprintf(stderr, "line %d: ", lineNum);

  va_start(arg, pat);
  vfprintf(stderr, pat, arg);
  va_end(arg);

  fprintf(stderr, "\n");

  yyerror_count++;
}

//metraei poses fores klithike i yyerror - an > 0 to programma exei lathi 
int yyerror_count = 0;

//to proto pragma pou grafetai sto paragomeno C arxeio 
const char *c_prologue =
    "#include \"kappalib.h\"\n"
    "\n";
