/* Simple test script to test.
 *
 */

unsigned int res[8*8] __attribute__((section(".salaga_mm_region")));

int main(void)
{
	int i;

	for (i = 0; i < 64; ++i) {
		res[i] = i;
	}

	return 0;
}
