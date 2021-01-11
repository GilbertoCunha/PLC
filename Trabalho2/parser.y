%{
#include "translator.h"

int DEBUG, VERBOSE;
int ERROR = 0, SYNT_ERROR = 0;
int var_count = 0;
int func_count = 0;
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
%token <id> T_ID T_STR T_FSTR
%token <num> T_NUM

%token T_AND T_OR T_NOT
%token T_EQ T_NEQ T_GE T_LE

%token T_FOR T_IF T_ELSE
%token T_START T_END T_IB T_IE

%token T_READ T_WRITE
%token T_LCOM T_MCOM T_FSS

%left '<' '>' '+' '-' '*' '/' '%' 
%left T_AND T_OR T_NOT T_EQ T_NEQ T_GE T_LE

%type <inst> Declarations Declaration DeclList SingDecl
%type <inst> Instructions Instruction Atribution Write Conditional Cycle
%type <inst> Par Factor Term Expression FString

%start L

%%
L : Declarations T_IB Instructions T_IE { fprintf (vm, "%sstart\n%sstop", $1, $3); }
  | error '\n'
  ;

Instructions : Instructions Instruction { asprintf (&$$, "%s%s", $1, $2); }
             | error '\n'               { asprintf (&$$, "%s",""); }
             |                          { asprintf (&$$, "%s", ""); }
             ;

Instruction : Atribution     { asprintf (&$$, "%s", $1); }
            | Write          { asprintf (&$$, "%s", $1); }
            | Conditional    { asprintf (&$$, "%s", $1); }
            | Cycle          { asprintf (&$$, "%s", $1); }
            | T_LCOM         { asprintf (&$$, "%s", ""); }
            | T_MCOM         { asprintf (&$$, "%s", ""); }
            | '\n'           { asprintf (&$$, "%s", ""); }
            ;

Cycle : T_FOR '(' T_ID ',' Expression ',' Expression ')' T_START Instructions T_END { forStartEnd (&$$, $3, $5, $7, $10, &vars, &func_count); }
      | T_FOR '(' T_ID ',' Expression ',' Expression ',' Expression ')' T_START Instructions T_END { forStep (&$$, $3, $5, $7, $9, $12, &vars, &func_count); }
      ;

Conditional : T_IF Expression T_START '\n' Instructions T_END '\n'                                     { ifInstr (&$$, $2, $5, &func_count); }
            | T_IF Expression T_START '\n' Instructions T_START T_ELSE T_START '\n' Instructions T_END { ifElse (&$$, $2, $5, $10, &func_count); }
            | T_IF Expression T_START '\n' Instructions T_START T_ELSE Conditional                     { ifElseif (&$$, $2, $5, $8, &func_count); }
            ;

Write : T_WRITE '(' T_FSS FString '"' ')' '\n'   { asprintf (&$$, "%s", $4); }
      | T_WRITE '(' T_STR ')' '\n'               { asprintf (&$$, "pushs %s\nwrites\n", $3); }
      ;

FString : FString '{' Expression '}'     { asprintf (&$$, "%s%swritei\n", $1, $3); }
        | FString T_FSTR                 { asprintf (&$$, "%spushs \"%s\"\nwrites\n", $1, $2); }
        | '{' Expression '}'             { asprintf (&$$, "%swritei\n", $2); }
        | T_FSTR                         { asprintf (&$$, "pushs \"%s\"\nwrites\n", $1); }
        ;

Atribution : T_ID '=' Expression '\n'                               { exprAtr (&$$, $1, $3, &vars); }
           | T_ID '=' T_READ '(' ')' '\n'                           { readAtr (&$$, $1, &vars); }
           | T_ID '=' T_READ '(' T_STR ')' '\n'                     { readAtrStr (&$$, $1, $5, &vars); }
           | T_ID '[' Expression ']' '=' Expression '\n'            { arrayAtr (&$$, $1, $3, $6, &vars); }
           | T_ID '[' Expression ']' '=' T_READ '(' ')' '\n'        { readArrayAtr (&$$, $1, $3, &vars); }
           | T_ID '[' Expression ']' '=' T_READ '(' T_STR ')' '\n'  { readArrayAtrStr (&$$, $1, $3, $8, &vars); }
           ;

Declarations : Declarations Declaration   { asprintf (&$$, "%s%s", $1, $2); }
             | error '\n'                 { asprintf (&$$, "%s",""); }
             |                            { asprintf (&$$, "%s", ""); }
             ;

Declaration : T_INT DeclList       { asprintf (&$$, "%s", $2); }     
            | T_LCOM               { asprintf (&$$, "%s", ""); }
            | T_MCOM               { asprintf (&$$, "%s", ""); }
            | '\n'                 { asprintf (&$$, "%s", ""); }
            ;

DeclList : SingDecl ',' DeclList        { asprintf (&$$, "%s%s", $1, $3); }
         | SingDecl                     { asprintf (&$$, "%s", $1); }
         ;

SingDecl  : T_ID                                { declaration (&$$, $1, &var_count, &vars); }
          | T_ID '[' T_NUM ']'                  { declrArray (&$$, $1, $3, &var_count, &vars); }
          | T_ID '=' Expression                 { declrExpr (&$$, $1, $3, &vars, &var_count); }
          | T_ID '=' T_READ '(' ')'             { declrRead (&$$, $1, &vars, &var_count); }
          | T_ID '=' T_READ '(' T_STR ')'       { declrReadStr (&$$, $1, $5, &vars, &var_count); }
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

Factor : T_NUM                       { asprintf (&$$, "pushi %d\n", $1); }
       | T_ID                        { factorId (&$$, $1, &vars); }
       | T_ID '[' Expression ']'     { factorArray (&$$, $1, $3, &vars); }
       | '-' T_NUM                   { asprintf (&$$, "pushi %d\n", -$2); }
       | '-' T_ID                    { negfactorId (&$$, $2, &vars); }
       | '-' T_ID '[' Expression ']' { negfactorArray (&$$, $2, $4, &vars); }
       ;
%%

#include "lex.yy.c"

void yyerror (char *s) {
    if (!ERROR) printf ("\n%s\n", repeatChar ('-', 90));
    fprintf (stderr,"Line: %d | Error: %s\n", yylineno, s);
    printf ("%s\n", repeatChar ('-', 90));
    ERROR = 1;
}

int main(int argc, char **argv) {
    if (!strcmp (argv[1], "yes")) DEBUG = 1;
    else DEBUG = 0;
    if (!strcmp (argv[2], "yes")) VERBOSE = 1;
    else VERBOSE = 0;
    vm = fopen ("program.vm", "w");

    if (VERBOSE) printf ("-> Started parsing\n");
    yyparse ();
    fclose (vm);

    if (!ERROR && VERBOSE) {
        printf ("-> Parsing complete with no compile time errors.\n");
        printf ("-> VM program generated\n");
    }
    else if (ERROR && VERBOSE) {
        system ("rm program.vm");
        printf ("\n-> VM program file deleted. Errors found while parsing.\n");
        printf ("-> Correct them in order to be able to run the program.\n");
    }
    else if (ERROR) system ("rm program.vm");

    system ("rm a.out lex.yy.c y.tab.h y.tab.c");

    if (DEBUG && !ERROR) {
            GraphAVLTree (vars);
            system ("rm avl.dot");
            if (VERBOSE) printf ("-> Debug mode detected. VM file kept and variables AVLTree image generated.\n");
    }
    else if (DEBUG) {
        GraphAVLTree (vars);
        system ("rm avl.dot");
        if (VERBOSE) printf ("-> Debug mode detected. Variables AVLTree image generated.\n");
    }

    return 0;
}