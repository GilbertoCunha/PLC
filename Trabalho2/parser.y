%{
#include <stdio.h>
#include <glib.h>

int ERROR = 0;
GHashTable *vars;
int yylex();
void yyerror(char *s);
%}

%union {
  int num;
  char *id;
}

%token <id> T_ID
%token <num> T_NUM
%token T_INT
%token T_FOR
%token T_START T_END
%token T_IF T_ELSE
%token T_AND T_OR T_NOT
%token T_ERROR

%type <num> Factor Term Expression
%start L

%%
L : Declarations
  ;

Declarations : Declaration Declarations
             |
             ;

Declaration : T_INT T_ID ';'                            { g_hash_table_insert(vars, $2, 0); }
            | T_INT T_ID '=' Expression ';'             { if (!ERROR) g_hash_table_insert(vars, $2, $4); }
            | T_INT T_ID '[' T_NUM ']' ';'              { 
    if (!ERROR) {
        for (int i=0; i<$4; ++i) {
          char var_name[50];
          snprintf(var_name, 50, "%s[%d]", $2, i);
          printf ("%s\n", var_name);
          g_hash_table_insert(vars, var_name, i);
        }
    }
}
            ;

Expression : Expression '+' Term  { if (!ERROR) $$ = $1 + $3; }
           | Expression '-' Term  { if (!ERROR) $$ = $1 - $3; }
           | Term                 { if (!ERROR) $$ = $1; }
           ;

Term : Term '*' Factor  { if (!ERROR) $$ = $1 * $3; }
     | Term '/' Factor  { 
    if ($3 == 0) {
      yyerror("Division by zero!\n");
      ERROR = 1;
    }
    else if (!ERROR) $$ = $1 / $3;
}
     | Factor           { if (!ERROR) $$ = $1; }
     ;

Factor : T_NUM  { $$ = $1; } 
       | T_ID   { 
    void *r = g_hash_table_lookup(vars, $1);
    if (r == NULL) {
      char error_str[100];
      snprintf (error_str, 100, "Variable \"%s\" has not yet been created\n", $1);
      yyerror(error_str);
      ERROR = 1;
    }
    else $$ = r;
}
       ;

List : '[' ListAux ']'
     | '[' ']'
     ;

ListAux : Expression ',' ListAux
        | Expression ',' ListAux
        | Expression
        | Expression
        ;
%%

#include "lex.yy.c"

void yyerror (char *s) {
    fprintf (stderr,"Error: %s\n",s);
}

void printHash (GHashTable *h) {
    printf ("Variables:\n");
    GList *keys = g_hash_table_get_keys(vars);
    while (keys != NULL) {
        printf ("    %s: %d\n", keys->data, g_hash_table_lookup(vars, keys->data));
        keys = keys->next;
    }
}

int main() {
    int x = 3;
    vars = g_hash_table_new(g_str_hash, g_int_equal);
    printf ("Started parsing\n");
    yyparse ();
    printf ("Parsing COMPLETED\n");
    printf ("\n");
    printHash (vars);

    printf ("%s: %d\n", "array[1]", g_hash_table_lookup(vars, "array[1]"));

    return 0;
}