#include <stdlib.h>
#include <string.h>
#include <salagaio.h>

#define PINNED_ARRAY_SIZE 20
unsigned int pinned_array[PINNED_ARRAY_SIZE] __attribute__((section(".pinned_array_section")));

int main()
{
    int *i = malloc(sizeof(int));

    char print_message[] = "Hello World!\n";

    for (*i = 0; *i < strlen(print_message); ++(*i)) {
        putchar(print_message[*i]);
    }

    free(i);

    return 0;
}
