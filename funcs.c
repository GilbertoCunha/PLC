#include <stdio.h>
#include <string.h>
#include <ctype.h>
#include <stdlib.h>
#include "funcs.h"

char *str_to_lower (char *s) {
    for (int i=0; i<strlen(s); ++i) s[i] = tolower(s[i]);

    return s;
}

void ShowLStr (LStr *l) {
  while ((*l) != NULL) {
    printf ("Nome: %s\n", (*l)->nome);
    l = &((*l)->prox);
  }
}

void acrescentaLStr (LStr *l, char *s) {
  while ((*l) != NULL) l = &((*l)->prox);
  
  (*l) = malloc (sizeof (struct slist));
  (*l)->nome = strdup (s);
  (*l)->prox = NULL;
}

void acrescentaProj (LProj *p, char *chave, char *titulo, LStr autores) {
    while (*p != NULL) p = &((*p)->prox);

    (*p) = malloc (sizeof (struct projeto));
    (*p)->chave = strdup (chave);
    (*p)->titulo = strdup (titulo);
    (*p)->autores = autores;
    (*p)->prox = NULL;
}

void acrescentaCat (LCat *l, char *s) {
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

/*
int main () {
    LStr nomes = NULL;
    acrescentaLStr (&nomes, "hello");
    acrescentaLStr (&nomes, "bye");
    ShowLStr (&nomes);

    return 0;
}
*/