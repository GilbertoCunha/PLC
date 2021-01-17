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
void exprAtr (char **r, char *id, char *expr, AVLTree *vars);
void arrayAtr (char **r, char *id, char *instr, char *expr, AVLTree *vars, int *count, int line);
void readAtr (char **r, char *id, char *instr, AVLTree *vars);
void readArrayAtr (char **r, char *id, char *instr1, char *instr2, AVLTree *vars, int *count, int line);
void declaration (char **r, char *id, int *count, AVLTree *vars);
void declrArray (char **r, char *id, char *index, char *count, AVLTree *vars);
void declrExpr (char **r, char *id, char *expr, AVLTree *vars, int *count);
void declrRead (char **r, char *id, char *instr, AVLTree *vars, int *count);
void decList (char **r, char *id, int index, char *instr, AVLTree *vars, int *count, int *size);
void declrFunc (char **r, char *id, char *instrs1, char *instrs2, AVLTree *vars, int *count, char *ftype);
void factorId (char **r, char *id, AVLTree *vars);
void factorArray (char **r, char *id, char *instr, AVLTree *vars, int *count, int line);
void negfactorId (char **r, char *id, AVLTree *vars);
void negfactorArray (char **r, char *id, char *instr, AVLTree *vars, int *count, int line);
void forStartEnd (char **r, char *id, char *expr1, char *expr2, char *instr, AVLTree *vars, int *count);
void forStep (char **r, char *id, char *expr1, char *expr2, char *expr3, char *instr, AVLTree *vars, int *count);
void forArrayIV (char **r, char *index, char *v, char *id, char *instr, AVLTree *vars, int *count);
void forCond (char **r, char *id1, char *id2, char *expr1, char *expr2, char *expr3, char *instrs, AVLTree *vars, int *count);
void funcCall (char **r, char *id, AVLTree *vars);
void funcAtr (char **r, char *id1, char *id2, AVLTree *vars);

#endif