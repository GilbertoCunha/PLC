#ifndef _AVLTREES
#define _AVLTREES

typedef struct node {
    int root;
    int key;
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
void insertAVL (AVLTree *a, int key, int x);
int isBSTree (AVLTree a);

#endif