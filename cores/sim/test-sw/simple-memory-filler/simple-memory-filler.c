/* Simple test script to test.
 *
 */

unsigned int res[32*16] __attribute__((section(".salaga_mm_region")));

int main(void)
{
	int i;

	for(i = 0; i<512; ++i) {
		res[i] = i;
	}

	return 0;
}
