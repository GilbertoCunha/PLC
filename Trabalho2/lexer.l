%{
#include <stdio.h>
%}

DIGIT [0-9]
LETTER [a-zA-Z]
SYMBS [\+\-\*\/\{\}\[\]\(\)!<>\\\;]

%x STRING
%option noyywrap

%%
^int\               { printf ("T_INT "); } 
^for\               { printf ("T_FOR "); } 
[\t\ ]+for\         { printf ("T_FOR "); } 
\ \:\:[\ \n]        { printf ("T_START "); } 
^\:\;[\ \n]         { printf ("T_END "); } 
[\ \n]+\:\;[\ \n]   { printf ("T_END "); } 
^if\                { printf ("T_IF "); } 
[\t\ ]+if\          { printf ("T_IF "); } 
^else[\ \n]         { printf ("T_ELSE "); } 
[\t\ ]+else[\ \n]   { printf ("T_ELSE "); }
{DIGIT}+            { printf ("T_NUM "); } 
{LETTER}+           { printf ("T_ID "); } 
\"                  { printf ("\" "); BEGIN STRING; } 
[ ]                 { printf (" "); } 
(.|\n)              { printf ("%c ", yytext[0]); } 

<STRING>\"          { printf ("\" "); BEGIN INITIAL; } 
<STRING>(.|\n)      { printf ("%c", yytext[0]); } 
%%

int main () {
    yylex ();
    return 0;
}
