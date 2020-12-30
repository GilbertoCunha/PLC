#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "aux.h"

void remChar (char *s, char c) {
    int j, n = strlen(s); 
    for (int i=j=0; i<n; i++) 
       if (s[i] != c) 
          s[j++] = s[i]; 
      
    s[j] = '\0';
}

int array_size (char *s) {
    int res=0, j=0, n=strlen(s);
    char r[n];
    for (int i=0; i<n; ++i) 
       if (s[i] == '[') {
         res=1;
         for (j=0; s[i+j+1]!=']'; ++j) r[j] = s[i+j+1];
         break;
       }
    r[j] = '\0';
    if (res) res = atoi(r);
    else res = 1;
    return res;
}

char *array_pos_name (char *s, int pos) {
    int res=0, j=0, n=strlen(s);
    char r[n], *f = malloc (n * sizeof (char));
    for (j=0; j<n && s[j]!='['; ++j)
       r[j] = s[j];
    r[j] = '\0';
    snprintf (f, n, "_%s%d", r, pos);
    return f;
}

void T_ID_to_str (char *s, char *varname) {
    char aux[50];
    strcpy (aux, s);
    if (strchr (s, '[') != NULL) {
        remChar (aux, '['); remChar (aux, ']');
        snprintf (varname, 50, "_%s", aux);
    }
    else snprintf (varname, 50, "%s", s);
}