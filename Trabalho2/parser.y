%{
#include <stdio.h>
#include "AVLTrees.h"
#include "aux.h"

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
%type <inst> Instruction Atribution Write String
%type <inst> Par Factor Term Expression
%start L

%%
L : Declarations Instructions
  |
  ;

Instructions : Instructions Instruction { if (!ERROR) fprintf (vm, "%s", $2); }
             |
             ;

Instruction : Atribution    { if (!ERROR) asprintf (&$$, "%s", $1); }
            | Write         { if (!ERROR) asprintf (&$$, "%s", $1); }
            ;

Write : T_WRITE '"' String '"' ')'      { if (!ERROR) asprintf (&$$, "pushs %s\nwrites\n", $3); }
      | T_WRITE Expression ')'          { if (!ERROR) asprintf (&$$, "%swritei\n", $2); }
      ;

String : 
       ;

Atribution : T_ID '=' Expression ';'      {
    if (!ERROR) {
        int sp;
        char varname[50];
        T_ID_to_str ($1, varname);
        if (!searchAVL(vars, varname, &sp)) {
          ERROR = 1;
          char *error_str;
          asprintf (&error_str, "Can't assign to variable \"%s\" because it hasn't been declared\n", $1);
          yyerror(error_str);
        }
        else asprintf (&$$, "%sstoreg %d\n", $3, sp);
    }
}
            | T_ID '=' T_READ ')' ';'    {
    if (!ERROR) {
        int sp;
        char varname[50];
        T_ID_to_str ($1, varname);
        if (!searchAVL (vars, varname, &sp)) { 
            char *error_str;
            asprintf (&error_str, "Variable \"%s\" has not yet been declared\n", $1);
            yyerror(error_str);
            ERROR = 1;
        }
        else asprintf (&$$, "read\natoi\nstoreg %d\n", sp);
    }
}

Declarations : Declarations Declaration   { if (!ERROR) fprintf (vm, "%s", $2); }
             | 
             ;

Declaration : T_INT T_ID ';'              { 
    if (!ERROR) {
        int size = array_size ($2);
        char *varname;
        for (int i=0; i<size; ++i) {
          varname = strdup (array_pos_name($2, i));
          insertAVL (&vars, varname, var_count++);
        }
        asprintf (&$$, "pushn %d\n", size);
    }
}   
            | T_INT T_ID '=' Expression ';'            {
    char varname[50];
    T_ID_to_str ($2, varname);
    if (strchr (varname, "[") != NULL) ERROR = 1;
    if (!ERROR) {
        insertAVL (&vars, varname, var_count);
        asprintf (&$$, "pushn 1\n%sstoreg %d\n", $4, var_count++);
    }
}
            | T_INT T_ID '=' T_READ ')' ';'                     {
    if (strchr ($2, "[") != NULL) ERROR = 1;
    if (!ERROR) {
        char varname[50];
        T_ID_to_str ($2, varname);
        insertAVL (&vars, varname, var_count);
        asprintf (&$$, "pushn 1\nread\natoi\nstoreg %d\n", var_count++);
    }
    else yyerror ("Can't assign integer to array\n");
}
            ;

Expression : Expression '+' Term  { if (!ERROR) asprintf (&$$, "%s%sadd\n", $1, $3); }
           | Expression '-' Term  { if (!ERROR) asprintf (&$$, "%s%ssub\n", $1, $3); }
           | Term                 { if (!ERROR) asprintf (&$$, "%s", $1); }
           ;

Term : Term '*' Par  { if (!ERROR) asprintf (&$$, "%s%smul\n", $1, $3); }
     | Term '/' Par  { 
    if ($3 == 0) {
      yyerror("Division by zero!\n");
      ERROR = 1;
    }
    else if (!ERROR) asprintf (&$$, "%s%sdiv\n", $1, $3);
}
     | Par           { if (!ERROR) asprintf (&$$, "%s", $1); }
     ;

Par : '(' Expression ')'    { if (!ERROR) asprintf (&$$, "%s", $2); }
    | Factor                { if (!ERROR) asprintf (&$$, "%s", $1); }
    ;

Factor : T_NUM   { asprintf (&$$, "pushi %d\n", $1); }
       | T_ID    {
    int sp;
    char varname[50];
    T_ID_to_str ($1, varname);
    if (!searchAVL (vars, varname, &sp)) { 
        char *error_str;
        asprintf (&error_str, "Variable \"%s\" has not yet been declared\n", $1);
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