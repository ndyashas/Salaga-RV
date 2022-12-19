unsigned int pinned_array[20] __attribute__((section(".pinned_array_section")));

int main()
{
    int i;
    int j;
    int swap_var;

    // Initialize the array in increasing order
    for (i = 0; i < 20; ++i) {
	pinned_array[i] = i;
    }

    // Sort it! - Bubble sort in decending order
    for (i = 0; i < 19; ++i) {
	for (j = 0; j < 19; ++j) {
	    if (pinned_array[j] < pinned_array[j + 1]) {
		swap_var = pinned_array[j];
		pinned_array[j] = pinned_array[j + 1];
		pinned_array[j + 1] = swap_var;
	    }
	}
    }

    return 0;
}
