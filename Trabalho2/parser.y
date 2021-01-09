%{
#include <stdio.h>
#include "AVLTrees.h"
#include "aux.h"

int ERROR = 0;
int var_count = 0;
int else_count = 0;
AVLTree vars = NULL;
FILE *vm;

int yylex ();
void myyyerror (char *l, char *s);
void yyerror (char *s);
%}
%locations

%union {
  int num;
  char *id;
  char *inst;
}

%token T_INT
%token <id> T_ID
%token <num> T_NUM
%token <id> T_STR

%token T_AND T_OR T_NOT
%token T_EQ T_NEQ T_GE T_LE

%token T_FOR T_IF T_ELSE
%token T_START T_END

%token T_READ T_WRITE
%token T_LCOM T_MCOM
%token T_ERROR

%left '<' '>' '+' '-' '*' '/' '%' 
%left T_AND T_OR T_NOT T_EQ T_NEQ T_GE T_LE

%type <inst> Declarations Declaration
%type <inst> Instructions Instruction Atribution Write Conditional
%type <inst> Par Factor Term Expression FString

%start L

%%
L : Declarations '%' Instructions '%' { fprintf (vm, "%sstart\n%sstop", $1, $3); }
  |
  ;

Instructions : Instructions Instruction { asprintf (&$$, "%s%s", $1, $2); }
             |                          { asprintf (&$$, "%s", ""); }
             ;

Instruction : Atribution     { asprintf (&$$, "%s", $1); }
            | Write          { asprintf (&$$, "%s", $1); }
            | Conditional    { asprintf (&$$, "%s", $1); }
            | T_LCOM         { asprintf (&$$, "%s", ""); }
            | T_MCOM         { asprintf (&$$, "%s", ""); }
            | '\n'           { asprintf (&$$, "%s", ""); }
            ;

Conditional : T_IF Expression T_START '\n' Instructions T_END '\n' { 
    asprintf (&$$, "%sjz else%d\n%selse%d:\n", $2, else_count, $5, else_count);
    else_count++;
}
            ;

Write : T_WRITE '(' '"' FString '"' ')' '\n'   { asprintf (&$$, "%s", $4, "\n"); }
      ;

FString : FString '{' Expression '}'     { asprintf (&$$, "%s%swritei\n", $1, $3); }
        | FString T_STR                  { asprintf (&$$, "%spushs \"%s\"\nwrites\n", $1, $2); }
        | '{' Expression '}'             { asprintf (&$$, "%swritei\n", $2); }
        | T_STR                          { asprintf (&$$, "pushs \"%s\"\nwrites\n", $1); }
        ;

Atribution : T_ID '=' Expression '\n'      {
    int sp, size;
    char *varname = get_varname($1);
    int index = array_size($1);
    searchAVLsize (vars, varname, &size);
    if (searchAVLsp (vars, varname, &sp) == -1) {
        char *error_str;
        asprintf (&error_str, "Can't assign to variable \"%s\" because it hasn't been declared", $1);
        myyyerror(&$$, error_str);
    }
    else if (index == -1) asprintf (&$$, "%sstoreg %d\n", $3, sp);
    else if (index < size) asprintf (&$$, "pushgp\npushi %d\npadd\npushi %d\n%sstoren\n", sp, index, $3);
    else myyyerror (&$$, "Index out of range");
}
            | T_ID '=' T_READ '(' ')' '\n'    {
    int sp;
    char *varname = get_varname($1);
    int index = array_size($1);
    if (searchAVLsp (vars, varname, &sp) == -1) { 
        char *error_str;
        asprintf (&error_str, "Variable \"%s\" has not yet been declared", $1);
        myyyerror(&$$, error_str);
    }
    else if (index == -1) asprintf (&$$, "read\natoi\nstoreg %d\n", sp);
    else myyyerror (&$$, "Can't assign integer to array");
}

Declarations : Declarations Declaration   { asprintf (&$$, "%s%s", $1, $2); }
             |                            { asprintf (&$$, "%s", ""); }
             ;

