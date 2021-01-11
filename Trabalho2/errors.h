#ifndef _ERRORHANDLE
#define _ERRORHANDLE

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "AVLTrees.h"
#include "translator.h"
#include "aux.h"

void myyyerror (char **r, char *s, int *error);
void notDeclared (char **r, char *id, int *error);
void outOfRange (char **r, char *id, char size, char index, int *error);
void assignIntArray (char **r, char *id, int *error);

#endif