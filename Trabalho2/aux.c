#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "aux.h"

int array_index (char *src, char **id) {
    int r;
    int size, end;
    char *aux = strdup(src);
    for (size=0; src[size]!='\0' && src[size]!='['; ++size);
    for (end=size; src[end]!='\0'; end++)
        if (src[end]!='[' && src[end]!=']') 
            aux[end-size-1] = src[end];
    if (size == end) r = -1;
    else {
        aux[end-size-2] = '\0';
        if (isdigit(aux[0])) r = atoi (aux);
        else {
          asprintf (id, "%s", aux);
          r = -1;
        }
    }
    return r;
}

char *get_varname (char *src) {
    char *dest = strdup(src);
    int i;
    for (i=0; src[i]!='\0' && src[i]!='['; ++i);
    dest[i] = '\0';
    return dest;
}

char *repeatChar (char c, int n) {
    char *r = malloc ((n+1) * sizeof (char));
    for (int i=0; i<n; ++i) r[i] = c;
    r[n] = '\0';
    return r;
}