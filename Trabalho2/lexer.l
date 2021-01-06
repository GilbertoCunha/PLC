%{
#include <stdio.h>
#include "y.tab.h"
%}

DIGIT [0-9]
LETTER [a-zA-Z]
OPERATION [\+\(\)\*\-\/\%]
SYMBS [\+\-\*\/\{\}\[\]\(\)!<>\\\;]

%x STRING FSTRING
%option noyywrap
%option yylineno

%%
^int\                                       { return T_INT;  } 
^for\                                       { return T_FOR; } 
[\t\ ]+for\                                 { return T_FOR; } 
\ \:\:[\ \n]                                { return T_START; } 
^\:\;[\ \n]                                 { return T_END; } 
[\ \n]+\:\;[\ \n]                           { return T_END; } 
^if\                                        { return T_IF; } 
[\t\ ]+if\                                  { return T_IF; } 
^else[\ \n]                                 { return T_ELSE; } 
[\t\ ]+else[\ \n]                           { return T_ELSE; } 
[ ]or[ ]                                    { return T_OR; } 
[ ]and[ ]                                   { return T_AND; } 
[ ]not                                      { return T_NOT; } 
read\ *\(                                   { return T_READ; } 
write\ *\(                                  { return T_WRITE; } 
{DIGIT}+                                    { yylval.num = atoi(yytext); return T_NUM; } 
{LETTER}+_*{LETTER}*{DIGIT}*\[{DIGIT}+\]    { yylval.id = strdup(yytext); return T_ID; } 
{LETTER}+_*{LETTER}*{DIGIT}*                { yylval.id = strdup(yytext); return T_ID; } 
\"                                          { BEGIN STRING; return yytext[0]; } 
[\ \n\t\r]                                  { ; } 
.                                           { return yytext[0]; } 

<STRING>\"                                          { BEGIN INITIAL; return yytext[0]; }
<STRING>\{                                          { BEGIN FSTRING; return yytext[0]; }
<STRING>[^\{\"]*                                    { yylval.id = strdup(yytext); return T_STR; }

<FSTRING>\}                                         { BEGIN STRING; return yytext[0]; }
<FSTRING>{OPERATION}                                { return yytext[0]; }
<FSTRING>{DIGIT}+                                   { yylval.num = atoi(yytext); return T_NUM; }
<FSTRING>{LETTER}+_*{LETTER}*{DIGIT}*\[{DIGIT}+\]   { yylval.id = strdup(yytext); return T_ID; } 
<FSTRING>{LETTER}+_*{LETTER}*{DIGIT}*               { yylval.id = strdup(yytext); return T_ID; }
<FSTRING>[ ]                                        { ; }
<FSTRING>(.|\n)                                     { return yytext[0]; }
%%