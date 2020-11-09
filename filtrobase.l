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
    initGraph (&grafo, "Nuno Oliveira");
    LStr *sitio = &a;
    while (*sitio != NULL && strcmp((*sitio)->nome, grafo->nome) != 0) sitio = &((*sitio)->prox);
    if (*sitio != NULL) {
        sitio = &a;
        while(*sitio!=NULL){
            if (strcmp((*sitio)->nome,grafo->nome) != 0) acrescentaNodo(&(grafo->autores), (*sitio)->nome);
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

int contaPubs (LStr *a) {
    int r = 0;

    while (*a != NULL) {
        a = &((*a)->prox);
        r += 1;
    }

    return r;
}

void ShowAut (LAut *a) {
    while ((*a) != NULL) {
        printf ("\t\t<h1><b> %s </b> - %d Publicações\n", (*a)->nome, contaPubs (&((*a)->public)));

        LStr *sitio = &((*a)->public);
        while (*sitio != NULL) {
            printf ("\t\t\t<ul> %s </ul>\n", (*sitio)->nome);
            sitio = &((*sitio)->prox);
        }
        printf ("\n");
        a = &((*a)->prox);
    }
}

void ShowGraph (Graph *grafo){
    file = fopen("graph.dot","w");
    fprintf (file,"grafo = {\n");
    while ((*grafo)->autores != NULL){
        fprintf(file,"\t%s -> %s\n",(*grafo)->nome,(*grafo)->autores->nome);
        (*grafo)->autores = (*grafo)->autores->prox;
    } 
    fprintf (file,"}");
    fclose(file);
}

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
    ShowGraph (&grafo);
    
    printf ("\t</body>\n");
    printf ("</html>\n");

    return 1;
}

int main () {
    yylex();
    return 0;
}
