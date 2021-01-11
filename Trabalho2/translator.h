#ifndef _TRANSLATOR
#define _TRANSLATOR

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "errors.h"
#include "AVLTrees.h"
#include "aux.h"

void ifInstr (char **r, char *expr, char *instr, int *count);
void ifElse (char **r, char *expr, char *instr1, char *instr2, int *count);
void ifElseif (char **r, char *expr, char *instr, char *cond, int *count);
void exprAtr (char **r, char *id, char *expr, AVLTree *vars, int *error);
void readAtr (char **r, char *id, AVLTree *vars, int *error);
void readAtrStr (char **r, char *id, char *s, AVLTree *vars, int *error);
void declaration (char **r, char *id, int *count, AVLTree *vars);
void declrExpr (char **r, char *id, char *expr, AVLTree *vars, int *count, int *error);
void declrRead (char **r, char *id, AVLTree *vars, int *count, int *error);
void declrReadStr (char **r, char *id, char *s, AVLTree *vars, int *count, int *error);
void factorId (char **r, char *id, AVLTree *vars, int *error);
void negfactorId (char **r, char *id, AVLTree *vars, int *error);
void forStartEnd (char **r, char *id, char *expr1, char *expr2, char *instr, AVLTree *vars, int *count, int *error);
void forStep (char **r, char *id, char *expr1, char *expr2, char *expr3, char *instr, AVLTree *vars, int *count, int *error);

#endif