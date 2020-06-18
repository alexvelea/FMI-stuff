#include <fcntl.h>
#include <string.h>

#include "../utils.h"

long int num_reads = 0, num_writes = 0;

int read_number(int fd, int position) 
{
    unsigned char bin_number[5];
    off_t offset = 4 * position;
    int n = pread(fd, bin_number, 4, offset);
    if (n != 4)
        die("Error while reading number from file. %m");

    int number = 0;
    int itr = 0;
    for (itr = 0; itr < 4; itr += 1) 
        number |= bin_number[itr] << (8 * (3 - itr));

    num_reads += 1;
//    msg("read from %d\t0x%08x", position, number);
    return number;
}

void writeNumber(int fd, int pos, int number) 
{
    unsigned char bin_number[5];
    int i = 0;
    for (i = 0; i < 4; i += 1) {
        bin_number[i] = (number >> (8 * (3 - i))) & ((1 << 8) - 1);
    }
    int n = pwrite(fd, bin_number, 4, 4 * pos);
    if (n != 4) 
    {
        die("Can't write numbers to file written size: %d. %m", n);
    }

    num_writes += 1;
//    msg("write to %d\t0x%08x", pos, number);
}

void swapNumbers(int fd, int pos1, int pos2) {
    int a = read_number(fd, pos1);
    int b = read_number(fd, pos2);
    writeNumber(fd, pos1, b);
    writeNumber(fd, pos2, a);
}

// benchmark stuff
long int num_swaps = 0, num_calls = 0, num_iterations = 0;

void quicksort(int fd, int left, int right)
{
    num_calls += 1;
    int i, j;
    int mid;

    if (left < right)
    {
        mid = rand() % (right - left + 1) + left;
        i=left;
        j=right;

        while (i < j) 
        {
            while(read_number(fd, i) <= read_number(fd, mid) && i < right) 
            {
                num_iterations += 1;
                i++;
            }

            while(read_number(fd, j) > read_number(fd, mid)) 
            {
                num_iterations += 1;
                j--;
            }

            if (i < j)
            {
                num_swaps += 1;
                swapNumbers(fd, i, j);
            }
        }

        num_swaps += 1;
        swapNumbers(fd, mid, j);

        quicksort(fd, left, j - 1);
        quicksort(fd, j + 1, right);
    }
}

int main(int argc, char** argv)
{
    if (argc < 2)
        die("Provide 1 file to sort");

    int read_fd = open(argv[1], O_RDWR);
    if (read_fd == -1)
        die("Can't open %s - %m", argv[2]);

    off_t remaining = lseek(read_fd, 0, SEEK_END);
    if (remaining == -1)
        die("Can't determine file's size %s - %m", argv[1]);
    
    remaining -= remaining & 3;

    msg("The file contains %ld ints", remaining / 4);

    quicksort(read_fd, 0, (remaining) / 4 - 1);
    msg("num_swaps:\t%ld\nnum_calls:\t%ld\nnum_iteration:\t%ld\nnum_reads:\t%ld\nnum_writes:\t%ld\n", 
            num_swaps, num_calls, num_iterations, num_reads, num_writes);

    close(read_fd);
    return 0;
}
