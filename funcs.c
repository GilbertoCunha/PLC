#include <stdio.h>
#include <string.h>
#include <ctype.h>
#include <stdlib.h>
#include "funcs.h"

void swap_comma (char nome[], char a[]) {
    int i;
    for (i=0; nome[i]!='\0' && nome[i]!=','; ++i);
    if (i != strlen(nome)) {
        strcat (a, nome+i+1);
        strcat (a, " ");
        nome[i] = '\0';
        strcat (a, nome);
        strcpy (nome, a);
    }
    memset(a, 0, strlen(a));
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
        printf("\t\t<h1> <b> Categoria %s</b> - %d ", (*l)->nome, (*l)->num_ocorr);
        if ((*l)->num_ocorr > 1) printf ("ocorrências </h1>\n");
        else printf ("ocorrência </h1>\n");

        LProj *sitio = &((*l)->projeto);
        printf ("<ol>\n");
        while (*sitio != NULL) {
            printf ("\t\t\t<li style=\"font-size:1.5vw\"> <b> Título: %s </b> </li>\n", (*sitio)->titulo);
            printf ("\t\t\t\t<ul> \t\t<b>Chave:</b> %s </ul>\n", (*sitio)->chave);
            printf ("\t\t\t\t<ul> \t\t<b>Autores:</b> ");

            LStr *sitio2 = &((*sitio)->autores);
            while (*sitio2 != NULL && (*sitio2)->prox != NULL) {
                printf ("%s and ", (*sitio2)->nome);
                sitio2 = &((*sitio2)->prox);
            }
            if ((*sitio2) != NULL) printf ("%s", (*sitio2)->nome);
            printf (" </ul>\n\n");
            sitio = &((*sitio)->prox); 
        }
        printf ("</ol>\n");

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
    int num;
    printf ("\n");
    while ((*a) != NULL) {
        num = contaPubs (&((*a)->public));
        printf ("<h1> %s - %d ", (*a)->nome, contaPubs (&((*a)->public)));
        if (num > 1) printf ("Publicações\n </h1>\n");
        else printf ("Publicação\n </h1>\n");

        LStr *sitio = &((*a)->public);
        printf ("<ul>\n");
        while (*sitio != NULL) {
            printf ("<li>\t%s \n </li>", (*sitio)->nome);
            sitio = &((*sitio)->prox);
        }
        printf ("</ul>\n");
        a = &((*a)->prox);
    }
}

void ShowAutF (LAut *a, FILE *f) {
    int num;
    fprintf (f, "\n");
    while ((*a) != NULL) {
        num = contaPubs (&((*a)->public));
        fprintf (f, "%s - %d", (*a)->nome, num);
        if (num > 1) fprintf (f, "Publicações\n");
        else fprintf (f, "Publicação\n");

        LStr *sitio = &((*a)->public);
        while (*sitio != NULL) {
            fprintf (f, "\t- %s \n", (*sitio)->nome);
            sitio = &((*sitio)->prox);
        }
        fprintf (f, "\n");
        a = &((*a)->prox);
    }
}

void ShowGraph (Graph *grafo, char *path) {
    LNodo *aux = &((*grafo)->autores);
    FILE *file = fopen(path, "w");
    fprintf (file, "graph G {\n");
    fprintf (file, "\tlayout = fdp;\n");
    int num = 1;
    while (*aux != NULL){
        fprintf (file,"\t%d -- %d;\n", 0, num++);
        aux = &((*aux)->prox);
    }
    aux = &((*grafo)->autores);
    fprintf (file,"\t%d [label=\"%s\"];\n", 0,(*grafo)->nome);
    num = 1;
    while (*aux != NULL){
        fprintf (file, "\t%d [label=\"%s\n%d em comum\"];\n", num++,(*aux)->nome, (*aux)->num_ocorr);
        aux = &((*aux)->prox);
    }
    fprintf (file,"}");
    fclose(file);
}

