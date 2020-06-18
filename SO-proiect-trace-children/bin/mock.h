#include "trace_children.h"

#include <string.h>
#include <stdlib.h>

struct ProcessStats* create(pid_t pid, double wall_time_ms, double user_time_ms, double system_time_ms, int num_children) {
    struct ProcessStats* p = (struct ProcessStats*)(malloc(sizeof(struct ProcessStats)));
    p->children = (struct ProcessStats**)malloc(sizeof(struct ProcessStats*) * (num_children + 1));
    memset(p->children, 0, (num_children + 1) * sizeof(struct ProcessStats*));

    p->pid = pid;
    p->user_time_ms = user_time_ms;
    p->system_time_ms = system_time_ms;

    return p;
}

struct ProcessStats* getMock() {
    struct ProcessStats* root = create(1, 1000.0, 500.0, 500.0, 3);
    root->children[0] = create(2, 200, 100, 100, 0);
    
    root->children[2] = create(3, 100, 0, 100, 0);
    struct ProcessStats* root2 = create(4, 700.0, 300, 400, 2);
    root->children[1] = root2;

    root2->children[0] = create(5, 10, 10, 10, 1);
    root2->children[0]->children[0] = create(6, 5, 5, 5, 0);
    root2->children[1] = create(7, 10, 10, 10, 2);
    root2->children[1]->children[0] = create(8, 5, 5, 5, 0);
    root2->children[1]->children[1] = create(9, 5, 5, 5, 0);

    return root;
}


