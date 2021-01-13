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

char *outOfRange (char *id, char *instr, int size, int *count) {
    char *inferior, *greater, *error_inf, *error_gr, *error_str;
    asprintf (&error_gr, "| Error: Index of array \'%s\' too high for its size.", id);
    asprintf (&error_inf, "| Error: Index of array \'%s\' smaller than zero.", id);
    asprintf (&greater, "%spushi %d\nsupeq\njz func%d\nerr \"%s\"\nstop\nfunc%d:\n", 
                instr, size, *count, error_gr, *count);
    asprintf (&inferior, "%spushi 0\ninf\njz func%d\nerr \"%s\"\nstop\nfunc%d:\n", 
                instr, *count + 1, error_inf, *count + 1);
    asprintf (&error_str, "%s%s", inferior, greater);
    *count = *count + 2;
    return error_str;
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