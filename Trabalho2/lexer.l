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
int                                         { return T_INT;  } 
for                                         { return T_FOR; } 
\:\:                                        { return T_START; } 
\:\;                                        { return T_END; } 
if                                          { return T_IF; } 
else                                        { return T_ELSE; } 
or                                          { return T_OR; } 
and                                         { return T_AND; } 
not                                         { return T_NOT; } 
read                                        { return T_READ; } 
write                                       { return T_WRITE; } 
{DIGIT}+                                    { yylval.num = atoi(yytext); return T_NUM; } 
{LETTER}+_*{LETTER}*{DIGIT}*\[{DIGIT}+\]    { yylval.id = strdup(yytext); return T_ID; } 
{LETTER}+_*{LETTER}*{DIGIT}*                { yylval.id = strdup(yytext); return T_ID; } 
\"                                          { BEGIN STRING; return yytext[0]; } 
[\ \t\r]                                    { ; }
\=\=                                        { return T_EQ; }
\!\=                                        { return T_NEQ; }
\<\=                                        { return T_LE; }
\>\=                                        { return T_GE; }
(.|\n)                                      { return yytext[0]; } 

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