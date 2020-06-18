#include <stdlib.h>


#include "../utils.h"

int main(int argc, char** argv) {
    if (argc < 2) {
        die("Provide number of numbers");
    }

    int n = atoi(argv[1]);
    for (int i = 0; i < n; i += 1) {
        printf("%d ", rand());
    }

    return 0;
}
