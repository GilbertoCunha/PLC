%{
#include <stdio.h>
#include <string.h>
#include <ctype.h>
#include "funcs.h"

LCat l = NULL;

%}


%x CATEGORIA CHAVE TITULO AUTORES AUTOR FIM

%%
\@                              { BEGIN CATEGORIA; }
<CATEGORIA>[^\{]+               { acrescenta(&l, str_to_lower(yytext)); }
<CATEGORIA>\{                   { BEGIN CHAVE; }

<CHAVE>[^\,]+                                  { ; }
<CHAVE>\,                                      { BEGIN INITIAL; }

<*>\ +author\ *\=\ *(\{|\")                    { BEGIN AUTORES; }
<AUTORES>((\ +and\ +)*.+)+(\}\,|\"\,)          { printf("nome:%s \n",yytext); BEGIN INITIAL;}




<*>\ +title\ *\=\ *(\{|\")      { BEGIN TITULO; }
<TITULO>([^\}\,]|[^\"\,])+      { BEGIN INITIAL;}

(.|\n)                  { ; }
%%

void ShowCat (LCat *l) {
    printf ("<h> Contagem de categorias </h>\n");
    printf ("<ol>\n");
    while (*l != NULL) {
        printf("\t<li> Nome: %s | Num_ocorr: %d </li>\n", (*l)->nome, (*l)->num_ocorr);
        l = &((*l)->prox);
    }
    printf ("</ol>\n");
}

int yywrap () {
    ShowCat (&l);
    return 1;
}

int main () {
    yylex();
    return 0;
}
