#include "trace_children.h"

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/stat.h> 
#include <fcntl.h>
#include <errno.h>
#include <time.h>

#include <unistd.h>
#include <sys/times.h>
#include "print_process_stats.h"
#include "utils.h"

void dealloc(struct ProcessStats* process) {
    struct ProcessStats** children = process->children;
    while (*children != NULL) {
        dealloc(*children);
        children += 1;
    }

    free(process);
}

void printProcessStats(struct ProcessStats* process) {
    // compute percentage data
    xsleepms(1000); // give it a little time to settle in
    updateProcessStatsRecursive(process);

    for (int j = 1; j < INDENT_LEVEL / 2; j += 1) {
        printf(" ");
    }
    printProcessStatsInternal(process, 0, 1, 0);
}

struct ProcessStats* getProcessStats(pid_t pid);

void printProcessStatsPID(pid_t pid) {
    struct ProcessStats* process = getProcessStats(pid);
    printProcessStats(process);
    dealloc(process);
}

void updateProcessStats(struct ProcessStats* process) {
    // read data from /proc/$/stat
    char* pid_str = to_char(process->pid);
    int pid_size = strlen(pid_str);

    // compute file to read
    int total_size = 11 + pid_size;
    static char stat_path[1024];
    stat_path[total_size] = '\0';
    strcpy(stat_path, "/proc/");
    strcpy(stat_path + 6, pid_str);
    strcpy(stat_path + 6 + pid_size, "/stat");

    // opening file
    int fd = open(stat_path, O_RDONLY);
    if (fd == -1) {
        perror(NULL);
        exit(errno);
    }

    static char buff[1024];
    char* b = buff;
    int rc = xread(fd, buff, 1023);
    if (rc < 0) {
        perror(NULL);
        exit(errno);
    }

    buff[rc+1] = '\0';
    // compute time just after reading data so we know the correct time difference between 2 reads
    struct timespec current_time;
    clock_gettime(CLOCK_REALTIME, &current_time);
    
    unsigned long utime, stime;
    static char* format = "%*d %s %c %*d %*d %*d %*d %*d %*u %lu %lu %lu %lu %lu %lu %*ld %*ld %*ld %ld %ld %*ld %llu %lu %ld %lu";
    //                     1   2  3  4   5   6   7   8   9   10  11  12  13  14  15  16   17   18   19  20  21   22   23  24  25

    sscanf(buff, format,
           process->name,
           &(process->state),        // - (3) status (RSDZTW)
                                     // (4) The PID of the parent.
                                     // (5) The process group ID of the process.
                                     // (6) The session ID of the process.
                                     // (7) dunno
                                     // (8) dunno
                                     // (9) dunno
           &(process->minflt),       // - (10) The number of minor faults the process has made which have not required
                                        // loading a memory page from disk.
           &(process->cminflt),      // - (11) The number of minor faults that the process's waited-for children have made.
           &(process->majflt),       // - (12) The number of major faults the process has made which have required loading a
                                        // memory page from disk.
           &(process->cmajflt),      // - (13) The number of major faults that the process's waited-for children have made.
           &utime,                   // - (14) Amount of time that this process has been scheduled in user mode;
           &stime,                   // - (15) Amount of time that this process has been scheduled in kernel mode;
                                     // - (16) Amount of time that this process's waited-for children have been scheduled in user mode;
                                     // - (17) Amount of time that this process's waited-for children have been scheduled in kernel mode;
                                     // (18) dunno
           &(process->nice),         // - (19) The nice value (see setpriority(2)), a value in the range 19 (low priority) to
                                     // -20 (high priority).
           &(process->num_threads),  // - (20) Number of threads in this process
                                     // (21) useless
           &(process->starttime),    // - (22) The time the process started after system boot
           &(process->vsize),        // - (23) Virtual memory size in bytes.
           &(process->rss),          // - (24) Resident Set Size: number of pages the process has in real memory.
           &(process->rsslim)        // - (25) Current soft limit in bytes on the rss of the process; see the description of
                                     // RLIMIT_RSS in getrlimit(2).
    );

    long num_ticks_per_sec = sysconf(_SC_CLK_TCK);

    if (process->last_update_time.tv_sec != 0) {
        // not the first time we update the values
        // we can compute the %values (% cpu usage)
        // if it worked 10 cpu secs and the last update was 15 secs ago, process has 66% of the CPU
        
        // how many nano seconds passed since last update
        double ms_elapsed = (current_time.tv_sec - process->last_update_time.tv_sec) * 1e3 +
                               (current_time.tv_nsec - process->last_update_time.tv_nsec) / 1e6;
               
        int ms_cpu_used = (1000 * utime / num_ticks_per_sec) + (1000 * stime / num_ticks_per_sec) - process->user_time_ms - process->system_time_ms;
        process->cpu_percentage = 100.0 * ms_cpu_used / ms_elapsed;
    } else {
        process->cpu_percentage = 0.0;
    }

    process->user_time_ms = 1000 * utime / num_ticks_per_sec;
    process->system_time_ms = 1000 * stime / num_ticks_per_sec;

    // move data into process (like wall time, etc)

    process->last_update_time = current_time;
}

