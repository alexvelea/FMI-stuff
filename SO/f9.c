#include <fcntl.h>

#include "utils.h"

void append_same_file(int read_fd, int write_fd, const char* file_name) 
{
    if (!file_exists(file_name))
        die("%s is not a valid file", file_name);

    off_t remaining = lseek(read_fd, 0, SEEK_END);
    if (remaining == -1)
        die("Can't seek file %s - %m", file_name);

    char buff[1024];
    off_t start = 0;

    while (remaining > 0) {
        int len = pread(read_fd, buff, sizeof(buff), start);
        if (len == -1) {
            if (errno == EINTR || errno == EAGAIN)
                continue;

            die("Error while reading %m");
        }

        xwrite(write_fd, buff, len);
        remaining -= len;
        start += len;
    }
}

int main(int argc, char** argv)
{
    if (argc < 3)
        die("Provide 2 files.");

    int read_fd = open(argv[1], O_RDONLY);
    if (read_fd == -1)
        die("Can't open %s - %m", argv[1]);

    int write_fd = open(argv[2], O_WRONLY | O_APPEND);
    if (write_fd == -1) 
        die("Can't open %s - %m", argv[2]);   

    if (same_file(read_fd, write_fd))
        append_same_file(read_fd, write_fd, argv[1]);
    else
        read_all_from_fd(read_fd, xwrite_callback, (void*)&write_fd);        

    return 0;
}
