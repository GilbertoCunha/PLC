#include <stdio.h>
#include <string.h>
#include <ctype.h>
#include <stdlib.h>
#include "funcs.h"

void swapcomma (char autor[]) {
    char aux[100];
    int indice = -1;
    for (int i=0; autor[i]!='\0'; ++i) if (autor[i] == ',') indice = i;
    if (indice != -1) {
        strcat (aux, autor+indice+1);
        strcat (aux, " ");
        autor[indice] = '\0';
        strcat (aux, autor);
        strcpy (autor, aux);
    }
}

char *str_to_lower (char *s) {
    for (int i=0; i<strlen(s); ++i) s[i] = tolower(s[i]);

    return s;
}

void ShowLStr (LStr *l) {
    while ((*l) != NULL && (*l)->prox != NULL) {
        printf ("%s -> ", (*l)->nome);
        l = &((*l)->prox);
    }
    if ((*l) != NULL) printf ("%s\n", (*l)->nome);
}

void acrescentaLStr (LStr *l, char *s) {
    while ((*l) != NULL) l = &((*l)->prox);

    (*l) = malloc (sizeof (struct slist));
    (*l)->nome = strdup (s);
    (*l)->prox = NULL;
}

void ShowProj (LProj *p) {
    while ((*p) != NULL) {
        printf ("Chave: %s\n", (*p)->chave);
        printf ("Título: %s\n", (*p)->titulo);
        printf ("Autores: ");
        ShowLStr (&((*p)->autores));
        printf ("\n");
        p = &((*p)->prox);
    }
}

void copiaLStr (LStr *source, LStr *dest) {
    *dest = NULL;
    while (*source != NULL) {
        (*dest) = malloc (sizeof (struct slist));
        (*dest)->nome = (*source)->nome;
        (*dest)->prox = NULL;
        source = &((*source)->prox);
        dest = &((*dest)->prox);
    }
    *dest = NULL;
}

void acrescentaProj (LProj *p, char *chave, char *titulo, LStr autores) {
    while (*p != NULL) p = &((*p)->prox);

    (*p) = malloc (sizeof (struct projeto));
    (*p)->chave = strdup (chave);
    (*p)->titulo = strdup (titulo);
    (*p)->autores = autores;
    (*p)->prox = NULL;
}

void acrescentaNodo(LNodo *n, char *nome) {
    while (*n != NULL && strcmp((*n)->nome, nome) != 0) n = &((*n)->prox);

    if(*n == NULL){
        (*n) = malloc(sizeof(struct nodo));
        (*n)->nome = strdup(nome);
        (*n)->num_ocorr = 0;
        (*n)->prox = NULL;
    }
    (*n)->num_ocorr++;
}

void initGraph (Graph *g, char *nome) {
    *g = malloc (sizeof (struct agraph));
    (*g)->nome = strdup (nome);
    (*g)->autores = NULL;
}

void acrescentaAut (LAut *a, char *name, char *pub) {
    while (*a != NULL && strcmp((*a)->nome, name) != 0) a = &((*a)->prox);

    if (*a == NULL) {
        (*a) = malloc (sizeof (struct autor));
        (*a)->nome = strdup (name);
        (*a)->prox = NULL;
    }
    acrescentaLStr (&((*a)->public), pub);
}


void copiaLProj (LProj *source, LProj *dest) {
    while (*dest != NULL) dest = &((*dest)->prox);
    while (*source != NULL) {
        *dest = malloc (sizeof (struct projeto));
        (*dest)->chave = (*source)->chave;
        (*dest)->titulo = (*source)->titulo;
        copiaLStr (&((*source)->autores), &((*dest)->autores));
        (*dest)->prox = NULL;
        source = &((*source)->prox);
        dest = &((*dest)->prox);
    }
    *dest = NULL;
}

void acrescentaCat (LCat *l, char *s, LProj p) {
    while (*l != NULL && strcmp((*l)->nome, s) < 0)
        l = &((*l)->prox);
    
    if (*l == NULL) {
        *l = malloc (sizeof (struct categoria));
        (*l)->nome = strdup (s);
        (*l)->num_ocorr = 1;
        copiaLProj (&p, &((*l)->projeto));
        (*l)->prox = NULL;
    }
    else if (strcmp ((*l)->nome, s) == 0) {
        (*l)->num_ocorr++;
        copiaLProj (&p, &((*l)->projeto));
    }
    else {
        LCat new = malloc (sizeof (struct categoria));
        new->nome = strdup (s);
        new->num_ocorr = 1;
        copiaLProj (&p, &(new->projeto));
        new->prox = *l;
        *l = new;
    }
}

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

void ShowGraph (Graph *grafo, char *path) {
    LNodo *aux = &((*grafo)->autores);
    FILE *file = fopen(path, "w");
    fprintf (file, "digraph G {\n");
    fprintf (file, "\tlayout = fdp;\n");
    int num = 1;
    while (*aux != NULL){
        fprintf (file,"\t%d -> %d;\n", 0, num++);
        aux = &((*aux)->prox);
    }
    aux = &((*grafo)->autores);
    fprintf (file,"\t%d [label=\"%s\", pos=\"0,0!\"];\n", 0,(*grafo)->nome);
    num = 1;
    while (*aux != NULL){
        fprintf (file, "\t%d [label=\"%s\n%d em comum\"];\n", num++,(*aux)->nome, (*aux)->num_ocorr);
        aux = &((*aux)->prox);
    }
    fprintf (file,"}");
    fclose(file);
}