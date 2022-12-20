unsigned int pinned_array[20] __attribute__((section(".pinned_array_section")));

int main()
{
    int i;

    for (i = 0; i < 20; ++i) {
	pinned_array[i] = i;
    }

    return 0;
}
