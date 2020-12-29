#ifndef _AVLTREES
#define _AVLTREES

typedef struct node {
    int root;
    int sp;
    char *key;
    int height;
    struct node *left;
    struct node *right;
} *AVLTree;

void ShowAVLTree (AVLTree a);
void GraphAVLTree (AVLTree a);
int max (int a, int b);
int height (AVLTree a);
AVLTree Left (AVLTree a);
AVLTree Right (AVLTree a);
void insertAVLaux (AVLTree *a, char *key, int x, int sp);
void insertAVL (AVLTree *a, char *key, int x);
int isBSTree (AVLTree a);
int searchAVLvalue (AVLTree a, char *key, int *x);

#endif