void updateProcessStatsRecursive(struct ProcessStats* process) {
    updateProcessStats(process);
    struct ProcessStats** children = process->children;
    while (*children != NULL) {
        updateProcessStatsRecursive(*children);
        children++;
    }
}

struct ProcessStats* getProcessStats(pid_t pid) {
    // read children pids from /proc/$(pid)/task/$(pid)/children
    char* pid_str = to_char(pid);
    int pid_size = strlen(pid_str);

    // compute file to read
    int total_size = 21 + 2 * pid_size;
    static char children_path[1024];
    children_path[total_size] = '\0';
    strcpy(children_path, "/proc/");
    strcpy(children_path + 6, pid_str);
    strcpy(children_path + 6 + pid_size, "/task/");
    strcpy(children_path + 6 + pid_size + 6, pid_str);
    strcpy(children_path + 6 + pid_size + 6 + pid_size, "/children");
    // opening file
    int fd = open(children_path, O_RDONLY);
    if (fd == -1) {
        perror(NULL);
        exit(errno);
    }

    // reading file
    int num_children = 0;
    static char buff[1024];
    int rc = xread(fd, buff, 1023);
    if (rc < 0) {
        perror(NULL);
        exit(errno);
    }

    buff[rc+1] = '\0';

    // determining number of children based on the number of spaces
    char* c = buff;
    while (*c != '\0') {
        if (*c == ' ') {
            num_children += 1;
            c += 1;
        }
        c += 1;
    }

    // create the process object
    // with some okish default values
    struct ProcessStats* process = (struct ProcessStats*)xmalloc(sizeof(struct ProcessStats));
    process->pid = pid;
    process->last_update_time.tv_nsec = 0;
    process->last_update_time.tv_sec = 0;
    process->children = (struct ProcessStats**)xmalloc((num_children + 1) * sizeof(struct ProcessStats*));

    // getting children pids
    c = buff;
    int* children_pid = (int*)xmalloc((num_children + 1) * (sizeof(int)));
    for (int i = 0; i < num_children; i += 1) {
        int x = 0;
        while (*c != ' ') {
            x *= 10;
            x += *c - '0';
            c += 1;
        }
        c += 1;
        children_pid[i] = x;
    }

    // calling the function recursively for each child-pid
    for (int i = 0; i < num_children; i += 1) {
        process->children[i] = getProcessStats(children_pid[i]);
        if (process->children[i] == NULL) {
            // if somehow a child died durring our read or something, erase it
            i -= 1;
            num_children -= 1;
        }
    }

    // make last child NULL for sentinel
    process->children[num_children] = NULL;

    // erase malloced memory
    free(children_pid);

    // update child info
    updateProcessStats(process);
    return process;
}
