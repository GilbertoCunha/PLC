#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "aux.h"

char *repeatChar (char c, int n) {
    char *r = malloc ((n+1) * sizeof (char));
    for (int i=0; i<n; ++i) r[i] = c;
    r[n] = '\0';
    return r;
}