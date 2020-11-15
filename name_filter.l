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

<AUTOR>((\ |\n|\r|\t)+and(\ |\n|\r|\t)+|\ and\ and\ )   {
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
    int num_nomes;
    int num_chars;
    FILE *f = fopen ("lista_autores.txt", "w");
    yylex();
    fprintf (f, "\n\nLISTA DE AUTORES\n\n");
    while (autores != NULL) {
        for (num_nomes=0; num_nomes<3 && autores != NULL; ++num_nomes) {
            for (int i=0; autores->nome[i]!='\0'; ++i) fprintf (f, "%c", autores->nome[i]);
            for (num_chars=strlen(autores->nome); num_chars<40; ++num_chars) fprintf (f, " ");
            autores = autores->prox;
        }
        fprintf (f, "\n");
    }
    fclose (f);
    return 0;
}