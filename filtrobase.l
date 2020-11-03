%{
#include <stdio.h>
#include <string.h>
#include <ctype.h>

typedef struct categoria {
    char *nome;
    int num_ocorr;
    struct categoria *prox;
} *LCat;

char *str_to_lower (char *s) {
    for (int i=0; i<strlen(s); ++i) s[i] = tolower(s[i]);

    return s;
}

void acrescenta (LCat *l, char *s) {
    while (*l != NULL && strcmp((*l)->nome, s) < 0)
        l = &((*l)->prox);
    
    if (*l == NULL) {
        *l = malloc (sizeof (struct categoria));
        (*l)->nome = strdup (s);
        (*l)->num_ocorr = 1;
        (*l)->prox = NULL;
    }
    else if (strcmp ((*l)->nome, s) == 0) (*l)->num_ocorr++;
    else {
        LCat new = malloc (sizeof (struct categoria));
        new->nome = strdup (s);
        new->num_ocorr = 1;
        new->prox = *l;
        *l = new;
    }
}

LCat l = NULL;

%}


%x CATEGORIA

%%
\@                      { BEGIN CATEGORIA; }
<CATEGORIA>\{           { BEGIN INITIAL; }
<CATEGORIA>[^\{]+       { acrescenta(&l, str_to_lower(yytext)); }

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