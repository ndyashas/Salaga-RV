unsigned int pinned_array[20] __attribute__((section(".pinned_array_section")));

int main()
{
    int i;
    int j;
    int factorial;
    int factorial_till = 10;

    pinned_array[0] = 1;
    
    // Find factorial and place in the pinned_array
    for (i = 1, factorial = 1; i <= factorial_till; ++i) {
	for (j = 1, factorial = j; j <= i; ++j) {
	    factorial = factorial * j;
	}

	pinned_array[i] = factorial;
    }

    return 0;
}
