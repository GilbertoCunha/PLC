%{
#include <stdio.h>
%}
%option noyywrap

%x AUTOR

%%
\ +author\ *\=\ *(\{|\")    { printf("AUTOR$"); BEGIN AUTOR; }
<AUTOR>\ +and\ +            { printf ("$$"); }
<AUTOR>[^\n]+(\}\,|\"\,)    { printf ("$},"); BEGIN INITIAL; }
<AUTOR>.+                   { ECHO; }
(.|\n)                      { ECHO; }
%%

int main () {
    yylex();
    return 0;
}