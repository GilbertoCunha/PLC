%{
#include "translator.h"

int DEBUG, ERROR = 0;
int var_count = 0;
int else_count = 0;
AVLTree vars = NULL;
FILE *vm;

int yylex ();
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

Conditional : T_IF Expression T_START '\n' Instructions T_END '\n'                                     { ifInstr (&$$, $2, $5, &else_count); }
            | T_IF Expression T_START '\n' Instructions T_START T_ELSE T_START '\n' Instructions T_END { ifElse (&$$, $2, $5, $10, &else_count); }
            | T_IF Expression T_START '\n' Instructions T_START T_ELSE Conditional                     { ifElseif (&$$, $2, $5, $8, &else_count); }
            ;

Write : T_WRITE '(' '"' FString '"' ')' '\n'   { asprintf (&$$, "%s", $4, "\n"); }
      ;

FString : FString '{' Expression '}'     { asprintf (&$$, "%s%swritei\n", $1, $3); }
        | FString T_STR                  { asprintf (&$$, "%spushs \"%s\"\nwrites\n", $1, $2); }
        | '{' Expression '}'             { asprintf (&$$, "%swritei\n", $2); }
        | T_STR                          { asprintf (&$$, "pushs \"%s\"\nwrites\n", $1); }
        ;

Atribution : T_ID '=' Expression '\n'      { exprAtr (&$$, $1, $3, &vars, &ERROR); }
           | T_ID '=' T_READ '(' ')' '\n'  { readAtr (&$$, $1, &vars, &ERROR); }

Declarations : Declarations Declaration   { asprintf (&$$, "%s%s", $1, $2); }
             |                            { asprintf (&$$, "%s", ""); }
             ;

Declaration : T_INT T_ID '\n'                     { declaration (&$$, $2, &var_count, &vars); }   
            | T_INT T_ID '=' Expression '\n'      { declrExpr (&$$, $2, $4, &vars, &var_count, &ERROR); }
            | T_INT T_ID '=' T_READ '(' ')' '\n'  { declrRead (&$$, $2, &vars, &var_count, &ERROR); }
            | T_LCOM                              { asprintf (&$$, "%s", ""); }
            | T_MCOM                              { asprintf (&$$, "%s", ""); }
            | '\n'                                { asprintf (&$$, "%s", ""); }
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
     | Term '/' Term     { asprintf (&$$, "%s%sdiv\n", $1, $3); }
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
       | T_ID    { factorId (&$$, $1, &vars, &ERROR); }
       ;
%%

#include "lex.yy.c"

void yyerror (char *s) {
    fprintf (stderr,"Line: %d | Error: %s\n", yylineno, s);
}

int main(int argc, int *argv) {
    if (argc != 2) DEBUG = 0;
    else DEBUG = argv[0];

    vm = fopen ("program.vm", "w");

    printf ("-> Started parsing\n");
    yyparse ();
    fclose (vm);
    if (!ERROR) {
        printf ("-> Parsing complete with no compile time errors.\n");
        printf ("-> VM program generated\n");
    }
    else {
        system ("rm *.out lex.yy.c y.tab.h y.tab.c program.vm");
        printf ("\n-> VM program file deleted. Errors found while parsing.\n");
        printf ("-> Correct them in order to be able to run the program.\n");
    }

    if (DEBUG && !ERROR) {
            GraphAVLTree (vars);
            system ("rm *.out lex.yy.c y.tab.h y.tab.c *.dot");
            printf ("-> Debug mode detected. VM file kept and variables AVLTree image generated.\n");
        }
    else if (DEBUG && ERROR) {
        GraphAVLTree (vars);
        system ("rm *.dot");
    }
    else if (!DEBUG && !ERROR) system ("rm *.out lex.yy.c y.tab.c y.tab.h");

    return 0;
}