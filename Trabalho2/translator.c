#include "translator.h"

void ifInstr (char **r, char *expr, char *instr, int *count) {
    asprintf (r, "%sjz cond%d\n%scond%d:\n", expr, *count, instr, *count);
    *count = *count + 1;
}

void ifElse (char **r, char *expr, char *instr1, char *instr2, int *count) {
    asprintf (r, "%sjz cond%d\n%sjump cond%d\ncond%d:\n%scond%d:\n", expr, *count, instr1, *count + 1, *count, instr2, *count + 1);
    *count = *count + 2;
}

void ifElseif (char **r, char *expr, char *instr, char *cond, int *count) {
    asprintf (r, "%sjz cond%d\n%sjump cond%d\ncond%d:\n%s", expr, *count, instr, *count - 1, *count, cond);
    *count = *count + 1;
}

void exprAtr (char **r, char *id, char *expr, AVLTree *vars, int *error) {
    int sp, size;
    char *class, *type;
    char *varname = get_varname(id);
    int index = array_size(id);
    if (!searchAVL (*vars, varname, &class, &type, &size, &sp)) notDeclared (r, varname, error);
    else if (!strcmp (class, "var")) asprintf (r, "%sstoreg %d\n", expr, sp);
    else if (!strcmp (class, "array") && index < size) asprintf (r, "pushgp\npushi %d\npadd\npushi %d\n%sstoren\n", sp, index, expr);
    else if (!strcmp (class, "array")) outOfRange (r, varname, size, index, error);
}

void readAtr (char **r, char *id, AVLTree *vars, int *error) {
    int sp, size;
    char *class, *type;
    char *varname = get_varname(id);
    int index = array_size(id);
    if (!searchAVL (*vars, varname, &class, &type, &size, &sp)) notDeclared (r, varname, error);
    else if (!strcmp (class, "type")) asprintf (r, "read\natoi\nstoreg %d\n", sp);
    else if (!strcmp (class, "array")) assignIntArray (r, varname, error);
}

void readAtrStr (char **r, char *id, char *s, AVLTree *vars, int *error) {
    int sp, size;
    char *type, *class;
    char *varname = get_varname(id);
    int index = array_size(id);
    if (!searchAVL (*vars, varname, &class, &type, &size, &sp)) notDeclared (r, varname, error);
    else if (!strcmp (class, "var")) asprintf (r, "pushs %s\nwrites\nread\natoi\nstoreg %d\n", s, sp);
    else if (!strcmp (class, "array")) assignIntArray (r, varname, error);
}

void declaration (char **r, char *id, int *count, AVLTree *vars) {
    int index = array_size (id);
    char *varname = get_varname(id);
    if (index == -1) {
        insertAVL (vars, varname, "var", "int", 1, *count);
        asprintf (r, "pushn 1\n");
        *count = *count + 1;
    }
    else {
        insertAVL (vars, varname, "array", "int", index, *count);
        asprintf (r, "pushn %d\n", index);
        *count = *count + index;
    }
}

void declrExpr (char **r, char *id, char *expr, AVLTree *vars, int *count, int *error) {
    int index = array_size(id);
    char *varname = get_varname(id);
    if (index == -1) {
        insertAVL (vars, varname, "var", "int", 1, *count);
        asprintf (r, "pushn 1\n%sstoreg %d\n", expr, *count);
        *count = *count +1;
    }
    else myyyerror (r, "Can't declare and assign to array.", error);
}

void declrRead (char **r, char *id, AVLTree *vars, int *count, int *error) {
    int index = array_size(id);
    char *varname = get_varname(id);
    if (index == -1) {
        insertAVL (vars, varname, "var", "int", 1, *count);
        asprintf (r, "pushn 1\nread\natoi\nstoreg %d\n", *count);
        *count = *count + 1;
    }
    else assignIntArray (r, varname, error);
}

void declrReadStr (char **r, char *id, char *s, AVLTree *vars, int *count, int *error) {
    int index = array_size(id);
    char *varname = get_varname(id);
    if (index == -1) {
        insertAVL (vars, varname, "var", "int", 1, *count);
        asprintf (r, "pushs %s\nwrites\npushn 1\nread\natoi\nstoreg %d\n", s, *count);
        *count = *count + 1;
    }
    else assignIntArray (r, varname, error);
}

