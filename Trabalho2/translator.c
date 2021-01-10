#include "translator.h"

void myyyerror (char **r, char *s, int *error) {
    if (!(*error)) printf ("\n%s\n", repeatChar ('-', 90));
    asprintf (r, "%s", "");
    yyerror (s);
    *error = 1;
    printf ("%s\n", repeatChar ('-', 90));
}

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
    char *varname = get_varname(id);
    int index = array_size(id);
    searchAVLsize (*vars, varname, &size);
    if (searchAVLsp (*vars, varname, &sp) == -1) {
        char *error_str;
        asprintf (&error_str, "Can't assign to variable \"%s\" because it hasn't been declared.", varname);
        myyyerror(r, error_str, error);
    }
    else if (index == -1) asprintf (r, "%sstoreg %d\n", expr, sp);
    else if (index < size) asprintf (r, "pushgp\npushi %d\npadd\npushi %d\n%sstoren\n", sp, index, expr);
    else {
        char *error_str;
        asprintf (&error_str, "Array \"%s\" of size %d has no index %d.", varname, size, index);
        myyyerror (r, error_str, error);
    }
}

void readAtr (char **r, char *id, AVLTree *vars, int *error) {
    int sp;
    char *varname = get_varname(id);
    int index = array_size(id);
    if (searchAVLsp (*vars, varname, &sp) == -1) { 
        char *error_str;
        asprintf (&error_str, "Can't assign to variable \"%s\" because it hasn't been declared.", varname);
        myyyerror(r, error_str, error);
    }
    else if (index == -1) asprintf (r, "read\natoi\nstoreg %d\n", sp);
    else {
        char *error_str;
        asprintf (&error_str, "Can't assign integer to array \"%s\".", varname);
        myyyerror (r, error_str, error);
    }
}

void readAtrStr (char **r, char *id, char *s, AVLTree *vars, int *error) {
    int sp;
    char *varname = get_varname(id);
    int index = array_size(id);
    if (searchAVLsp (*vars, varname, &sp) == -1) { 
        char *error_str;
        asprintf (&error_str, "Can't assign to variable \"%s\" because it hasn't been declared.", varname);
        myyyerror(r, error_str, error);
    }
    else if (index == -1) asprintf (r, "pushs %s\nwrites\nread\natoi\nstoreg %d\n", s, sp);
    else {
        char *error_str;
        asprintf (&error_str, "Can't assign integer to array \"%s\".", varname);
        myyyerror (r, error_str, error);
    }
}

void declaration (char **r, char *id, int *count, AVLTree *vars) {
    int size = array_size (id);
    char *varname = get_varname(id);
    if (size == -1) {
        insertAVL (vars, varname, "int", size, *count);
        asprintf (r, "pushn 1\n");
        *count = *count + 1;
    }
    else {
        insertAVL (vars, varname, "array", size, *count);
        asprintf (r, "pushn %d\n", size);
        *count = *count + size;
    }
}

void declrExpr (char **r, char *id, char *expr, AVLTree *vars, int *count, int *error) {
    int size = array_size(id);
    char *varname = get_varname(id);
    if (size == -1) {
        insertAVL (vars, varname, "int", size, *count);
        asprintf (r, "pushn 1\n%sstoreg %d\n", expr, *count);
        *count = *count +1;
    }
    else myyyerror (r, "Can't declare and assign to array.", error);
}

void declrRead (char **r, char *id, AVLTree *vars, int *count, int *error) {
    int size = array_size(id);
    char *varname = get_varname(id);
    if (size == -1) {
        insertAVL (vars, varname, "int", size, *count);
        asprintf (r, "pushn 1\nread\natoi\nstoreg %d\n", *count);
        *count = *count + 1;
    }
    else {
        char *error_str;
        asprintf (&error_str, "Can't assign integer to array \"%s\".", varname);
        myyyerror (r, error_str, error);
    }
}

