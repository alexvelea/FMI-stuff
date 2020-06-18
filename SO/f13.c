#include <fcntl.h>
#include <string.h>

#include "utils.h"

struct char_counter
{
    char ch;
    size_t* num_cnt;
};

void increase_counter(char* buff, int len, void* bind)
{
    struct char_counter* counter = (struct char_counter*)bind;
    int itr = 0;
    for (itr = 0; itr < len; itr += 1)
        if (buff[itr] == counter->ch)
            *(counter->num_cnt) += 1;
}

int main(int argc, char** argv) {
    if (argc < 3)
        die("Provide 1 char and 1 file");

    if (strlen(argv[1]) == 0)
        die("Provide a char to count");

    int read_fd = open(argv[2], O_RDONLY);
    if (read_fd == -1)
        die("Can't open %s - %m", argv[2]);

    char ch = argv[1][0];
    size_t num_cnt = 0;

    struct char_counter* counter = (struct char_counter*)xmalloc(sizeof(struct char_counter));
    counter->ch = ch;
    counter->num_cnt = &num_cnt;

    read_all_from_fd(read_fd, increase_counter, counter);
    
    msg("Character \'%c\' (%d) was found %zu times", argv[1][0], (int)argv[1][0], num_cnt);
    free(counter);

    return 0;
}