void factorId (char **r, char *id, AVLTree *vars, int *error) {
    int sp, size;
    char *class, *type;
    char *varname = get_varname(id);
    int index = array_size(id);
    if (!searchAVL (*vars, varname, &class, &type, &size, &sp)) notDeclared (r, varname, error);
    else if (!strcmp (class, "var")) asprintf(r, "pushg %d\n", sp);
    else if (!strcmp (class, "array") && index < size) asprintf(r, "pushgp\npushi %d\npadd\npushi %d\nloadn\n", sp, index);
    else if (!strcmp (class, "array")) outOfRange (r, varname, size, index, error);
}

void negfactorId (char **r, char *id, AVLTree *vars, int *error) {
    int sp, size;
    char *class, *type;
    char *varname = get_varname(id);
    int index = array_size(id);
    if (!searchAVL (*vars, varname, &class, &type, &size, &sp)) notDeclared (r, varname, error);
    else if (!strcmp (class, "var")) asprintf(r, "pushg %d\npushi -1\nmul\n", sp);
    else if (!strcmp (class, "array") && index < size) asprintf(r, "pushgp\npushi %d\npadd\npushi %d\nloadn\npushi -1\nmul\n", sp, index);
    else if (!strcmp (class, "array")) outOfRange (r, varname, size, index, error);
}

void forStartEnd (char **r, char *id, char *expr1, char *expr2, char *instr, AVLTree *vars, int *count, int *error) {
    int sp, size;
    char *class, *type;
    char *varname = get_varname(id);
    int index = array_size(id);
    if (!searchAVL (*vars, varname, &class, &type, &size, &sp)) notDeclared (r, varname, error);
    else if (!strcmp (class, "var")) {
        asprintf(r, "%s%sinf\njz cycle%d\n%sstoreg %d\ncycle%d:\n%spushg %d\npushi 1\nadd\nstoreg %d\npushg %d\n%ssupeq\njz cycle%d\ncycle%d:\n", 
                expr1, expr2, *count + 1, expr1, sp, *count, instr, sp, sp, sp, expr2, *count, *count + 1);
        *count = *count + 2;
    }
    else if (!strcmp (class, "array")) myyyerror (r, "Can't iterate variable of array, use integer instead.", error);
}

void forStep (char **r, char *id, char *expr1, char *expr2, char *expr3, char *instr, AVLTree *vars, int *count, int *error) {
    int sp, size;
    char *class, *type;
    char *varname = get_varname(id);
    int index = array_size(id);
    if (!searchAVL (*vars, varname, &class, &type, &size, &sp)) notDeclared (r, varname, error);
    else if (!strcmp (class, "var")) {
        char *aux, *aux1;
        asprintf (&aux, "%s%s%spushi 0\ninf\njz cycle%d\ncycle%d:\ninfeq\njz cycle%d\njump cycle%d\ncycle%d:\nsupeq\njz cycle%d\njump cycle%d\n", 
                  expr1, expr2, expr3, *count + 1, *count, *count + 2, *count + 4, *count + 1, *count + 2, *count + 4);
        asprintf (&aux1, "%spushi 0\ninf\njz cycle%d\ncycle%d:\ninfeq\njz cycle%d\njump cycle%d\ncycle%d:\nsupeq\njz cycle%d\njump cycle%d\n", 
                  expr3, *count + 6, *count + 5, *count + 3, *count + 7, *count + 6, *count + 3, *count + 7);
        asprintf(r, "%scycle%d:\n%sstoreg %d\ncycle%d:\n%spushg %d\n%sadd\nstoreg %d\npushg %d\n%s%scycle%d:\n", 
                 aux, *count + 2, expr1, sp, *count + 3, instr, sp, expr3, sp, sp, expr2, aux1, *count + 7);
        *count = *count + 8;
    }
    else if (!strcmp (class, "array")) myyyerror (r, "Can't iterate variable of array, use integer instead.", error);
}