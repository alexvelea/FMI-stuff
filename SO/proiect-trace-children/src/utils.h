#ifndef TRACE_CHILDREN_SRC_UTILS_H
#define TRACE_CHILDREN_SRC_UTILS_H

#include <sys/types.h>

#define NONRET __attribute__((noreturn))
#define UNUSED __attribute__((unused))
#define GENERATE_PRINTF_WARNINGS __attribute__((format(printf, 1, 2)))

int xread(int fd, void *buf, int len);

int xwrite(int fd, const void *buf, int len);

void* xmalloc(size_t size);

void xsleepms(int num_ms);

int valid_path(const char* path);

int dir_exists(const char * path);

int file_exists(const char * path);

char* to_char(int x);

#ifndef tracechildrenuselib
#include "tracechildren_src/utils.c"
#endif

#endif  // TRACE_CHILDREN_SRC_UTILS_H
