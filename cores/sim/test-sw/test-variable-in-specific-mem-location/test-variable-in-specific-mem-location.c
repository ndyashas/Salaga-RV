/* Simple test script to test.
 *
 */

__attribute__((section(".salaga_mm_region")))unsigned int res[8*8];

int main(void)
{
	int i;

	for (i = 0; i < 2; ++i) {
		res[i] = i;
	}

	return 0;
}
