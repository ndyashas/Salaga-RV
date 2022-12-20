#include <stdlib.h>

#define PINNED_ARRAY_SIZE 20
unsigned int pinned_array[PINNED_ARRAY_SIZE] __attribute__((section(".pinned_array_section")));


struct node {
    int val;
    struct node* next;
};

struct node* append(struct node **root, int val)
{
    struct node *trav = *root;
    struct node* new = malloc(sizeof(struct node));
    new->val = val;
    new->next = NULL;

    if (*root == NULL) {
	// Initialize
	*root = new;
    }
    else {
	// Go till the end before appending
	while (trav->next != NULL) {
	    trav = trav->next;
	}
	trav->next = new;
    }

    return new;
}

int main()
{
    int i;
    struct node *root = NULL;
    struct node *prev = NULL;

    // Append nodes to the list
    for (i = 0; i < PINNED_ARRAY_SIZE; ++i) {
	append(&root, i*2);
    }

    // Reverse and place elements in the pinned_array for inspection
    for (i = 0; i < PINNED_ARRAY_SIZE; ++i) {
	prev = root;
	pinned_array[PINNED_ARRAY_SIZE - i - 1] = root->val;
	root = root->next;
	free(prev);
    }

    return 0;
}
