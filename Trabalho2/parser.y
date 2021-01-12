%{
#include "translator.h"

int DEBUG, VERBOSE;
int ERROR = 0;
int sp_count = 0;
int func_count = 0;
int list_size = 0;
AVLTree vars = NULL;
FILE *vm;

int yylex ();
void yyerror (char *s);
%}
%error-verbose
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

%type <inst> declrs declr decllist singdecl list
%type <inst> instrs instr atr read write cond cycle
%type <inst> par factor term expr fstring string

%start L

%%

L : declrs T_IB instrs T_IE { fprintf (vm, "%sstart\n%sstop", $1, $3); }
  | error '\n'
  ;

endline : '\n'
        | ';'
        ;

instrs : instrs instr   { asprintf (&$$, "%s%s", $1, $2); }
       | error endline  { asprintf (&$$, "%s",""); }
       |                { asprintf (&$$, "%s", ""); }
       ;

instr : atr       { asprintf (&$$, "%s", $1); }
      | write     { asprintf (&$$, "%s", $1); }
      | cond      { asprintf (&$$, "%s", $1); }
      | cycle     { asprintf (&$$, "%s", $1); }
      | T_LCOM    { asprintf (&$$, "%s", ""); }
      | T_MCOM    { asprintf (&$$, "%s", ""); }
      | endline   { asprintf (&$$, "%s", ""); }
      ;

cycle : T_FOR '(' T_ID ',' expr ',' expr ')' T_START instrs T_END           { forStartEnd (&$$, $3, $5, $7, $10, &vars, &func_count); }
      | T_FOR '(' T_ID ',' expr ',' expr ',' expr ')' T_START instrs T_END  { forStep (&$$, $3, $5, $7, $9, $12, &vars, &func_count); }
      | T_FOR T_ID '-' '>' T_ID T_START instrs T_END                        { forArrayV(&$$, $2, $5, $7, &vars, &func_count); }
      | T_FOR '(' T_ID ',' T_ID ')' '-' '>' T_ID T_START instrs T_END       { forArrayIV(&$$, $3, $5, $9, $11, &vars, &func_count); }    
      ;

cond : T_IF expr T_START instrs T_END endline                         { ifInstr (&$$, $2, $4, &func_count); }
     | T_IF expr T_START instrs T_START T_ELSE T_START instrs T_END   { ifElse (&$$, $2, $4, $8, &func_count); }
     | T_IF expr T_START instrs T_START T_ELSE cond                   { ifElseif (&$$, $2, $4, $7, &func_count); }
     ;

write : T_WRITE '(' string ')' endline   { asprintf (&$$, "%s", $3); }
      ;

read : T_READ '(' string ')' endline     { asprintf (&$$, "%s", $3); }
     ;

string : T_FSS fstring '"'    { asprintf (&$$, "%s", $2); }
       | T_STR                { asprintf (&$$, "pushs %s\nwrites\n", $1); }
       |                      { asprintf (&$$, "%s", ""); }
       ;

fstring : fstring '{' expr '}'     { asprintf (&$$, "%s%swritei\n", $1, $3); }
        | fstring T_FSTR           { asprintf (&$$, "%spushs \"%s\"\nwrites\n", $1, $2); }
        | '{' expr '}'             { asprintf (&$$, "%swritei\n", $2); }
        | T_FSTR                   { asprintf (&$$, "pushs \"%s\"\nwrites\n", $1); }
        ;

atr : T_ID '=' expr endline                 { exprAtr (&$$, $1, $3, &vars); }
    | T_ID '=' read                         { readAtr (&$$, $1, $3, &vars); }
    | T_ID '[' expr ']' '=' expr endline    { arrayAtr (&$$, $1, $3, $6, &vars); }
    | T_ID '[' expr ']' '=' read            { readArrayAtr (&$$, $1, $3, $6, &vars); }
    ;

declrs : declrs declr    { asprintf (&$$, "%s%s", $1, $2); }
       | error endline   { asprintf (&$$, "%s",""); }
       |                 { asprintf (&$$, "%s", ""); }
       ;

declr : T_INT decllist    { asprintf (&$$, "%s", $2); }     
      | T_LCOM            { asprintf (&$$, "%s", ""); }
      | T_MCOM            { asprintf (&$$, "%s", ""); }
      | endline           { asprintf (&$$, "%s", ""); }
      ;

decllist : singdecl ',' decllist    { asprintf (&$$, "%s%s", $1, $3); }
         | singdecl                 { asprintf (&$$, "%s", $1); }
         ;

singdecl : T_ID                                    { declaration (&$$, $1, &sp_count, &vars); }
         | T_ID '[' T_NUM ']'                      { declrArray (&$$, $1, $3, &sp_count, &vars); }
         | T_ID '=' expr                           { declrExpr (&$$, $1, $3, &vars, &sp_count); }
         | T_ID '=' read                           { declrRead (&$$, $1, $3, &vars, &sp_count); }
         | T_ID '[' T_NUM ']' '=' '[' list ']'     { decList (&$$, $1, $3, $7, &vars, &sp_count, &list_size); }     
         ;

list : expr ',' list          { asprintf (&$$, "%s%s", $1, $3); list_size++; }
     | expr                   { asprintf (&$$, "%s", $1); list_size++; }
     ;

expr : expr T_EQ expr     { asprintf (&$$, "%s%sequal\n", $1, $3); }
     | expr T_NEQ expr    { asprintf (&$$, "%s%sequal\nnot\n", $1, $3); }
     | expr T_GE expr     { asprintf (&$$, "%s%ssupeq\n", $1, $3); }
     | expr T_LE expr     { asprintf (&$$, "%s%sinfeq\n", $1, $3); }
     | expr '>' expr      { asprintf (&$$, "%s%ssup\n", $1, $3); }
     | expr '<' expr      { asprintf (&$$, "%s%sinf\n", $1, $3); }
     | expr '+' term      { asprintf (&$$, "%s%sadd\n", $1, $3); }
     | expr '-' term      { asprintf (&$$, "%s%ssub\n", $1, $3); }
     | term               { asprintf (&$$, "%s", $1); }
     ;

term : term '*' term      { asprintf (&$$, "%s%smul\n", $1, $3); }
     | term '/' term      { asprintf (&$$, "%s%sdiv\n", $1, $3); }
     | term '%' term      { asprintf (&$$, "%s%smod\n", $1, $3); }
     | term T_AND term    { asprintf (&$$, "%snot\nnot\n%snot\nnot\nmul\n", $1, $3); }
     | term T_OR term     { asprintf (&$$, "%snot\n%snot\nmul\nnot\n", $1, $3); }
     | T_NOT term         { asprintf (&$$, "%snot\n", $2); }
     | par                { asprintf (&$$, "%s", $1); }
     ;

par : '(' expr ')'        { asprintf (&$$, "%s", $2); }
    | factor              { asprintf (&$$, "%s", $1); }
    ;

factor : T_NUM                    { asprintf (&$$, "pushi %d\n", $1); }
       | T_ID                     { factorId (&$$, $1, &vars); }
       | T_ID '[' expr ']'        { factorArray (&$$, $1, $3, &vars); }
       | '-' T_NUM                { asprintf (&$$, "pushi %d\n", -$2); }
       | '-' T_ID                 { negfactorId (&$$, $2, &vars); }
       | '-' T_ID '[' expr ']'    { negfactorArray (&$$, $2, $4, &vars); }
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