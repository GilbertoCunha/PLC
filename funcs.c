#include <stdio.h>
#include <string.h>
#include <ctype.h>
#include <stdlib.h>
#include "funcs.h"

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
