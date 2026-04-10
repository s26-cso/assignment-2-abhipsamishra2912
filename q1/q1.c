#include <stdio.h>

typedef struct Node{
    int val;
    struct Node* left;
    struct Node* right;
}Node;

struct Node* make_node(int val);
struct Node* insert(struct Node* root, int val);
struct Node* get(struct Node* root, int val);
int getAtMost(int val, struct Node* root);

int main() {
    struct Node* root = NULL;
    root = insert(root, 10);
    root = insert(root, 5);
    root = insert(root, 15);
    root = insert(root, 3);

    printf("get(10) = %p\n", get(root, 10)); 
    printf("get(99) = %p\n", get(root, 99));   
    printf("getAtMost(12, root) = %d\n", getAtMost(12, root)); 
    printf("getAtMost(5, root) = %d\n", getAtMost(5, root)); 
    printf("getAtMost(2, root) = %d\n", getAtMost(2, root));  
}