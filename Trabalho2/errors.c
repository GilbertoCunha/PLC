#include "errors.h"

void myyyerror (char **r, char *s) {
    asprintf (r, "%s", "");
    yyerror (s);
}

void notDeclared (char **r, char *id) {
    char *error_str;
    asprintf (&error_str, "Can't assign to variable \"%s\" because it hasn't been declared.", id);
    myyyerror(r, error_str);
}

void outOfRange (char **r, char *id, char size, char index) {
    char *error_str;
    asprintf (&error_str, "Array \"%s\" of size %d has no index %d.", id, size, index);
    myyyerror (r, error_str);
}

void assignIntArray (char **r, char *id) {
    char *error_str;
    asprintf (&error_str, "Can't assign integer to array \"%s\".", id);
    myyyerror (r, error_str);
}

void intIndex (char **r, char *id) {
    char *error_str;
    asprintf (&error_str, "Integer \"%s\" can't be indexed.", id);
    myyyerror (r, error_str);
}