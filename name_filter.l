%{
#include <stdio.h>
#include <string.h>
#include "funcs.h"

LNodo autores = NULL;
char autor[100];
char aux[100];
%}
%option noyywrap

%x AUTOR TITULO

%%
^\ +(?i:author)\ *\=\ *(\{|\")\ *        { printf ("AUTOR$$"); BEGIN AUTOR; }
^\ +(?i:title)\ *\=\ *(\{|\")\ *         { printf ("TITULO$$"); BEGIN TITULO; }

<AUTOR>([\ \n\r\t]+and[\ \n\r\t]+|(\ and)+\ )   {
    swap_comma (autor, aux);
    acrescentaNodo (&autores, autor);  
    printf ("%s$$", autor);
    memset(autor, 0, strlen(autor));
}
<AUTOR>\ *(\}|\")\,                         {
    swap_comma (autor, aux);
    acrescentaNodo (&autores, autor);  
    printf ("%s$},", autor); BEGIN INITIAL;
    memset(autor, 0, strlen(autor));
}
<AUTOR>(M�rio\ B�ron|Mario\ B�ron|Mario\ Ber�n) { strcat (autor, "Mario Beron"); }
<AUTOR>(\n|\r|\t)+\ *                           { strcat (autor, " "); }
<AUTOR>\ *\,\ *                                 { strcat (autor, ","); }
<AUTOR>�                                        { strcat (autor, "?"); }
<AUTOR>(\{|\}|\\\'|\\\~|\\\^|\\\")              { ; }
<AUTOR>\ +                                      { strcat (autor, " "); }
<AUTOR>.                                        { strcat (autor, yytext); }

<TITULO>(\}|\")\,                        { printf ("$},"); BEGIN INITIAL; }
<TITULO>(\n|\r|\t)                       { ; }
<TITULO>.                                { ECHO; }

(.|\n)                                   { ECHO; }
%%

int main () {
    FILE *f = fopen ("lista_autores.txt", "w");
    yylex();
    ShowAuthorTable(f, autores);
    fclose (f);
    return 0;
}