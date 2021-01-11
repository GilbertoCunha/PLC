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
void outOfRange (char **r, char *id, char size, char index);
void assignIntArray (char **r, char *id);
void intIndex (char **r, char *id);

#endif