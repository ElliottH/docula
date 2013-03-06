/**
 * Test source file...
 *
 * @file
 * @author Elliott Hillary <ejh67@cam.ac.uk>
 * @date 2012-12-20
 * @license MIT
 */

#include "test_fib.h"

/**
 * Calculates the nth Fibonacci number recursively.
 */
uint fibonacci(uint n) {
    if (n == 0)
        return 0;
    else if (n == 1)
        return 1;
    else
        return fibonacci(n-1) + fibonacci(n-2);
}

uint fib() {
    fib(default);
}
