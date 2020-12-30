%{
#include <stdio.h>
#include "AVLTrees.h"

int ERROR = 0;
AVLTree vars = NULL;
FILE *vm;
int yylex();
void yyerror(char *s);
%}

%union {
  int num;
  char *id;
  char *inst;
}

%token <id> T_ID
%token <num> T_NUM
%token T_INT
%token T_FOR
%token T_START T_END
%token T_IF T_ELSE
%token T_AND T_OR T_NOT
%token T_READ T_WRITE
%token T_ERROR

%type <inst> Declaration
%type <num> Factor Term Expression
%start L

%%
L : Declarations L
  | Std L
  |
  ;

Std : T_INT T_ID '=' T_READ ')' ';'       { 
    if (!ERROR) {
        fprintf (vm, "read\natoi\n"); 
    
    }
} 

Declarations : Declarations Declaration   { if (!ERROR) fprintf (vm, "%s", $2); }
             | 
             ;

Declaration : T_INT T_ID ';'                            { insertAVL(&vars, $2, 0); asprintf (&$$, "pushn 1\n"); }
            | T_INT T_ID '=' Expression ';'             { if (!ERROR) { insertAVL(&vars, $2, $4); asprintf (&$$, "pushi %d\n", $4); } }
            | T_INT T_ID '[' T_NUM ']' ';'              { 
    if (!ERROR) {
        for (int i=0; i<$4; ++i) {
          char var_name[50];
          snprintf(var_name, 50, "_%s%d", $2, i);
          insertAVL(&vars, var_name, 0);
        }
        asprintf (&$$, "pushn %d\n", $4);
    }
}
            | T_ID '=' Expression ';'                         {
    if (!ERROR) {
        int sp; 
        if (searchAVLsp(vars, $1, &sp)) insertAVL(&vars, $1, $3);
        else {
          ERROR = 1;
          char error_str[100];
          snprintf (error_str, 100, "Can't assign to variable \"%s\" because it hasn't been declared\n", $1);
          yyerror(error_str);
        }
        asprintf (&$$, "pushi %d\nstoreg %d\n", $3, sp);
    }
}     
            | T_ID '[' T_NUM ']' '=' Expression ';'            {
    if (!ERROR) {
        int sp;
        char varname[50];
        snprintf (varname, 50, "_%s%d", $1, $3);
        if (searchAVLsp(vars, varname, &sp)) insertAVL(&vars, varname, $6);
        else {
          ERROR = 1;
          char error_str[100];
          snprintf (error_str, 100, "Can't assign to variable \"%s\" because it hasn't been declared\n", $1);
          yyerror(error_str);
        }
        asprintf (&$$, "pushi %d\nstoreg %d\n", $6, sp);
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

Factor : T_NUM              { $$ = $1; }
       | T_ID '[' T_NUM ']' {
    int value;
    char varname[50];
    snprintf (varname, 50, "_%s%d", $1, $3);
    if (!searchAVLvalue (vars, varname, &value)) { 
      char error_str[100];
      snprintf (varname, 50, "%s[%d]", $1, $3);
      snprintf (error_str, 100, "Variable \"%s\" has not yet been declared\n", varname);
      yyerror(error_str);
      ERROR = 1;
    }
    else $$ = value;
}
       | T_ID   { 
    int value;
    if (!searchAVLvalue (vars, $1, &value)) { 
      char error_str[100];
      snprintf (error_str, 100, "Variable \"%s\" has not yet been deflared\n", $1);
      yyerror(error_str);
      ERROR = 1;
    }
    else $$ = value;
}
       ;
%%

#include "lex.yy.c"

void yyerror (char *s) {
    fprintf (stderr,"Error: %s\n",s);
}

int main() {
    vm = fopen ("program.vm", "w");
    printf ("Started parsing\n");
    yyparse ();
    printf ("Parsing COMPLETE\n");
    
    GraphAVLTree (vars);
    fclose (vm);
    return 0;
}