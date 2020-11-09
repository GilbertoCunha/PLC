%{
#include <stdio.h>
#include <string.h>
#include <ctype.h>
#include "funcs.h"

FILE *file;
LCat l = NULL;
LProj p = NULL;
LStr a = NULL;
LAut autores = NULL;
char *nome;
char *chave;
char *titulo;
Graph grafo = NULL;
%}

%x CATEGORIA CHAVE AUTORES AUTOR FIM TITULO
%x DENTRO

LETRAS [a-zA-Z\,\.\ ]

%%
\@                                   { BEGIN CATEGORIA; }
<CATEGORIA>[^\{]+                    { nome = strdup (str_to_lower (yytext)); }
<CATEGORIA>\{                        { BEGIN CHAVE; }
<DENTRO>\n\ *\}                      { 
    acrescentaProj (&p, chave, titulo, a); 
    acrescentaCat (&l, nome, p);

    LStr *sitio = &a;
    while (*sitio != NULL && strcmp((*sitio)->nome, grafo->nome) != 0) sitio = &((*sitio)->prox);
    if (*sitio != NULL) {
        sitio = &a;
        while(*sitio!=NULL){
            if (strcmp((*sitio)->nome,grafo->nome) != 0) acrescentaNodo (&(grafo->autores), (*sitio)->nome);
            sitio = &((*sitio)->prox);
        }
    }
    while (a != NULL) {
        acrescentaAut (&autores, a->nome, titulo);
        a = a->prox;
    }

    BEGIN INITIAL; p = NULL; 
}

<CHAVE>[^\,]+                        { chave = strdup (yytext); }
<CHAVE>\,                            { BEGIN DENTRO; }

<DENTRO>AUTOR\$                      { BEGIN AUTORES; }
<AUTORES>\}\,                        { BEGIN DENTRO; }
<AUTORES>\$[^\$]+\$                  { yytext[strlen(yytext)-1] = '\0'; acrescentaLStr (&a, yytext+1); }

<DENTRO>TITULO\$                     { BEGIN TITULO; }
<TITULO>\$[^\$]+\$                   { yytext[strlen(yytext)-1] = '\0'; titulo = strdup (yytext+1); BEGIN DENTRO; }

<*>(.|\n)                            { ; }
%%

int yywrap () {
    printf ("<!DOCTYPE html>\n");
    printf ("<html>\n");
    printf ("\t<head>\n");
    printf ("\t\t<title> Trabalho 1 </title>\n");
    printf ("\t\t<meta charset=\"UTF-8\" >\n");
    printf ("\t</head>\n");
    printf ("\t<body>\n");
    
    ShowCat (&l);
    ShowAut (&autores);
    ShowGraph (&grafo, "graph.dot");
    
    printf ("\t</body>\n");
    printf ("</html>\n");

    return 1;
}

int main (int argc, char **argv) {
    printf ("%s\n", argv[1]);
    initGraph (&grafo, argv[1]);
    yylex();

    return 0;
}
