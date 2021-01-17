%{
#include "translator.h"

int DEBUG, VERBOSE;
int ERROR = 0, FUNC = 0;
int sp_count = 0;
int fcount = 0;
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

%token INT VOID
%token <id> ID STR FSTR
%token <num> NUM

%token AND OR NOT
%token EQ NEQ GE LE

%token FOR IF ELSE
%token START END

%token MAIN READ WRITE
%token FSS

%type <inst> main funcs declrs declr decllist singdecl list
%type <inst> instrs instr atr read write cond cycle fcall
%type <inst> par factor term expr lexpr arithm fstring string

%start L

%%

L : declrs START funcs '|' main END { fprintf (vm, "%sstart\n%sstop\n%s", $1, $5, $3); }
  | declrs '|' main END             { fprintf (vm, "%sstart\n%sstop\n", $1, $3); }
  | error '\n'
  ;

endline : '\n' | ';' ;

main : '|' MAIN '|' '|' instrs      { asprintf (&$$, "%s", $5); }
     ;

funcs : START VOID ID START instrs END funcs    { declrFunc (&$$, $3, $5, $7, &vars, "void"); }
      | VOID ID START instrs END funcs          { declrFunc (&$$, $2, $4, $6, &vars, "void"); }
      | '\n' funcs                              { asprintf (&$$, "%s", $2); }
      | error endline                           { asprintf (&$$, "%s", ""); }
      |                                         { asprintf (&$$, "%s", ""); }
      ;

instrs : instrs instr   { asprintf (&$$, "%s%s", $1, $2); }
       | error endline  { asprintf (&$$, "%s",""); }
       |                { asprintf (&$$, "%s", ""); }
       ;

instr : atr endline      { asprintf (&$$, "%s", $1); }
      | write endline    { asprintf (&$$, "%s", $1); }
      | cond endline     { asprintf (&$$, "%s", $1); }
      | cycle endline    { asprintf (&$$, "%s", $1); }
      | fcall endline    { asprintf (&$$, "%s", $1); }
      | '\n'             { asprintf (&$$, "%s", ""); }
      ;

fcall : ID '(' ')'            { funcCall (&$$, $1, &vars); }
      ;

cycle : FOR '(' ID ',' expr ',' expr ')' START instrs END                  { forStartEnd (&$$, $3, $5, $7, $10, &vars, &fcount); }
      | FOR '(' ID ',' expr ',' expr ',' expr ')' START instrs END         { forStep (&$$, $3, $5, $7, $9, $12, &vars, &fcount); }
      | FOR '(' ID ',' ID ')' '-' '>' ID START instrs END                  { forArrayIV (&$$, $3, $5, $9, $11, &vars, &fcount); }    
      | FOR '(' ID '=' expr ',' expr ',' ID '=' expr ')' START instrs END  { forCond (&$$, $3, $9, $5, $7, $11, $14, &vars, &fcount); }
      ;

cond : IF expr START instrs END                          { ifInstr (&$$, $2, $4, &fcount); }
     | IF expr START instrs START ELSE START instrs END  { ifElse (&$$, $2, $4, $8, &fcount); }
     | IF expr START instrs START ELSE cond              { ifElseif (&$$, $2, $4, $7, &fcount); }
     ;

write : WRITE '(' string ')'   { asprintf (&$$, "%s", $3); }
      ;

read : READ '(' string ')'     { asprintf (&$$, "%sread\natoi\n", $3); }
     ;

string : FSS fstring '"'    { asprintf (&$$, "%s", $2); }
       | STR                { asprintf (&$$, "pushs %s\nwrites\n", $1); }
       |                    { asprintf (&$$, "%s", ""); }
       ;

fstring : fstring '{' expr '}'   { asprintf (&$$, "%s%swritei\n", $1, $3); }
        | fstring FSTR           { asprintf (&$$, "%spushs \"%s\"\nwrites\n", $1, $2); }
        | '{' expr '}'           { asprintf (&$$, "%swritei\n", $2); }
        | FSTR                   { asprintf (&$$, "pushs \"%s\"\nwrites\n", $1); }
        ;

atr : ID '=' expr                 { exprAtr (&$$, $1, $3, &vars); }
    | ID '=' read                 { readAtr (&$$, $1, $3, &vars); }
    | ID '[' expr ']' '=' expr    { arrayAtr (&$$, $1, $3, $6, &vars, &fcount, @3.first_line); }
    | ID '[' expr ']' '=' read    { readArrayAtr (&$$, $1, $3, $6, &vars, &fcount, @3.first_line); }
    ;

declrs : declrs declr    { asprintf (&$$, "%s%s", $1, $2); }
       | error endline   { asprintf (&$$, "%s", ""); }
       |                 { asprintf (&$$, "%s", ""); }
       ;

declr : INT decllist endline       { asprintf (&$$, "%s", $2); }
      | '\n'                       { asprintf (&$$, "%s", ""); }
      ;

decllist : singdecl ',' decllist   { asprintf (&$$, "%s%s", $1, $3); }
         | singdecl                { asprintf (&$$, "%s", $1); }
         ;

singdecl : ID                                  { declaration (&$$, $1, &sp_count, &vars); }
         | ID '[' NUM ']'                      { declrArray (&$$, $1, $3, &sp_count, &vars); }
         | ID '=' expr                         { declrExpr (&$$, $1, $3, &vars, &sp_count); }
         | ID '=' read                         { declrRead (&$$, $1, $3, &vars, &sp_count); }
         | ID '[' NUM ']' '=' '[' list ']'     { decList (&$$, $1, $3, $7, &vars, &sp_count, &list_size); }     
         ;

list : expr ',' list          { asprintf (&$$, "%s%s", $1, $3); list_size++; }
     | expr                   { asprintf (&$$, "%s", $1); list_size++; }
     ;

expr : expr AND lexpr    { asprintf (&$$, "%sdup 1\njz func%d\n%smul\nfunc%d:\n", $1, fcount, $3, fcount); fcount++; }
     | expr OR lexpr     { asprintf (&$$, "%snot\ndup 1\njz func%d\n%snot\nmul\nnot\nfunc%d:\n", $1, fcount, $3, fcount); fcount++; }
     | NOT lexpr         { asprintf (&$$, "%snot\n", $2); }
     | lexpr             { asprintf (&$$, "%s", $1); }
     ;

lexpr : lexpr EQ arithm     { asprintf (&$$, "%s%sequal\n", $1, $3); }
      | lexpr NEQ arithm    { asprintf (&$$, "%s%sequal\nnot\n", $1, $3); }
      | lexpr GE arithm     { asprintf (&$$, "%s%ssupeq\n", $1, $3); }
      | lexpr LE arithm     { asprintf (&$$, "%s%sinfeq\n", $1, $3); }
      | lexpr '>' arithm    { asprintf (&$$, "%s%ssup\n", $1, $3); }
      | lexpr '<' arithm    { asprintf (&$$, "%s%sinf\n", $1, $3); }
      | arithm              { asprintf (&$$, "%s", $1); }
      ;

arithm : arithm '+' term    { asprintf (&$$, "%s%sadd\n", $1, $3); }
       | arithm '-' term    { asprintf (&$$, "%s%ssub\n", $1, $3); }
       | term               { asprintf (&$$, "%s", $1); }
       ;

term : term '*' par    { asprintf (&$$, "%s%smul\n", $1, $3); }
     | term '/' par    { asprintf (&$$, "%s%sdiv\n", $1, $3); }
     | term '%' par    { asprintf (&$$, "%s%smod\n", $1, $3); }
     | par             { asprintf (&$$, "%s", $1); }
     ;

par : '(' expr ')'        { asprintf (&$$, "%s", $2); }
    | factor              { asprintf (&$$, "%s", $1); }
    ;

factor : NUM                    { asprintf (&$$, "pushi %d\n", $1); }
       | ID                     { factorId (&$$, $1, &vars); }
       | ID '[' expr ']'        { factorArray (&$$, $1, $3, &vars, &fcount, @3.last_line); }
       | '-' NUM                { asprintf (&$$, "pushi %d\n", -$2); }
       | '-' ID                 { negfactorId (&$$, $2, &vars); }
       | '-' ID '[' expr ']'    { negfactorArray (&$$, $2, $4, &vars, &fcount, @3.first_line); }
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