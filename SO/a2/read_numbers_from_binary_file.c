#include <fcntl.h>
#include <string.h>

#include "../utils.h"

int readNumber(int fd, int position) {
    unsigned char bin_number[5];
    off_t offset = 4 * position;
    int n = pread(fd, bin_number, 4, offset);
    if (n != 4) {
        die("Error while reading number from file. Read %d\t%m", n);
    }

    int number = 0;
    int itr = 0;
    for (itr = 0; itr < 4; itr += 1) {
        number |= bin_number[itr] << (8 * (3 - itr));
    }
    
    return number;
}

int main(int argc, char** argv) {
    int read_fd = 0; 

    off_t remaining = lseek(read_fd, 0, SEEK_END);
    if (remaining == -1) {
        die("Can't determine file's size %s - %m", argv[1]);
    }
    
    remaining -= remaining & 3;

    msg("The file contains %ld ints", remaining / 4);

    for (int i = 0; i < remaining / 4; i += 1) {
        int x = readNumber(read_fd, i);
        printf("%d ", x);
    }

    printf("\n");

    close(read_fd);
    return 0;
}
