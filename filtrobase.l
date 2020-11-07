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
<CATEGORIA>[^\{]+                    { nome = strdup (str_to_lower (yytext)); }
<CATEGORIA>\{                        { BEGIN CHAVE; }
<DENTRO>\n\ *\}                      { acrescentaProj (&p, chave, titulo, a); acrescentaCat (&l, nome, p); BEGIN INITIAL; p = NULL; a = NULL; }

<CHAVE>[^\,]+                        { chave = strdup (yytext); }
<CHAVE>\,                            { BEGIN DENTRO; }

<DENTRO>AUTOR\$                      { BEGIN AUTORES; }
<AUTORES>\}\,                        { BEGIN DENTRO; }
<AUTORES>\$[^\$]+\$                  { yytext[strlen(yytext)-1] = '\0'; acrescentaLStr (&a, yytext+1); }

<DENTRO>^\ *title\ *\=\ *            { BEGIN TITULO; }
<TITULO>\"[^\"]+?\"\,                { titulo = strdup (yytext); BEGIN DENTRO; }
<TITULO>\{[^\}]+?\}\,                { titulo = strdup (yytext); BEGIN DENTRO; }

<*>(.|\n)                            { ; }
%%

void ShowCat (LCat *l) {
    while (*l != NULL) {
        printf("\t\t<h1> <b> Categoria %s</b> - %d ocorrências </h1>\n", (*l)->nome, (*l)->num_ocorr);

        LProj *sitio = &((*l)->projeto);
        while (*sitio != NULL) {
            printf ("\t\t\t<h3> Título: %s </h3>\n", (*sitio)->titulo);
            printf ("\t\t\t\t<ul> Chave: %s </ul>\n", (*sitio)->chave);
            printf ("\t\t\t\t<ul> Autores: ");

            LStr *sitio2 = &((*sitio)->autores);
            while (*sitio2 != NULL && (*sitio2)->prox != NULL) {
                printf ("%s and ", (*sitio2)->nome);
                sitio2 = &((*sitio2)->prox);
            }
            if ((*sitio2) != NULL) printf ("%s", (*sitio2)->nome);
            printf (" </ul>\n\n");
            sitio = &((*sitio)->prox); 
        }

        l = &((*l)->prox);
    }
}

int contaTitulos (LProj *p) {
    int r = 0;
    while (*p != NULL) {
        r += 1;
        p = &((*p)->prox);
    }
    return r;
}

int yywrap () {
    LCat *sitio = &l;
    while (*sitio != NULL) {
        printf ("A categoria %s tem %d títulos\n", (*sitio)->nome, contaTitulos (&((*sitio)->projeto)));
        sitio = &((*sitio)->prox);
    }

    printf ("<!DOCTYPE html>\n");
    printf ("<html>\n");
    printf ("\t<head>\n");
    printf ("\t\t<title> Trabalho 1 </title>\n");
    printf ("\t\t<meta charset=\"UTF-8\" >\n");
    printf ("\t</head>\n");
    printf ("\t<body>\n");
    
    ShowCat (&l);
    
    printf ("\t</body>\n");
    printf ("</html>\n");
    return 1;
}

int main () {
    yylex();
    return 0;
}
