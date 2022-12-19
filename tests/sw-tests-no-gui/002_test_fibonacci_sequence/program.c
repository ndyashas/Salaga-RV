unsigned int pinned_array[20] __attribute__((section(".pinned_array_section")));

int main()
{
    int i;
    int next_num;
    pinned_array[0] = 0;
    pinned_array[1] = 1;

    for (i = 2; i < 20; ++i) {
	next_num = pinned_array[i-1] + pinned_array[i-2];
	pinned_array[i] = next_num;
    }

    return 0;
}