Declaration : T_INT T_ID '\n'              {
    int size = array_size ($2);
    char *varname = get_varname($2);
    if (size == -1) {
        insertAVL (&vars, varname, "int", size, var_count++);
        asprintf (&$$, "pushn 1\n");
    }
    else {
        insertAVL (&vars, varname, "array", size, var_count);
        asprintf (&$$, "pushn %d\n", size);
        var_count += size;
    }
}   
            | T_INT T_ID '=' Expression '\n'            {
    int size = array_size($2);
    char *varname = get_varname($2);
    if (size == -1) {
        insertAVL (&vars, varname, "int", size, var_count);
        asprintf (&$$, "pushn 1\n%sstoreg %d\n", $4, var_count++);
    }
    else myyyerror (&$$, "Can't declare and assign to array");
}
            | T_INT T_ID '=' T_READ '(' ')' '\n'        {
    int size = array_size($2);
    char *varname = get_varname($2);
    if (size == -1) {
        insertAVL (&vars, varname, "int", size, var_count);
        asprintf (&$$, "pushn 1\nread\natoi\nstoreg %d\n", var_count++);;
    }
    else myyyerror (&$$, "Can't assign integer to array");
}
            | T_LCOM          { asprintf (&$$, "%s", ""); }
            | T_MCOM          { asprintf (&$$, "%s", ""); }
            | '\n'            { asprintf (&$$, "%s", ""); }
            ;

Expression : Expression T_EQ Expression     { asprintf (&$$, "%s%sequal\n", $1, $3); }
           | Expression T_NEQ Expression    { asprintf (&$$, "%s%sequal\nnot\n", $1, $3); }
           | Expression T_GE Expression     { asprintf (&$$, "%s%ssupeq\n", $1, $3); }
           | Expression T_LE Expression     { asprintf (&$$, "%s%sinfeq\n", $1, $3); }
           | Expression '>' Expression      { asprintf (&$$, "%s%ssup\n", $1, $3); }
           | Expression '<' Expression      { asprintf (&$$, "%s%sinf\n", $1, $3); }
           | Expression '+' Term            { asprintf (&$$, "%s%sadd\n", $1, $3); }
           | Expression '-' Term            { asprintf (&$$, "%s%ssub\n", $1, $3); }
           | Term                           { asprintf (&$$, "%s", $1); }
           ;

Term : Term '*' Term     { asprintf (&$$, "%s%smul\n", $1, $3); }
     | Term '/' Term     { 
                            if ($3 == 0) myyyerror (&$$, "Division by zero!");
                            else asprintf (&$$, "%s%sdiv\n", $1, $3);
                         }
     | Term '%' Term     { asprintf (&$$, "%s%smod\n", $1, $3); }
     | Term T_AND Term   { asprintf (&$$, "%snot\nnot\n%snot\nnot\nmul\n", $1, $3); }
     | Term T_OR Term    { asprintf (&$$, "%snot\n%snot\nmul\nnot\n", $1, $3); }
     | T_NOT Term        { asprintf (&$$, "%snot\n", $2); }
     | Par               { asprintf (&$$, "%s", $1); }
     ;

Par : '(' Expression ')'    { asprintf (&$$, "%s", $2); }
    | Factor                { asprintf (&$$, "%s", $1); }
    ;

Factor : T_NUM   { asprintf (&$$, "pushi %d\n", $1); }
       | T_ID    {
    int sp, size;
    char *varname = get_varname($1);
    int index = array_size($1);
    searchAVLsize(vars, varname, &size);
    if (searchAVLsp (vars, varname, &sp) == -1) {
        char *error_str;
        asprintf (&error_str, "Variable \"%s\" has not yet been declared", $1);
        myyyerror(&$$, error_str);
    } 
    else if (index == -1) asprintf(&$$, "pushg %d\n", sp);
    else if (index < size) asprintf(&$$, "pushgp\npushi %d\npadd\npushi %d\nload\n", sp, index);
    else myyyerror(&$$, "Index out of range");
}
       ;
%%

#include "lex.yy.c"

void myyyerror (char *L, char *s) {
    asprintf (L, "%s", "");
    yyerror (s);
    ERROR = 1;
}

void yyerror (char *s) {
    fprintf (stderr,"Line: %d | Error: %s\n", yylineno, s);
}

int main() {
    vm = fopen ("program.vm", "w");

    printf ("-> Started parsing\n");
    yyparse ();

    if (!ERROR) printf ("-> Parsing complete without errors.\n");

    GraphAVLTree (vars);
    fclose (vm);

    if (!ERROR) printf ("-> Program file succesfully generated.\n");
    else {
        system ("make parser_error");
        printf ("-> Generated program file deleted. Errors found while parsing.\n");
        printf ("-> Correct them in order to be able to run the program.\n");

    }
    return 0;
}