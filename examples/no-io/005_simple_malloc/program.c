#include <stdlib.h>

#define PINNED_ARRAY_SIZE 20
unsigned int pinned_array[PINNED_ARRAY_SIZE] __attribute__((section(".pinned_array_section")));

int main()
{
    int i;

    // Dynamically allocate memory for an array.
    unsigned int *int_array = malloc(sizeof(unsigned int)*PINNED_ARRAY_SIZE);

    // Initialize its contents
    for (i = 0; i < PINNED_ARRAY_SIZE; ++i) {
	int_array[i] = i;
    }

    // Reverse and copy to pinned array
    for (i = 0; i < PINNED_ARRAY_SIZE; ++i) {
        pinned_array[i] = int_array[PINNED_ARRAY_SIZE - i - 1];
    }

    // free the array
    free(int_array);

    return 0;
}
