%{
#include <stdio.h>
#include "y.tab.h"
#define YY_USER_ACTION yylloc.first_line = yylloc.last_line = yylineno;
%}

DIGIT [0-9]
LETTER [a-zA-Z]
OPERATION [\+\(\)\*\-\/\%]

%x FSTRING CBRACES
%option noyywrap
%option yylineno

%%
\#[^\n]*\n                                  { return LCOM; }
["]{3}(["]{0,2}([^\\"]|\\(.|\n)))*["]{3}    { return MCOM; } 
main                                        { return MAIN; }
int                                         { return INT; }
for                                         { return FOR; } 
\:\:                                        { return START; } 
\:\;                                        { return END; } 
if                                          { return IF; } 
else                                        { return ELSE; } 
or                                          { return OR; } 
and                                         { return AND; } 
not                                         { return NOT; } 
read                                        { return READ; } 
write                                       { return WRITE; } 
{DIGIT}+                                    { yylval.num = atoi(yytext); return NUM; }  
{LETTER}+_*{LETTER}*{DIGIT}*                { yylval.id = strdup(yytext); return ID; } 
[\ \t\r]                                    { ; }
\=\=                                        { return EQ; }
\!\=                                        { return NEQ; }
\<\=                                        { return LE; }
\>\=                                        { return GE; }
\"[^\"]*\"                                  { yylval.id = strdup(yytext); return STR; }
f\"                                         { BEGIN FSTRING; return FSS; }
(.|\n)                                      { return yytext[0]; }                                          

<FSTRING>\"                                         { BEGIN INITIAL; return yytext[0]; }
<FSTRING>\{                                         { BEGIN CBRACES; return yytext[0]; }
<FSTRING>[^\{\"]*                                   { yylval.id = strdup(yytext); return FSTR; }

<CBRACES>\}                                         { BEGIN FSTRING; return yytext[0]; }
<CBRACES>{OPERATION}                                { return yytext[0]; }
<CBRACES>{DIGIT}+                                   { yylval.num = atoi(yytext); return NUM; }
<CBRACES>{LETTER}+_*{LETTER}*{DIGIT}*               { yylval.id = strdup(yytext); return ID; }
<CBRACES>[ ]                                        { ; }
<CBRACES>(.|\n)                                     { return yytext[0]; }
%%