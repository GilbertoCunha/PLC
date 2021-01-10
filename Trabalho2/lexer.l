%{
#include <stdio.h>
#include "y.tab.h"
%}

DIGIT [0-9]
LETTER [a-zA-Z]
OPERATION [\+\(\)\*\-\/\%]
SYMBS [\+\-\*\/\{\}\[\]\(\)!<>\\\;]

%x FSTRING CBRACES
%option noyywrap
%option yylineno

%%
\#[^\n]*\n                                  { return T_LCOM; }
["]{3}(["]{0,2}([^\\"]|\\(.|\n)))*["]{3}    { return T_MCOM; } 
int                                         { return T_INT; } 
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
[\ \t\r]                                    { ; }
\=\=                                        { return T_EQ; }
\!\=                                        { return T_NEQ; }
\<\=                                        { return T_LE; }
\>\=                                        { return T_GE; }
\"[^\"]*\"                                  { yylval.id = strdup(yytext); return T_STR; }
f\"                                         { BEGIN FSTRING; return T_FSS; }
(.|\n)                                      { return yytext[0]; }                                          

<FSTRING>\"                                         { BEGIN INITIAL; return yytext[0]; }
<FSTRING>\{                                         { BEGIN CBRACES; return yytext[0]; }
<FSTRING>[^\{\"]*                                   { yylval.id = strdup(yytext); return T_FSTR; }

<CBRACES>\}                                         { BEGIN FSTRING; return yytext[0]; }
<CBRACES>{OPERATION}                                { return yytext[0]; }
<CBRACES>{DIGIT}+                                   { yylval.num = atoi(yytext); return T_NUM; }
<CBRACES>{LETTER}+_*{LETTER}*{DIGIT}*\[{DIGIT}+\]   { yylval.id = strdup(yytext); return T_ID; } 
<CBRACES>{LETTER}+_*{LETTER}*{DIGIT}*               { yylval.id = strdup(yytext); return T_ID; }
<CBRACES>[ ]                                        { ; }
<CBRACES>(.|\n)                                     { return yytext[0]; }
%%