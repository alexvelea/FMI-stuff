#include <errno.h>
#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#include <sys/types.h>
#include <unistd.h>

#include "mock.h"

pid_t xclone(void (*child_callback)(void*), void* arg) {
    pid_t child_pid = fork();
    if (child_pid < 0) {
        perror(NULL);
        exit(errno);
    } else if (child_pid == 0) {
        child_callback(arg);
        exit(0);
    } else {
        return child_pid;
    }
}

const double time_interval = 1.0 / 1e2; // seconds
int num_work_op_per_sec = 1.5e8;

void worker(double percentage_sleep) {
    fprintf(stderr, "Process %d should work %.3f%s of the time\n", getpid(), (1.0 - percentage_sleep) * 100.0, "%");
    fflush(stderr);

    struct timespec ts;
/*    
    {
        time_t tv_sec; seconds
        long tv_nsec;  nanoseconds
    };
*/

    int mx_sleep = 1e9 * time_interval * percentage_sleep;
    int mx_work = 1.0 * num_work_op_per_sec * time_interval * (1.0 - percentage_sleep);

    while (1) {
        if (mx_sleep) {
            ts.tv_nsec = rand() % mx_sleep;
            nanosleep(&ts, NULL);
        }

        if (mx_work) {
            int num_work = rand() % mx_work;
            int s = 0;
            for (int i = 0; i < num_work; i += 1) {
                s += rand();
            }
        }
    }
}

void createChildren(void* p) {
    struct ProcessStats* process = (struct ProcessStats*)(p);
    struct ProcessStats** next_process = process->children;
    while (*next_process != NULL) {
        xclone(createChildren, (void*)(*next_process));
        next_process += 1;
    }
    
    srand(getpid());

    double percentage_sleep = 1.0 * rand() / RAND_MAX / 3 + 0.66;
    worker(percentage_sleep);
}

void computeRand() {
    struct timespec start_time;
    clock_gettime(CLOCK_REALTIME, &start_time);
    int s = 0;
    for (int i = 0; i < (int)1e7; i += 1) {
        s += rand();
    }

     struct timespec end_time;
    clock_gettime(CLOCK_REALTIME, &end_time);   
    
    double nsec_elapsed = (end_time.tv_sec - start_time.tv_sec) * 1e9 
        + (end_time.tv_nsec - start_time.tv_nsec);

    num_work_op_per_sec = 1e7 / (nsec_elapsed / 1e9);
}

int main() {
    // compute the number of rand operations per sec
    computeRand();

    xclone(createChildren, (void*)(getMock()));
    sleep(1);
    printf("%d\n", getpid());
    fflush(stdout);
    struct timespec ts;
    ts.tv_sec = 1000;
    nanosleep(&ts, NULL);
}
