#ifndef _AVLTREES
#define _AVLTREES

typedef struct node {
    int root, size, height;
    char *key, *type;
    struct node *left;
    struct node *right;
} *AVLTree;

void ShowAVLTree (AVLTree a);
void GraphAVLTree (AVLTree a);
int max (int a, int b);
int height (AVLTree a);
AVLTree Left (AVLTree a);
AVLTree Right (AVLTree a);
void insertAVL (AVLTree *a, char *key, char *type, int size, int x);
int isBSTree (AVLTree a);
int searchAVLsp (AVLTree a, char *key, int *x);
int searchAVLsize (AVLTree a, char *key, int *x);

#endif