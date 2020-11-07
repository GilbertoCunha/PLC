%{
#include <stdio.h>
%}
%option noyywrap

%x AUTOR TITULO

%%
\ +(?i:author)\ *\=\ *(\{|\")\ *         { printf ("AUTOR$$"); BEGIN AUTOR; }
^\ +(?i:title)\ *\=\ *(\{|\")\ *         { printf ("TITULO$$"); BEGIN TITULO; }

<AUTOR>(\ |\n|\r|\t)+and(\ |\n|\r|\t)+   { printf ("$$"); }
<AUTOR>(\}|\")\,                         { printf ("$},"); BEGIN INITIAL; }
<AUTOR>(\n|\r|\t)                        { ; }
<AUTOR>.                                 { ECHO; }

<TITULO>(\}|\")\,                        { printf ("$},"); BEGIN INITIAL; }
<TITULO>(\n|\r|\t)                       { ; }
<TITULO>.                                { ECHO; }

(.|\n)                                   { ECHO; }
%%

int main () {
    yylex();
    return 0;
}