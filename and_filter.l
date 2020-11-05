%{
#include <stdio.h>
%}
%option noyywrap

%s AUTOR

%%
\ +author\ *\=\ *(\{|\")           { printf("AUTOR$$"); BEGIN AUTOR; }
<AUTOR>\ +and\ +                   { printf ("$$"); }
<AUTOR>(\}|\")\,                   { printf ("$},"); BEGIN INITIAL; }

(.|\n)                             { ECHO; }
%%

int main () {
    yylex();
    return 0;
}