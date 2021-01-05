%{
#include <stdio.h>
%}

DIGIT [0-9]
LETTER [a-zA-Z]
OPERATION [\+\(\)\*\-\/]
SYMBS [\+\-\*\/\{\}\[\]\(\)!<>\\\;]

%x STRING FSTRING
%option noyywrap

%%
^int\                                       { printf("T_INT ");  } 
^for\                                       { printf("T_FOR "); } 
[\t\ ]+for\                                 { printf("T_FOR "); } 
\ \:\:[\ \n]                                { printf("T_START "); } 
^\:\;[\ \n]                                 { printf("T_END "); } 
[\ \n]+\:\;[\ \n]                           { printf("T_END "); } 
^if\                                        { printf("T_IF "); } 
[\t\ ]+if\                                  { printf("T_IF "); } 
^else[\ \n]                                 { printf("T_ELSE "); } 
[\t\ ]+else[\ \n]                           { printf("T_ELSE "); } 
[ ]or[ ]                                    { printf("T_OR "); } 
[ ]and[ ]                                   { printf("T_AND "); } 
[ ]not                                      { printf("T_NOT "); } 
read\ *\(                                   { printf("T_READ "); } 
write\ *\(                                  { printf("T_WRITE "); } 
{DIGIT}+                                    { printf("T_NUM "); } 
{LETTER}+_*{LETTER}*{DIGIT}*\[{DIGIT}+\]    { printf("T_ID "); } 
{LETTER}+_*{LETTER}*{DIGIT}*                { printf("T_ID "); } 
\"                                          { BEGIN STRING; printf("%c ", yytext[0]); } 
[\ \n\t\r]                                  { ; } 
.                                           { printf("%c ", yytext[0]); } 

<STRING>\"                                          { BEGIN INITIAL; printf("%c ", yytext[0]); }
<STRING>\{                                          { BEGIN FSTRING; printf("%c ", yytext[0]); }
<STRING>[^\{\"]*                                    { printf("T_STR "); }

<FSTRING>\}                                         { BEGIN STRING; printf("%c ", yytext[0]); }
<FSTRING>{OPERATION}                                { printf("%c ", yytext[0]); }
<FSTRING>{DIGIT}+                                   { printf("T_NUM "); }
<FSTRING>{LETTER}+_*{LETTER}*{DIGIT}*\[{DIGIT}+\]   { printf("T_ID "); } 
<FSTRING>{LETTER}+_*{LETTER}*{DIGIT}*               { printf("T_ID "); }
<FSTRING>(.|\n)                                     { ; }
%%

int main () {
    yylex();
    return 0;
}