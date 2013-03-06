/**
 * Test header file...
 *
 * @file
 * @author Elliott Hillary <ejh67@cam.ac.uk>
 * @date 2012-12-20
 * @license MIT
 */


/**
 * The most important #define ever written.
 */
#define THE_MEANING_OF_LIFE 42

/**
 * This is a just a simple, and rather pointless, typedef!
 */
typedef unsigned int uint;

/**
 * Default value to be used.
 */
int default = 10;

/**
 * Calculates & returns the nth Fibonacci number.
 *
 * @param[in] n The position in the series that you wish to obtain the value for.
 * @return The nth Fibonacci number.
 */
uint fibonacci(uint n);

/**
 * Calculates & returns the defaultth Fibonacci number.
 *
 * @return The Fibonacci number corresponding with default.
 */
uint fib();
