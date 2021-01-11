#include "errors.h"

void myyyerror (char **r, char *s, int *error) {
    if (!(*error)) printf ("\n%s\n", repeatChar ('-', 90));
    asprintf (r, "%s", "");
    yyerror (s);
    *error = 1;
    printf ("%s\n", repeatChar ('-', 90));
}

void notDeclared (char **r, char *id, int *error) {
    char *error_str;
    asprintf (&error_str, "Can't assign to variable \"%s\" because it hasn't been declared.", id);
    myyyerror(r, error_str, error);
}

void outOfRange (char **r, char *id, char size, char index, int *error) {
    char *error_str;
    asprintf (&error_str, "Array \"%s\" of size %d has no index %d.", id, size, index);
    myyyerror (r, error_str, error);
}

void assignIntArray (char **r, char *id, int *error) {
    char *error_str;
    asprintf (&error_str, "Can't assign integer to array \"%s\".", id);
    myyyerror (r, error_str, error);
}