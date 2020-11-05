typedef struct slist {
  char *nome;
  struct slist *prox;
} *LStr;

typedef struct projeto {
    char *chave;
    char *titulo;
    LStr autores;
    struct projeto *prox;
} *LProj;

typedef struct categoria {
    char *nome;
    int num_ocorr;
    LProj projeto;
    struct categoria *prox;
} *LCat;

char *str_to_lower (char *s);
void acrescentaCat (LCat *l, char *s);
void ShowLStr (LStr *l);
void acrescentaLStr (LStr *l, char *s);
void ShowProj (LProj *p);
void acrescentaProj (LProj *p, char *chave, char *titulo, LStr autores);
