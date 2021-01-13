#include "errors.h"

void myyyerror (char **r, char *s) {
    asprintf (r, "%s", "");
    yyerror (s);
}

void notDeclared (char **r, char *id) {
    char *error_str;
    asprintf (&error_str, "Can't access variable \"%s\" because it hasn't been declared.", id);
    myyyerror(r, error_str);
}

void outOfRange (char **r, char *id, char size, char index) {
    char *error_str;
    asprintf (&error_str, "Array \"%s\" of size %d has no index %d.", id, size, index);
    myyyerror (r, error_str);
}

void assignIntArray (char **r, char *id) {
    char *error_str;
    asprintf (&error_str, "Array \"%s\" can't be treated as an integer.", id);
    myyyerror (r, error_str);
}

void intIndex (char **r, char *id) {
    char *error_str;
    asprintf (&error_str, "Integer \"%s\" can't be indexed.", id);
    myyyerror (r, error_str);
}

void indexSizeDontMatch (char **r, char *id, int index, int size) {
    char *error_str;
    asprintf (&error_str, "Array \"%s\" declared with size %d but list has size %d.", id, index, size);
    myyyerror (r, error_str);
}

void reDeclaration (char **r, char *id) {
    char *error_str;
    asprintf (&error_str, "Variable \"%s\" redeclared.", id);
    myyyerror (r, error_str);
}