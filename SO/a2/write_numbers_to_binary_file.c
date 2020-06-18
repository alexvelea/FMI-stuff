#include <fcntl.h>
#include <string.h>

#include "../utils.h"

void writeNumber(int fd, int number) {
    unsigned char bin_number[5];
    int i = 0;
    for (i = 0; i < 4; i += 1) {
        bin_number[i] = (number >> (8 * (3 - i))) & ((1 << 8) - 1);
    }
    int n = write(fd, bin_number, 4);
    if (n != 4) {
        die("Can't write numbers to file written size: %d. %m", n);
    }
}

int main(int argc, char** argv) {
    int number = 0;
    while (scanf("%d", &number) != EOF) {
        writeNumber(1, number);
    }
    
    return 0;
}
