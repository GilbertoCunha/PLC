%{
#include <stdio.h>
#include "AVLTrees.h"

int ERROR = 0;
AVLTree vars = NULL;
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

Declaration : T_INT T_ID ';'                            { insertAVL(&vars, $2, 0); }
            | T_INT T_ID '=' Expression ';'             { if (!ERROR) insertAVL(&vars, $2, $4); }
            | T_INT T_ID '[' T_NUM ']' ';'              { 
    if (!ERROR) {
        for (int i=0; i<$4; ++i) {
          char var_name[50];
          snprintf(var_name, 50, "_%s%d", $2, i);
          printf ("%s\n", var_name);
          insertAVL(&vars, var_name, i);
        }
    }
}
            | T_ID '=' T_NUM ';'                         {
    if (!ERROR) {
        int value; 
        if (searchAVLvalue(vars, $1, &value)) insertAVL(&vars, $1, $3);
        else {
          ERROR = 1;
          char error_str[100];
          snprintf (error_str, 100, "Can't assign to variable \"%s\" because it hasn't been declared\n", $1);
          yyerror(error_str);
        }
    }
}     
            | T_ID '[' T_NUM ']' '=' T_NUM ';'            {
    if (!ERROR) {
        int value; 
        char varname[50];
        snprintf (varname, 50, "_%s%d", $1, $3);
        if (searchAVLvalue(vars, varname, &value)) insertAVL(&vars, varname, $6);
        else {
          ERROR = 1;
          char error_str[100];
          snprintf (error_str, 100, "Can't assign to variable \"%s\" because it hasn't been declared\n", $1);
          yyerror(error_str);
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
    int r, value;
    r = searchAVLvalue (vars, $1, &value);
    if (r == 0) { 
      char error_str[100];
      snprintf (error_str, 100, "Variable \"%s\" has not yet been created\n", $1);
      yyerror(error_str);
      ERROR = 1;
    }
    else $$ = value;
}
       | T_ID '[' T_NUM ']' {
    int r, value;
    char varname[50];
    snprintf (varname, 50, "_%s%d", $1, $3);
    r = searchAVLvalue (vars, varname, &value);
    if (r == 0) { 
      char error_str[100];
      snprintf (error_str, 100, "Variable \"%s\" has not yet been created\n", $1);
      yyerror(error_str);
      ERROR = 1;
    }
    else $$ = value;
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

int main() {
    printf ("Started parsing\n");
    yyparse ();
    printf ("Parsing COMPLETE\n");
    printf ("\n");
    
    GraphAVLTree (vars);

    return 0;
}