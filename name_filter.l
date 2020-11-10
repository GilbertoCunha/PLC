%{
#include <stdio.h>
#include <string.h>
#include "funcs.h"

int indice, aux_ind;
LNodo autores = NULL;
char autor[100];
char aux[100];
%}
%option noyywrap

%x AUTOR TITULO

%%
\ +(?i:author)\ *\=\ *(\{|\")\ *         { printf ("AUTOR$$"); BEGIN AUTOR; }
^\ +(?i:title)\ *\=\ *(\{|\")\ *         { printf ("TITULO$$"); BEGIN TITULO; }

<AUTOR>(\ |\n|\r|\t)+and(\ |\n|\r|\t)+   { 
    indice = -1;
    for (int i=0; autor[i]!='\0'; ++i) if (autor[i] == ',') indice = i;
    if (indice != -1) {
        strcat (aux, autor+indice+1);
        strcat (aux, " ");
        autor[indice] = '\0';
        strcat (aux, autor);
        strcpy (autor, aux);
    }
    acrescentaNodo (&autores, autor);  
    printf ("%s$$", autor);
    memset(autor, 0, strlen(autor)); 
    memset(aux, 0, strlen(aux));
}
<AUTOR>(\}|\")\,                         { 
    indice = -1;
    for (int i=0; autor[i]!='\0'; ++i) if (autor[i] == ',') indice = i;
    if (indice != -1) {
        strcat (aux, autor+indice+1);
        strcat (aux, " ");
        autor[indice] = '\0';
        strcat (aux, autor);
        strcpy (autor, aux);
    }
    acrescentaNodo (&autores, autor);  
    printf ("%s$},", autor); BEGIN INITIAL;
    memset(autor, 0, strlen(autor)); 
    memset(aux, 0, strlen(aux)); 
}
<AUTOR>(\n|\r|\t)                        { printf (" "); }
<AUTOR>\ *\,\ *                          { strcat (autor, ","); }
<AUTOR>P\.\ Rangel\ Henriques            { printf ("P.R. Henriques"); strcat (autor, "P.R. Henriques"); }
<AUTOR>Pedro\ Rangel\ Henriques          { printf ("P.R. Henriques"); strcat (autor, "P.R. Henriques"); }
<AUTOR>Pedro\ Rangel\ and\ Henriques     { printf ("P.R. Henriques"); strcat (autor, "P.R. Henriques"); }
<AUTOR>\ +                               { strcat (autor, " "); }
<AUTOR>.                                 { strcat (autor, yytext); }

<TITULO>(\}|\")\,                        { printf ("$},"); BEGIN INITIAL; }
<TITULO>(\n|\r|\t)                       { ; }
<TITULO>.                                { ECHO; }

(.|\n)                                   { ECHO; }
%%

int main () {
    FILE *f = fopen ("lista_autores.txt", "w");
    yylex();
    while (autores != NULL) {
        fprintf (f, "%s\n", autores->nome);
        autores = autores->prox;
    }
    fclose (f);
    return 0;
}