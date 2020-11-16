typedef struct slist {
  char *nome;
  struct slist *prox;
} *LStr;

typedef struct nodo {
  char *nome;
  int num_ocorr;
  struct nodo *prox;
} *LNodo;

typedef struct agraph {
  char *nome;
  struct nodo *autores;
} *Graph;

typedef struct autor {
  char *nome;
  struct slist *public;
  struct autor *prox;
}*LAut;

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
void acrescentaCat (LCat *l, char *s, LProj p);
void ShowLStr (LStr *l);
void acrescentaLStr (LStr *l, char *s);
void ShowProj (LProj *p);
void acrescentaProj (LProj *p, char *chave, char *titulo, LStr autores);
void acrescentaAut (LAut *a, char *name, char *pub);
void acrescentaNodo(LNodo *n, char *nome);
void initGraph (Graph *g, char *nome);
void ShowGraph (Graph *grafo, char *path);
void ShowAut (LAut *a);
void ShowAutF (LAut *a, FILE *f);
int contaPubs (LStr *a);
void ShowCat (LCat *l);
void swap_comma (char nome[], char a[]);
void acrescentaAuts (LAut *autores, LStr nomes, char *pub);
void acrescentaGrafo (Graph g, LStr auts);
void ShowAuthorTable (FILE *f, LNodo autores);
void printHTMLstart ();
void printHTMLend ();