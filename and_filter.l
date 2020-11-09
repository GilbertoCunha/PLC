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
    memset(autor, 0, strlen(autor)); 
    memset(aux, 0, strlen(aux)); 
    printf ("$$"); 
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
    memset(autor, 0, strlen(autor)); 
    memset(aux, 0, strlen(aux));
    printf ("$},"); BEGIN INITIAL; 
}
<AUTOR>Daniela\nda                       { printf (" "); }
<AUTOR>(\n|\r|\t)                        { printf (" "); }
<AUTOR>\ *\,\ *                          { printf (","); strcat (autor, ","); }
<AUTOR>\ +                               { printf (" "); strcat (autor, " "); }
<AUTOR>.                                 { ECHO; strcat (autor, yytext); }

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