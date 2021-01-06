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
%locations

%union {
  int num;
  char *id;
  char *inst;
}

%token <id> T_ID
%token <num> T_NUM
%token <id> T_STR
%token T_INT
%token T_FOR
%token T_START T_END
%token T_IF T_ELSE
%token T_AND T_OR T_NOT
%token T_READ T_WRITE
%token T_ERROR

%type <inst> Declarations Declaration
%type <inst> Instructions Instruction Atribution Write
%type <inst> Par Factor Term Expression FString
%start L

%%
L : Declarations '%' Instructions '%' { fprintf (vm, "%sstart\n%sstop", $1, $3); }
  |
  ;

Instructions : Instructions Instruction { asprintf (&$$, "%s%s", $1, $2); }
             |                          { asprintf (&$$, "%s", ""); }
             ;

Instruction : Atribution    { asprintf (&$$, "%s", $1); }
            | Write         { asprintf (&$$, "%s", $1); }
            ;

Write : T_WRITE '"' FString '"' ')' ';'   { asprintf (&$$, "%s", $3, "\n"); }
      ;

FString : FString '{' Expression '}'     { asprintf (&$$, "%s%swritei\n", $1, $3); }
        | FString T_STR                  { asprintf (&$$, "%spushs \"%s\"\nwrites\n", $1, $2); }
        | '{' Expression '}'             { asprintf (&$$, "%swritei\n", $2); }
        | T_STR                          { asprintf (&$$, "pushs \"%s\"\nwrites\n", $1); }
        ;

Atribution : T_ID '=' Expression ';'      {
    int sp;
    char *varname = get_varname($1);
    int index = array_size($1);
    if (!searchAVL(vars, varname, &sp)) {
        char *error_str;
        asprintf (&error_str, "Can't assign to variable \"%s\" because it hasn't been declared\n", $1);
        yyerror(error_str);
        ERROR = 1;
    }
    else if (index == -1) asprintf (&$$, "%sstoreg %d\n", $3, sp);
    else asprintf (&$$, "pushgp\npushi %d\npadd\npushi %d\n%sstoren\n", sp, index, $3);
}
            | T_ID '=' T_READ ')' ';'    {
    int sp;
    char *varname = get_varname($1);
    int size = array_size($1);
    if (!searchAVL (vars, varname, &sp)) { 
        char *error_str;
        asprintf (&error_str, "Variable \"%s\" has not yet been declared\n", $1);
        yyerror(error_str);
        ERROR = 1;
    }
    else if (size == -1) asprintf (&$$, "read\natoi\nstoreg %d\n", sp);
    else {
        yyerror ("Can't assign integer to array\n");
        ERROR = 1;
    }
}

Declarations : Declarations Declaration   { asprintf (&$$, "%s%s", $1, $2); }
             |                            { asprintf (&$$, "%s", ""); }
             ;

Declaration : T_INT T_ID ';'              {
    int size = array_size ($2);
    char *varname = get_varname($2);
    if (size == -1) {
        insertAVL (&vars, varname, "int", var_count++);
        asprintf (&$$, "pushn 1\n");
    }
    else {
        insertAVL (&vars, varname, "array", var_count);
        asprintf (&$$, "pushn %d\n", size);
        var_count += size;
    }
}   
            | T_INT T_ID '=' Expression ';'            {
    int size = array_size($2);
    char *varname = get_varname($2);
    if (size == -1) {
        insertAVL (&vars, varname, "int", var_count);
        asprintf (&$$, "pushn 1\n%sstoreg %d\n", $4, var_count++);
    }
    else {
        yyerror ("Can't declare and assign to array\n");
        ERROR = 1;
    }
}
            | T_INT T_ID '=' T_READ ')' ';'                     {
    int size = array_size($2);
    char *varname = get_varname($2);
    if (size == -1) {
        insertAVL (&vars, varname, "int", var_count);
        asprintf (&$$, "pushn 1\nread\natoi\nstoreg %d\n", var_count++);;
    }
    else {
        yyerror ("Can't assign integer to array\n");
        ERROR = 1;
    }
}
            ;

Expression : Expression '=' '=' Expression  { asprintf (&$$, "%s%sequal\n", $1, $4); }
           | Expression '!' '=' Expression  { asprintf (&$$, "%s%sequal\nnot\n", $1, $4); }
           | Expression '>' '=' Expression  { asprintf (&$$, "%s%ssupeq\n", $1, $4); }
           | Expression '<' '=' Expression  { asprintf (&$$, "%s%sinfeq\n", $1, $4); }
           | Expression '>' Expression      { asprintf (&$$, "%s%ssup\n", $1, $3); }
           | Expression '<' Expression      { asprintf (&$$, "%s%sinf\n", $1, $3); }
           | Expression '+' Term            { asprintf (&$$, "%s%sadd\n", $1, $3); }
           | Expression '-' Term            { asprintf (&$$, "%s%ssub\n", $1, $3); }
           | Term                           { asprintf (&$$, "%s", $1); }
           ;

Term : Term '*' Par  { asprintf (&$$, "%s%smul\n", $1, $3); }
     | Term '/' Par  { 
    if ($3 == 0) {
      yyerror("Division by zero!\n");
      ERROR = 1;
    }
    else asprintf (&$$, "%s%sdiv\n", $1, $3);
}
     | Term '%' Par     { asprintf (&$$, "%s%smod\n", $1, $3); }
     | Term T_AND Par   { asprintf (&$$, "%snot\nnot\n%snot\nnot\nmul\n", $1, $3); }
     | Term T_OR Par    { asprintf (&$$, "%snot\n%snot\nmul\nnot\n", $1, $3); }
     | T_NOT Par        { asprintf (&$$, "%snot\n", $2); }
     | Par              { asprintf (&$$, "%s", $1); }
     ;

Par : '(' Expression ')'    { asprintf (&$$, "%s", $2); }
    | Factor                { asprintf (&$$, "%s", $1); }
    ;

Factor : T_NUM   { asprintf (&$$, "pushi %d\n", $1); }
       | T_ID    {
    int sp;
    char *varname = get_varname($1);
    int index = array_size($1);
    if (!searchAVL (vars, varname, &sp)) { 
        char *error_str;
        asprintf (&error_str, "Variable \"%s\" has not yet been declared\n", $1);
        yyerror(error_str);
        ERROR = 1;
    } 
    else if (index == -1) asprintf(&$$, "pushg %d\n", sp);
    else asprintf(&$$, "pushgp\npushi %d\npadd\npushi %d\nload\n", sp, index);
}
       ;
%%

#include "lex.yy.c"

void yyerror (char *s) {
    fprintf (stderr,"Line: %d | Error: %s\n", yylineno, s);
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