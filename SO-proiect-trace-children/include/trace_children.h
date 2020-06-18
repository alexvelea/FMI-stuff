#ifndef TRACE_CHILDREN_H
#define TRACE_CHILDREN_H

#include <time.h>
#include <sys/types.h>

#define INDENT_LEVEL 4

struct ProcessStats {
    pid_t pid;

    char state;
    char name[17];
    unsigned long minflt;
    unsigned long cminflt;
    unsigned long majflt;
    unsigned long cmajflt;

    long nice;
    long num_threads;

    unsigned long long starttime;
    unsigned long vsize;
    long rss;
    unsigned long rsslim;

    unsigned long user_time_ms;
    unsigned long system_time_ms;

    double cpu_percentage;

    struct timespec last_update_time;

    struct ProcessStats** children;
};

void printProcessStats(struct ProcessStats* process);

void printProcessStatsPID(pid_t pid);

void dealloc(struct ProcessStats* process);

struct ProcessStats* getProcessStats(pid_t pid);

void updateProcessStats(struct ProcessStats* process);

void updateProcessStatsRecursive(struct ProcessStats* process);

    #ifndef tracechildrenuselib
#include "tracechildren_src/trace_children.c"
#endif

#endif // TRACE_CHILDREN_H
