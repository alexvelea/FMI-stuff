#include <errno.h>
#include <stdlib.h>

#include "utils.h"

long int number_from_str(const char* str)
{
    int i;
    for (i = 0; str[i] != '\0'; i += 1)
        if (!(str[i] >= '0' && str[i] <= '9'))
            die("Number %s is not in base 10", str);

    long int aux = strtol(str, NULL, 10);
    if (errno == ERANGE)
        die("Number %s does not fit on long int", str);

    return aux;
}

long int gcd(long int a, long int b)
{
    if (b == 0)
        return a;
    
    return gcd(b, a % b);
}

int main(int argc, char** argv)
{
    if (argc < 3)
        die("Provide 2 numbers to compute GCD");

    long int a = number_from_str(argv[1]);
    long int b = number_from_str(argv[2]);

    if (a < 0)
        die("Number %ld must be positive", a);

    if (b < 0)
        die("Number %ld must be positive", b);

    long int c = gcd(a, b);

    msg("[%ld, %ld] = %ld", a, b, c);
    return 0;
}
