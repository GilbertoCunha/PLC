%{
#include <stdio.h>
%}
%option noyywrap

%x AUTOR

%%
\ +author\ *\=\ *(\{|\")\ *              { printf("AUTOR$$"); BEGIN AUTOR; }
<AUTOR>(\ |\n|\r|\t)+and(\ |\n|\r|\t)+   { printf ("$$"); }
<AUTOR>(\}|\")\,                         { printf ("$},"); BEGIN INITIAL; }
<AUTOR>(\n|\r|\t)                        { ; }
<AUTOR>.                                 { ECHO; }

(.|\n)                                   { ECHO; }
%%

int main () {
    yylex();
    return 0;
}