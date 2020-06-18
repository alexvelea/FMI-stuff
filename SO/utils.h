#ifndef UTILS
#define UTILS

#include <stdio.h>
#include <stdarg.h>
#include <stdlib.h>
#include <unistd.h>
#include <errno.h>

#include <sys/stat.h>

#define NONRET __attribute__((noreturn))
#define UNUSED __attribute__((unused))
#define GENERATE_PRINTF_WARNINGS __attribute__((format(printf, 1, 2)))

int xread(int fd, void *buf, int len)
{
	int rc;
	while (1) {
		rc = read(fd, buf, len);
		if ((rc < 0) && (errno == EAGAIN || errno == EINTR))
			continue;

        return rc;
	}
}

int xwrite(int fd, const void *buf, int len) 
{
	int write_size;
	while (len) {
	    write_size = write(fd, buf, len);
        
		if (write_size < 0) {
            if (errno == EAGAIN || errno == EINTR)
			    continue;
            
            return 0;
        }

		buf = (char*)(buf) + write_size;
        len -= write_size;
	}

    return 1;
}

void xwrite_callback(char* buff, int len, void* bind)
{
    xwrite(*(int*)(bind), buff, len);
}


void NONRET GENERATE_PRINTF_WARNINGS die(const char* msg, ...) 
{
    va_list args;
    va_start(args, msg);
    char buf[1024];
    int n = vsnprintf(buf, sizeof(buf), msg, args);

    xwrite(2, buf, n);
    xwrite(2, "\n", 1);
    exit(2);
}

void GENERATE_PRINTF_WARNINGS msg(const char* msg, ...)
{
    va_list args;
    va_start(args, msg);
    char buf[1024];
    int n = vsnprintf(buf, sizeof(buf), msg, args);
    xwrite(2, buf, n);
    xwrite(2, "\n", 1);   
    fsync(2);
    va_end(args);
}

void* xmalloc(size_t size)
{
    void* ptr = malloc(size);
    if (ptr == NULL) {
        die("Can't malloc");
    }
    return ptr;
}

int valid_path(const char* path) 
{
    struct stat st;
    return (stat(path, &st) >= 0);
}

int dir_exists(const char * path)
{
    struct stat st;
    return (stat(path, &st) >= 0 && S_ISDIR(st.st_mode));
}

int file_exists(const char * path)
{
    struct stat st;
    return (stat(path, &st) >= 0 && S_ISREG(st.st_mode));
}

void read_all_from_fd(int read_fd, void (*callback)(char*, int, void*), void* bind)
{
    char buff[1024];

    while (1) {
        int len = read(read_fd, buff, sizeof(buff));
        if (len == -1) {
            if (errno == EINTR || errno == EAGAIN) {
                continue;
            }

            die("Error while reading %m");
        }

        if (len == 0) {
            /// EOF
            return;
        }
 
        callback(buff, len, bind);
    }
}

int same_file(int fd1, int fd2)
{
    struct stat stat1, stat2;
    if(fstat(fd1, &stat1) < 0) return -1;
    if(fstat(fd2, &stat2) < 0) return -1;
    return (stat1.st_dev == stat2.st_dev) && (stat1.st_ino == stat2.st_ino);
}

#endif
