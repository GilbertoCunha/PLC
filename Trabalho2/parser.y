%{
#include <stdio.h>
#include <glib.h>

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
            | T_INT T_ID '=' Expression ';'             { g_hash_table_insert(vars, $2, $4); }
            | T_INT T_ID '[' T_NUM ']' '=' List ';'
            ;

Expression : Expression '+' Term  { $$ = $1 + $3; }
           | Expression '-' Term  { $$ = $1 - $3; }
           | Term                 { $$ = $1; }
           ;

Term : Term '*' Factor  { $$ = $1 * $3; }
     | Term '/' Factor  { 
    if ($3 == 0) yyerror("Division by zero!\n");
    else $$ = $1 / $3;
}
     | Factor           { $$ = $1; }
     ;

Factor : T_NUM  { $$ = $1; } 
       | T_ID   { 
    void *r = g_hash_table_lookup(vars, $1);
    if (r == NULL) {
      char error_str[100];
      printf ("%s\n", $1);
      asprintf(&error_str, "Variable \"%s\" has not been created\n", $1);
      yyerror(error_str);
    }
    else $$ = r;
}
       ;

List : '[' ListAux ']'
     | '[' ']'
     ;

ListAux : T_NUM ',' ListAux
        | T_ID ',' ListAux
        | T_NUM
        | T_ID
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
    free (keys);
}

int main() {
    int x = 3;
    vars = g_hash_table_new(g_str_hash, g_int_equal);
    printf ("Started parsing\n");
    yyparse ();
    printf ("Parsing COMPLETED\n");
    printf ("\n");
    printHash (vars);

    return 0;
}