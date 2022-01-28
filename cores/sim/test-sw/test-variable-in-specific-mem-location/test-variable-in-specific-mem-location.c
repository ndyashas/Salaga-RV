/* Simple test script to test.
 *
 */

__attribute__((section(".salaga_mm_region")))int res;

int main(void)
{
	int num1, num2;
	num1 = -5;
	num2 = 6;
        res = num1 + num2;

	return 0;
}
