%{
#include <stdio.h>
#include "y.tab.h"
#define YY_USER_ACTION yylloc.first_line = yylloc.last_line = yylineno;
%}

DIGIT [0-9]
LETTER [a-zA-Z]

%x FSTRING CBRACES
%option noyywrap
%option yylineno

%%
main                                        { return MAIN; }
int                                         { return INT; }
void                                        { return VOID; }
for                                         { return FOR; } 
if                                          { return IF; } 
else                                        { return ELSE; } 
or                                          { return OR; } 
and                                         { return AND; } 
not                                         { return NOT; } 
read                                        { return READ; } 
write                                       { return WRITE; } 
{DIGIT}+                                    { yylval.num = atoi(yytext); return NUM; }  
{LETTER}+{DIGIT}*_*{LETTER}*{DIGIT}*        { yylval.id = strdup(yytext); return ID; } 
\#[^\n]*\#                                  { ; }
["]{3}(["]{0,2}([^\\"]|\\(.|\n)))*["]{3}    { ; } 
\:\:                                        { return START; } 
\:\;                                        { return END; } 
\=\=                                        { return EQ; }
\!\=                                        { return NEQ; }
\<\=                                        { return LE; }
\>\=                                        { return GE; }
\"[^\"]*\"                                  { yylval.id = strdup(yytext); return STR; }
f\"                                         { BEGIN FSTRING; return FSS; }
[\ \t\r]                                    { ; }
(.|\n)                                      { return yytext[0]; }                                          

<FSTRING>\"                                         { BEGIN INITIAL; return yytext[0]; }
<FSTRING>\{                                         { BEGIN CBRACES; return yytext[0]; }
<FSTRING>[^\{\"]*                                   { yylval.id = strdup(yytext); return FSTR; }

<CBRACES>\}                                         { BEGIN FSTRING; return yytext[0]; }
<CBRACES>or                                         { return OR; } 
<CBRACES>and                                        { return AND; } 
<CBRACES>not                                        { return NOT; }
<CBRACES>{DIGIT}+                                   { yylval.num = atoi(yytext); return NUM; }
<CBRACES>{LETTER}+_*{LETTER}*{DIGIT}*               { yylval.id = strdup(yytext); return ID; }
<CBRACES>\=\=                                       { return EQ; }
<CBRACES>\!\=                                       { return NEQ; }
<CBRACES>\<\=                                       { return LE; }
<CBRACES>\>\=                                       { return GE; }
<CBRACES>[ ]                                        { ; }
<CBRACES>(.|\n)                                     { return yytext[0]; }
%%