%{
#include <stdio.h>
#include <string.h>
#include <ctype.h>
#include "funcs.h"

LCat l = NULL;
LProj p = NULL;
LStr a = NULL;
char *nome;
char *chave;
char *titulo;
%}

%x CATEGORIA CHAVE AUTORES AUTOR FIM TITULO
%x DENTRO

LETRAS [a-zA-Z\,\.\ ]

%%
\@                                   { BEGIN CATEGORIA; }
<CATEGORIA>[^\{]+                    { nome = strdup (yytext); acrescentaCat (&l, str_to_lower(yytext)); }
<CATEGORIA>\{                        { BEGIN CHAVE; }
<DENTRO>\n\ *\}                      { ShowLStr (&a); BEGIN INITIAL; p = NULL; a = NULL; }

<CHAVE>[^\,]+                        { chave = strdup (yytext); }
<CHAVE>\,                            { BEGIN DENTRO; }

<DENTRO>AUTOR\$                      { BEGIN AUTORES; }
<AUTORES>\$[^\$]+?\$                 { acrescentaLStr (&a, yytext+1); }
<AUTORES>\}\,                        { BEGIN DENTRO; }

<DENTRO>^\ *title\ *\=\ *            { BEGIN TITULO; }
<TITULO>\"[^\"]+?\"\,                { titulo = strdup (yytext); BEGIN DENTRO; }
<TITULO>\{[^\}]+?\}\,                { titulo = strdup (yytext); BEGIN DENTRO; }

<*>(.|\n)                            { ; }
%%

void ShowCat (LCat *l) {
    printf ("\t\t<h> Contagem de categorias </h>\n");
    printf ("\t\t<ol>\n");
    while (*l != NULL) {
        printf("\t\t\t<li> Nome: %s | Num_ocorr: %d </li>\n", (*l)->nome, (*l)->num_ocorr);
        l = &((*l)->prox);
    }
    printf ("\t\t</ol>\n");
}

int yywrap () {
    ShowCat (&l);
    return 1;
}

int main () {
    yylex();
    return 0;
}
