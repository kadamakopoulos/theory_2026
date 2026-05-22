// kappalib.h - standard library for Kappa language
#ifndef KAPPALIB_H
#define KAPPALIB_H

#include <math.h>
#include <stdarg.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

typedef char* StringType;

#define writeText(x)    printf("%s", (x))
#define writeInt(x)     printf("%d", (x))
#define writeReal(x)    printf("%g", (x))

void write(char const* pat, ...) {
    va_list arg;
    va_start(arg, pat);
    vfprintf(stdout, pat, arg);
    va_end(arg);
}

char* strdup(const char*);

#define BUFSIZE 1024
char* readText() {
    char buffer[BUFSIZE];
    buffer[0] = '\0';
    fgets(buffer, BUFSIZE, stdin);
    int blen = strlen(buffer);
    if (blen > 0 && buffer[blen-1] == '\n') buffer[blen-1] = '\0';
    return strdup(buffer);
}
#undef BUFSIZE

int readInt() { return atoi(readText()); }
double readReal() { return atof(readText()); }

#endif
