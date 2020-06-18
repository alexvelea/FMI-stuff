#include "trace_children.h"
#include <stdio.h>
#include <stdlib.h>

int main(int argc, char* argv[]) {
    int target_pid = 0;
    if (argc == 2) {
        target_pid = atoi(argv[1]);
    } else {
        scanf("%d", &target_pid);
    }

    printProcessStatsPID(target_pid);
    return 0;
}