void acrescentaGrafo (Graph g, LStr auts) {
    LStr *sitio = &auts;
    while (*sitio != NULL && strcmp((*sitio)->nome, g->nome) != 0) sitio = &((*sitio)->prox);
    if (*sitio != NULL) {
        sitio = &auts;
        while(*sitio!=NULL) {
            if (strcmp((*sitio)->nome, g->nome) != 0) acrescentaNodo (&(g->autores), (*sitio)->nome);
            sitio = &((*sitio)->prox);
        }
    }
}

void ShowAuthorTable (FILE *f, LNodo autores) {
    int num_nomes, num_chars;
    fprintf (f, "\n\n");
    for (int i=0; i<8; ++i) fprintf (f, "     ");
    fprintf (f, "LISTA DE AUTORES\n\n");
    while (autores != NULL) {
        for (num_nomes=0; num_nomes<3 && autores != NULL; ++num_nomes) {
            for (int i=0; autores->nome[i]!='\0'; ++i) fprintf (f, "%c", autores->nome[i]);
            for (num_chars=strlen(autores->nome); num_chars<40; ++num_chars) fprintf (f, " ");
            autores = autores->prox;
        }
        fprintf (f, "\n");
    }
}

void printHTMLstart () {
    printf ("<!DOCTYPE html>\n<html>\n<head>\n");
    printf ("<title> Trabalho 1 </title>\n");
    printf ("<meta name=\"viewport\" content=\"width=device-width, initial-scale=1\">\n");
    printf ("<style>\nbody {\nfont-family: Arial;\n}\n");printf (".tab {\noverflow: hidden;\nborder: 1px solid #ccc;\nbackground-color: #f1f1f1;\n}\n");
    printf ("img {\ndisplay: block;\nmargin-left: auto;\nmargin-right: auto;\n}\n");
    printf (".tab button {\nbackground-color: inherit;\nborder: none;\noutline: none;\ncursor: pointer;\n");
    printf ("padding: 14px 16px;\ntransition: 0.3s;\nfont-size: 17px;\n}\n");
    printf (".tab button:hover {\nbackground-color: #ddd;\n}\n");
    printf (".tab button.active {\nbackground-color: #ccc;\n}\n");
    printf (".tabcontent {\ndisplay: none;\npadding: 6px 12px;\nborder: 1px solid #ccc;\nborder-top: none;\n}\n");
    printf ("</style>\n</head>\n<body>\n");
    printf ("<pre class=\"tab\" style=\"text-align:center;\"> <h style=\"font-size:5vw\"> <b> BibTeXPro </b> </h> </pre>\n");
    printf ("<div class=\"tab\">\n");
    printf ("<button class=\"tablinks\" onclick=\"openCity(event, 'Categorias')\">Categorias</button>\n");
    printf ("<button class=\"tablinks\" onclick=\"openCity(event, 'Autores')\">Autores</button>\n");
    printf ("<button class=\"tablinks\" onclick=\"openCity(event, 'Grafo')\">Grafo</button>\n</div>\n");
}

void printHTMLend () {
    printf ("<script>\nfunction openCity(evt, cityName) {\n");
    printf ("var i, tabcontent, tablinks;\n");
    printf ("tabcontent = document.getElementsByClassName(\"tabcontent\");\n");
    printf ("for (i = 0; i < tabcontent.length; i++) {\ntabcontent[i].style.display = \"none\";\n}");
    printf ("tablinks = document.getElementsByClassName(\"tablinks\");\n");
    printf ("for (i = 0; i < tablinks.length; i++) {\n");
    printf ("tablinks[i].className = tablinks[i].className.replace(\" active\", \"\");\n}");
    printf ("document.getElementById(cityName).style.display = \"block\";\n");
    printf ("evt.currentTarget.className += \" active\";\n}\n</script>\n");
    printf ("</body>\n</html>");
}