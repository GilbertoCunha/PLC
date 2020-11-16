%{
#include <stdio.h>
#include <string.h>
#include <ctype.h>
#include "funcs.h"

FILE *file;
LCat l = NULL; LProj p = NULL; LStr a = NULL;
LAut autores = NULL; Graph grafo = NULL;
char *nome, *chave, *titulo;
%}

%option noyywrap
%x CATEGORIA DENTRO CHAVE AUTORES TITULO

%%
\@                                   { BEGIN CATEGORIA; }
<CATEGORIA>[^\{]+                    { nome = strdup (str_to_lower (yytext)); }
<CATEGORIA>\{                        { BEGIN CHAVE; }
<DENTRO>[\n\r]\ *\}                  { 
    acrescentaProj (&p, chave, titulo, a); 
    acrescentaCat (&l, nome, p);
    acrescentaGrafo (grafo, a);
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

int main (int argc, char **argv) {
    initGraph (&grafo, argv[1]);
    yylex();

    if (strcmp(argv[2], "html") == 0) {
        printHTMLstart ();
        
        ShowGraph (&grafo, "graph.dot");
        system("dot -Kfdp -Tpng -Goverlap=false -Gsplines=true graph.dot > graph.png");

        printf ("<div id=\"Categorias\" class=\"tabcontent\">\n");
        ShowCat (&l);
        printf ("</div>\n");
        printf ("<div id=\"Autores\" class=\"tabcontent\">\n");
        ShowAut (&autores);
        printf ("</div>\n");
        printf ("<div id=\"Grafo\" class=\"tabcontent\">\n");
        printf ("<img src=\"graph.png\" alt=\"Grafo dos autores em comum de %s\"", argv[1]);
        printf ("width=\"600\" class=\"center\">\n");
        printf ("</div>\n");
        
        printHTMLend ();
    }
    else if (strcmp(argv[2], "index") == 0) {
        FILE *f = fopen ("author.txt", "w");
        while (autores != NULL && strcmp(autores->nome, argv[1]) != 0) autores = autores->prox;
        if (autores != NULL) {
            autores->prox = NULL;
            ShowAutF (&autores, f);
        }
        else fprintf (f, "\nERROR: This author can't be found in the specified file\n");
        fclose (f);
    }

    return 0;
}