void declrReadStr (char **r, char *id, char *s, AVLTree *vars, int *count, int *error) {
    int size = array_size(id);
    char *varname = get_varname(id);
    if (size == -1) {
        insertAVL (vars, varname, "int", size, *count);
        asprintf (r, "pushs %s\nwrites\npushn 1\nread\natoi\nstoreg %d\n", s, *count);
        *count = *count + 1;
    }
    else {
        char *error_str;
        asprintf (&error_str, "Can't assign integer to array \"%s\".", varname);
        myyyerror (r, error_str, error);
    }
}

void factorId (char **r, char *id, AVLTree *vars, int *error) {
    int sp, size;
    char *varname = get_varname(id);
    int index = array_size(id);
    searchAVLsize(*vars, varname, &size);
    if (searchAVLsp (*vars, varname, &sp) == -1) {
        char *error_str;
        asprintf (&error_str, "Variable \"%s\" has not yet been declared.", varname);
        myyyerror(r, error_str, error);
    } 
    else if (index == -1) asprintf(r, "pushg %d\n", sp);
    else if (index < size) asprintf(r, "pushgp\npushi %d\npadd\npushi %d\nloadn\n", sp, index);
    else {
        char *error_str;
        asprintf (&error_str, "Array \"%s\" of size %d has no index %d.", varname, size, index);
        myyyerror (r, error_str, error);
    }
}

void negfactorId (char **r, char *id, AVLTree *vars, int *error) {
    int sp, size;
    char *varname = get_varname(id);
    int index = array_size(id);
    searchAVLsize(*vars, varname, &size);
    if (searchAVLsp (*vars, varname, &sp) == -1) {
        char *error_str;
        asprintf (&error_str, "Variable \"%s\" has not yet been declared.", varname);
        myyyerror(r, error_str, error);
    } 
    else if (index == -1) asprintf(r, "pushg %d\npushi -1\nmul\n", sp);
    else if (index < size) asprintf(r, "pushgp\npushi %d\npadd\npushi %d\nloadn\npushi -1\nmul\n", sp, index);
    else {
        char *error_str;
        asprintf (&error_str, "Array \"%s\" of size %d has no index %d.", varname, size, index);
        myyyerror (r, error_str, error);
    }
}

void forStartEnd (char **r, char *id, char *expr1, char *expr2, char *instr, AVLTree *vars, int *count, int *error) {
    int sp, size;
    char *varname = get_varname(id);
    int index = array_size(id);
    searchAVLsize(*vars, varname, &size);
    if (searchAVLsp (*vars, varname, &sp) == -1) {
        char *error_str;
        asprintf (&error_str, "Variable \"%s\" has not yet been declared.", varname);
        myyyerror(r, error_str, error);
    }
    else if (index == -1) {
        asprintf(r, "%s%sinf\njz cycle%d\n%sstoreg %d\ncycle%d:\n%spushg %d\npushi 1\nadd\nstoreg %d\npushg %d\n%ssupeq\njz cycle%d\ncycle%d:\n", 
                expr1, expr2, *count + 1, expr1, sp, *count, instr, sp, sp, sp, expr2, *count, *count + 1);
        *count = *count + 2;
    }
    else myyyerror (r, "Can't iterate variable of array, use integer instead.", error);
}

void forStep (char **r, char *id, char *expr1, char *expr2, char *expr3, char *instr, AVLTree *vars, int *count, int *error) {
    int sp, size;
    char *varname = get_varname(id);
    int index = array_size(id);
    searchAVLsize(*vars, varname, &size);
    if (searchAVLsp (*vars, varname, &sp) == -1) {
        char *error_str;
        asprintf (&error_str, "Variable \"%s\" has not yet been declared.", varname);
        myyyerror(r, error_str, error);
    }
    else if (index == -1) {
        asprintf(r, "%s%sinf\njz cycle%d\n%sstoreg %d\ncycle%d:\n%spushg %d\n%sadd\nstoreg %d\npushg %d\n%ssupeq\njz cycle%d\ncycle%d:\n", 
                expr1, expr2, *count + 1, expr1, sp, *count, instr, sp, expr3, sp, sp, expr2, *count, *count + 1);
        *count = *count + 2;
    }
    else myyyerror (r, "Can't iterate variable of array, use integer instead.", error);
}