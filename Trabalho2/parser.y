%{
#include <stdio.h>
#include "AVLTrees.h"

int ERROR = 0;
int var_count = 0;
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
%type <inst> Factor Term Expression
%start L

%%
L : Declarations
  |
  ;

Declarations : Declarations Declaration   { if (!ERROR) fprintf (vm, "%s", $2); }
             | 
             ;

Declaration : T_INT T_ID ';'                            { insertAVL(&vars, $2, 0); asprintf (&$$, "pushn 1\n"); }
            | T_INT T_ID '=' Expression ';'             { 
    if (!ERROR) { 
      insertAVL(&vars, $2, var_count); 
      asprintf (&$$, "pushn 1\n%sstoreg %d\n", $4, var_count++); 
    } 
}
            | T_INT T_ID '[' T_NUM ']' ';'              { 
    if (!ERROR) {
        for (int i=0; i<$4; ++i) {
          char var_name[50];
          snprintf (var_name, 50, "_%s%d", $2, i);
          insertAVL (&vars, var_name, var_count++);
        }
        asprintf (&$$, "pushn %d\n", $4);
    }
}
            | T_ID '=' Expression ';'                         {
    if (!ERROR) {
        int sp; 
        if (!searchAVL(vars, $1, &sp)) {
          ERROR = 1;
          char error_str[100];
          snprintf (error_str, 100, "Can't assign to variable \"%s\" because it hasn't been declared\n", $1);
          yyerror(error_str);
        }
        else asprintf (&$$, "%sstoreg %d\n", $3, sp);
    }
}     
            | T_ID '[' T_NUM ']' '=' Expression ';'            {
    if (!ERROR) {
        int sp;
        char varname[50];
        snprintf (varname, 50, "_%s%d", $1, $3);
        if (!searchAVL(vars, varname, &sp)) {
          ERROR = 1;
          char error_str[100];
          snprintf (error_str, 100, "Can't assign to variable \"%s\" because it hasn't been declared\n", $1);
          yyerror(error_str);
        }
        else asprintf (&$$, "%sstoreg %d\n", $6, sp);
    }
}
            | T_INT T_ID '=' T_READ ')' ';'                     {
    if (!ERROR) {
        insertAVL (&vars, $2, var_count);
        asprintf (&$$, "pushn 1\nread\natoi\nstoreg %d\n", var_count++);
    }
}
            | T_ID '=' T_READ ')' ';'                     {
    if (!ERROR) {
        int sp;
        if (!searchAVL(vars, $1, &sp)) {
          ERROR = 1;
          char error_str[100];
          snprintf (error_str, 100, "Can't assign to variable \"%s\" because it hasn't been declared\n", $1);
          yyerror(error_str);
        }
        else asprintf (&$$, "read\natoi\nstoreg %d\n", sp);
    }
}
            | T_ID '[' T_NUM ']' '=' T_READ ')' ';'                     {
    if (!ERROR) {
        int sp;
        char varname[50];
        snprintf (varname, 50, "_%s%d", $1, $3);
        if (!searchAVL(vars, varname, &sp)) {
          ERROR = 1;
          char error_str[100];
          snprintf (error_str, 100, "Can't assign to variable \"%s\" because it hasn't been declared\n", $1);
          yyerror(error_str);
        }
        else asprintf (&$$, "read\natoi\nstoreg %d\n", sp);
    }
}
            ;

Expression : Expression '+' Term  { if (!ERROR) asprintf (&$$, "%s%sadd\n", $1, $3); }
           | Expression '-' Term  { if (!ERROR) asprintf (&$$, "%s%ssub\n", $1, $3); }
           | Term                 { if (!ERROR) asprintf (&$$, "%s", $1); }
           ;

Term : Term '*' Factor  { if (!ERROR) asprintf (&$$, "%s%smul\n", $1, $3); }
     | Term '/' Factor  { 
    if ($3 == 0) {
      yyerror("Division by zero!\n");
      ERROR = 1;
    }
    else if (!ERROR) asprintf (&$$, "%s%sdiv\n", $1, $3);
}
     | Factor           { if (!ERROR) asprintf (&$$, "%s", $1); }
     ;

Factor : T_NUM              { asprintf (&$$, "pushi %d\n", $1); }
       | T_ID '[' T_NUM ']' {
    int sp;
    char varname[50];
    snprintf (varname, 50, "_%s%d", $1, $3);
    if (!searchAVL (vars, varname, &sp)) { 
      char error_str[100];
      snprintf (varname, 50, "%s[%d]", $1, $3);
      snprintf (error_str, 100, "Variable \"%s\" has not yet been declared\n", varname);
      yyerror(error_str);
      ERROR = 1;
    }
    else asprintf(&$$, "pushg %d\n", sp);
}
       | T_ID   { 
    int sp;
    if (!searchAVL (vars, $1, &sp)) { 
      char error_str[100];
      snprintf (error_str, 100, "Variable \"%s\" has not yet been deflared\n", $1);
      yyerror(error_str);
      ERROR = 1;
    }
    else asprintf(&$$, "pushg %d\n", sp);
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