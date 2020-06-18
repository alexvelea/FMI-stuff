#ifndef TRACE_CHILDREN_SRC_PRINT_PROCESS_STATS_H
#define TRACE_CHILDREN_SRC_PRINT_PROCESS_STATS_H
#include "trace_children.h"

void printProcessStatsInternal(struct ProcessStats* process, int depth, int child_mask, int is_last_child);

#ifndef tracechildrenuselib
#include "tracechildren_src/print_process_stats.c"
#endif

#endif  // TRACE_CHILDREN_SRC_PRINT_PROCESS_STATS_H
