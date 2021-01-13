#ifndef _ERRORHANDLE
#define _ERRORHANDLE

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "AVLTrees.h"
#include "translator.h"
#include "aux.h"

void myyyerror (char **r, char *s);
void notDeclared (char **r, char *id);
char *outOfRange (char *id, char *instr, int size, int *count);
void assignIntArray (char **r, char *id);
void intIndex (char **r, char *id);
void indexSizeDontMatch (char **r, char *id, int index, int size);
void reDeclaration (char **r, char *id);

#endif