%{
#include <stdio.h>
#include "y.tab.h"
%}

DIGIT [0-9]
LETTER [a-zA-Z]
SYMBS [\+\-\*\/\{\}\[\]\(\)!<>\\\;]

%x STRING
%option noyywrap

%%
^int\                         { return T_INT;  } 
^for\                         { return T_FOR; } 
[\t\ ]+for\                   { return T_FOR; } 
\ \:\:[\ \n]                  { return T_START; } 
^\:\;[\ \n]                   { return T_END; } 
[\ \n]+\:\;[\ \n]             { return T_END; } 
^if\                          { return T_IF; } 
[\t\ ]+if\                    { return T_IF; } 
^else[\ \n]                   { return T_ELSE; } 
[\t\ ]+else[\ \n]             { return T_ELSE; } 
[ ]or[ ]                      { return T_OR; } 
[ ]and[ ]                     { return T_AND; } 
[ ]not                        { return T_NOT; } 
{DIGIT}+                      { yylval.num = atoi(yytext); return T_NUM; } 
{LETTER}+{DIGIT}*             { yylval.id = strdup(yytext); return T_ID; } 
\"                            { return yytext[0]; BEGIN STRING; } 
[\ \n\t\r]                    { ; } 
.                             { return yytext[0]; } 

<STRING>\"                    { return yytext[0]; BEGIN INITIAL; } 
<STRING>\{{LETTER}+\}         { yytext[strlen(yytext)-1] = '\0'; yylval.id = strdup(yytext+1); return T_ID; }
<STRING>\{{LETTER}+           { yytext[strlen(yytext)-1] = '\0'; yylval.id = strdup(yytext+1); return T_ID; }
<STRING>\[{LETTER}+\]\}       { yytext[strlen(yytext)-1] = '\0'; yylval.id = strdup(yytext+1); return T_ID; }
<STRING>\[{DIGIT}+\]\}        { yytext[strlen(yytext)-2] = '\0'; yylval.num = atoi(yytext+2); return T_NUM; }
<STRING>(.|\n)                { return yytext[0]; } 
%%