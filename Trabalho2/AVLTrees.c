#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "AVLTrees.h"

void ShowAVLTree (AVLTree a) {
    if (a != NULL) {
        printf ("(%s, %d) ", a->key, a->root);
        ShowAVLTree (a->left);
        ShowAVLTree (a->right);
    }
}

void GraphAVLTreeAux (AVLTree a, FILE *f) {
    if (a != NULL) {
        fprintf (f, "%s [label=\"key: %s\nsp: %d\ntype: %s\"];\n", a->key, a->key, a->root, a->type);
        if (a->left != NULL) fprintf (f, "%s -> %s;\n", a->key, a->left->key);
        else if (a->right != NULL) {
            fprintf (f, "%d [shape=point];\n", (int) &(a->left));
            fprintf (f, "%s -> %d;\n", a->key, (int) &(a->left));
        }
        if (a->right != NULL) fprintf (f, "%s -> %s;\n", a->key, a->right->key);
        else if (a->left != NULL){
            fprintf (f, "%d [shape=point];\n", (int) &(a->right));
            fprintf (f, "%s -> %d;\n", a->key, (int) &(a->right));
        }
        GraphAVLTreeAux (a->left, f);
        GraphAVLTreeAux (a->right, f);
    }
}

void GraphAVLTree (AVLTree a) {
    if (a != NULL) {
        FILE *f = fopen ("avl.dot", "w");
        fprintf (f, "digraph G {\n");
        fprintf (f, "\tlabelloc=\"t\";\n");
        fprintf (f, "\tlabel=\"AVLTree\";\n");
        GraphAVLTreeAux (a, f);
        fprintf (f, "}");
        fclose (f);
        system ("dot -Tpng avl.dot > avl.png");
    }
}

int max (int a, int b) {
    int r;
    if (a > b) r = a;
    else r = b;
    return r;
}

int height (AVLTree a) {
    int r;
    if (a == NULL) r = 0;
    else r = a->height;
    return r;
}

int get_balance (AVLTree a) {
    int r;
    if (a == NULL) r = 0;
    else r = height (a->left) - height (a->right);
    return r;
}

AVLTree Left (AVLTree a) {
    AVLTree r = a->right;
    AVLTree aux = r->left;

    r->left = a;
    a->right = aux;

    a->height = 1 + max (height (a->left), height (a->right));
    r->height = 1 + max (height (r->left), height (r->right));

    return r;
}

AVLTree Right (AVLTree a) {
    AVLTree r = a->left;
    AVLTree aux = r->right;

    r->right = a;
    a->left = aux;

    a->height = 1 + max (height (a->left), height (a->right));
    r->height = 1 + max (height (r->left), height (r->right));

    return r;
}

int size (AVLTree a) {
    int r;
    if (a == NULL) r = 0;
    else r = 1 + size (a->left) + size(a->right);
    return r;
}

void insertAVL (AVLTree *a, char *key, char *type, int x) {
    if ((*a) == NULL) {
        *a = (AVLTree) malloc (sizeof (struct node));
        (*a)->root = x;
        (*a)->key = strdup(key);
        (*a)->type = strdup(type);
        (*a)->height = 1;
        (*a)->left = NULL;
        (*a)->right = NULL;
    }
    else if (strcmp(key, (*a)->key) < 0) insertAVL (&((*a)->left), key, type, x);
    else if (strcmp(key, (*a)->key) > 0) insertAVL (&((*a)->right), key, type, x);

    (*a)->height = 1 + max (height ((*a)->left), height ((*a)->right));
    int balance = get_balance (*a);

    if (balance > 1 && strcmp(key, (*a)->left->key) <= 0) *a = Right (*a);
    else if (balance > 1 && strcmp(key, (*a)->left->key) > 0) {
        (*a)->left = Left ((*a)->left);
        *a = Right (*a);
    }
    else if (balance < -1 && strcmp(key, (*a)->right->key) >= 0) *a = Left (*a);
    else if (balance < -1 && strcmp(key, (*a)->right->key) < 0) {
        (*a)->right = Right ((*a)->right);
        *a = Left (*a);
    }
}

int isBSTree (AVLTree a) {
    int r;
    if (a == NULL) r = 1;
    else if (a->left != NULL && strcmp(a->left->key, a->key) > 0) r = 0;
    else if (a->right != NULL && strcmp(a->right->key, a->key) < 0) r = 0;
    else if (!isBSTree (a->right) || !isBSTree (a->left)) r = 0;
    else r = 1;
    return r;
}

int searchAVL (AVLTree a, char *key, int *x) {
    int r = 1;
    if (a == NULL) r = 0;
    else if (strcmp (key, a->key) < 0) r = searchAVL (a->left, key, x);
    else if (strcmp (key, a->key) > 0) r = searchAVL (a->right, key, x);
    else *x = a->root;
    return r;
}