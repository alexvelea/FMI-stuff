#include <fcntl.h>
#include <string.h>

#include "utils.h"


void write_to_stdout(char* buff, int size, UNUSED void* bind) {
    xwrite(1, buff, size);
}

void readFromStdin() {
    read_all_from_fd(0, write_to_stdout, NULL);
}

void readFromFile(const char* file_name) {
    int read_fd = open(file_name, O_RDONLY);
    if (read_fd == -1) {
        die("Can't open %s - %m", file_name);
    }
    
    read_all_from_fd(read_fd, write_to_stdout, NULL);
    return;
}

int main(int argc, char** argv) {
    if (argc < 2)
        readFromStdin();
    else 
        readFromFile(argv[1]);

    return 0;
}
