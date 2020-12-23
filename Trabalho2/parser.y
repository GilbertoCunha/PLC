%{
#include <stdio.h>

int yylex();
void yyerror(char *s);
%}

%token T_ID T_NUM T_INT
%token T_FOR T_DO
%token T_IF T_THEN T_ELSE
%token T_ERROR

%%
L : 
  ;
%%
#include "lex.yy.c"

void yyerror (char *s) {
    fprintf (stderr,"Error: %s\n",s);
}

int main() {
    printf ("Started parsing\n");
    // yyparse ();
    yylex ();
    printf ("Parsing COMPLETED\n");
    return 0;
}
