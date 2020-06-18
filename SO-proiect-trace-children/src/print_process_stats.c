#include "print_process_stats.h"

#include <stdio.h>
#include <sys/times.h>
#include <unistd.h>
#include <string.h>

void printPrefix(int depth, int child_mask) {
    for (int i = 0; i <= depth; i += 1) {
        for (int j = 1; j < INDENT_LEVEL / 2; j += 1) {
            printf(" ");
        }

        if ((1 << i) & child_mask) {
            printf("║");
        } else {
            printf(" ");
        }

        for (int j = INDENT_LEVEL / 2; j < INDENT_LEVEL; j += 1) {
            printf(" ");
        }
    }
}
void printProcessStatsInternalInformation(struct ProcessStats* process, int depth, int child_mask, int is_last_child) {
    struct timespec current_time;
    clock_gettime(CLOCK_MONOTONIC, &current_time);

    long wall_time_ms = 1000 * ((current_time.tv_sec + 1.0 * current_time.tv_nsec / 1e9) -
                                1.0 * process->starttime / sysconf(_SC_CLK_TCK));

    static char buff[65];
    memset(buff, 0, sizeof(buff));
    
    if (depth != 0) { printPrefix(depth, child_mask | (1 << (depth - 1)));  } else { printf("   "); }
    printf("┌");
    for (int i = 0; i < 64 - 1 - 2; i += 1) { printf("─"); }
    printf("┐");
    printf("\n");

    sprintf(buff, "│ pid             %d", process->pid);
    int name_len = strlen(process->name);
    process->name[name_len - 1] = '\0';

    sprintf(buff + 32, "name            %s", process->name + 1);
    while (strlen(buff) < 64) { buff[strlen(buff)] = ' '; } buff[64] = '\0';
    if (depth != 0) { printPrefix(depth, child_mask | (1 << (depth - 1)));  } else { printf("    "); }
    printf("%s│\n", buff); memset(buff, 0, sizeof(buff));
    process->name[name_len - 1] = ')';

    sprintf(buff, "│ cpu%s            %.1lf", "%", process->cpu_percentage);
    while (strlen(buff) < 32) { buff[strlen(buff)] = ' '; };

    sprintf(buff + 32, "cputime         %ld:%02ld.%03ld", 
            (process->user_time_ms + process->system_time_ms) / 1000 / 64,
            ((process->user_time_ms + process->system_time_ms) / 1000) % 64,
            (process->user_time_ms + process->system_time_ms) % 1000);
    while (strlen(buff) < 64) { buff[strlen(buff)] = ' '; } buff[64] = '\0';

    if (depth != 0) {
        printPrefix(depth - 2, child_mask);

        for (int j = 1; j < INDENT_LEVEL / 2; j += 1) {
            printf(" ");
        }

        if (is_last_child) {
            printf("╚");
        } else {
            printf("╠");
        }

        for (int j = INDENT_LEVEL / 2; j < INDENT_LEVEL; j += 1) {
            printf("═");
        }

        for (int j = 1; j < INDENT_LEVEL / 2; j += 1) {
            printf("═");
        }

        if (process->children[0] != NULL) {
            child_mask |= (1 << depth);
            if (depth == 0) {
                printf("╔");
            } else {
                printf("╦");  // ╦
            }
        } else {
            printf("═");
        }

        for (int j = INDENT_LEVEL / 2; j < INDENT_LEVEL - 1; j += 1) {
            printf("═");
        }
        printf(" ");
    } else {
        printf(" ╔═ ");
    }
    
    printf("%s│\n", buff); memset(buff, 0, sizeof(buff));
    sprintf(buff, "│ systime         %ld:%02ld.%03ld", 
            (process->system_time_ms / 1000) / 64, 
            (process->system_time_ms / 1000) % 64, 
            process->system_time_ms % 1000);
    while (strlen(buff) < 32) { buff[strlen(buff)] = ' '; };
    sprintf(buff + 32, "walltime        %ld:%02ld.%03ld", 
            (wall_time_ms) / 1000 / 64,
            ((wall_time_ms) / 1000) % 64,
            (wall_time_ms) % 1000);
    while (strlen(buff) < 64) { buff[strlen(buff)] = ' '; } buff[64] = '\0';
    printPrefix(depth, child_mask); printf("%s│\n", buff); memset(buff, 0, sizeof(buff));
    
    int page_size = getpagesize();

    int virtual_mem_kb = process->vsize >> 10;
    int mem_kb = (process->rss * page_size) >> 10;
    
    if (virtual_mem_kb < 512) {
    sprintf(buff, "│ virtual memory  %dKB", virtual_mem_kb);
    } else {
    sprintf(buff, "│ virtual memory  %.01fMB", 1.0 * virtual_mem_kb / (1 << 10));
    }

    while (strlen(buff) < 32) { buff[strlen(buff)] = ' '; }

    if (mem_kb < 512) {
    sprintf(buff + 32, "real memory     %dKB", mem_kb);
    } else {
    sprintf(buff + 32, "real memory     %.01fMB", 1.0 * mem_kb / (1 << 10));
    }

    while (strlen(buff) < 64) { buff[strlen(buff)] = ' '; } buff[64] = '\0';
    printPrefix(depth, child_mask); printf("%s│\n", buff); memset(buff, 0, sizeof(buff));
 
    printPrefix(depth, child_mask); 
    printf("└");
    for (int i = 0; i < 64 - 1 - 2; i += 1) { printf("─"); }
    printf("┘");
    printf("\n");
}

void printProcessStatsInternal(struct ProcessStats* process, int depth, int child_mask, int is_last_child) {
    // print prefix for process

    // print data about the process
    printProcessStatsInternalInformation(process, depth, child_mask, is_last_child);

    if (process->children[0] != NULL) {
        child_mask |= (1 << depth);
    }

    // calling on children with the cool-looking border UI
    struct ProcessStats** next_process = process->children;
    while (*next_process != NULL) {
        int next_mask = child_mask;
        int last_child = (*(next_process + 1)) == NULL;

        if (last_child) {
            next_mask ^= (1 << depth);
        }

        printProcessStatsInternal(*next_process, depth + 1, next_mask, last_child);
        next_process++;
    }
}

