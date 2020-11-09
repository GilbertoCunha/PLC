%{
#include <stdio.h>
#include <string.h>
%}
%option noyywrap

%%

Danielada                  { printf ("Daniela da"); }
(.|\n)                     { ECHO; }

%%

int main () {
    yylex ();
    return 0;
}