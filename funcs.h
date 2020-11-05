typedef struct projeto {
    char *chave;
    char *titulo;
    char **autores;
    struct projeto *prox;
} *LProj;

typedef struct categoria {
    char *nome;
    int num_ocorr;
    struct categoria *prox;
} *LCat;

char *str_to_lower (char *s);

void acrescenta (LCat *l, char *s);


