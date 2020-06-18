#include <unistd.h>
#include <string.h>
#include <stdlib.h>

#include "utils.h"

extern char** environ;

char** GetEnvVar(char* search) 
{
    char** start = environ;
    int size = strlen(search);

    char** answer = NULL;
    while (*start != NULL) 
    {
        if (strncmp(*start, search, size) == 0) 
        {
            answer = start;
            break;
        }
        start++;
    }

    return answer;
}

char* set_environ(char** env_pointer, char* txt) 
{
/*
 *  Can't free environ pointer.
 *  free(*env_pointer);
*/
    char* old_value = *env_pointer;
    *env_pointer = txt;
    return old_value;
}

// debug purpose :)
void print_all_environment() 
{
    char** start = environ;
    while (*start != NULL) 
    {
        msg("Environment:%s\n", *start);
        start++;
    }
}

int main()
{
    char* search = strdup("TERM");
    char** term = GetEnvVar(search);

    if (term == NULL)
        die("TERM variable not found");
    else 
    {
        fprintf(stderr, "Before fork:%s\n", *term);
        fflush(stderr);
    }

    char* new_term_value = strdup("TERM=vt52");
    char* old_term_value = set_environ(term, new_term_value);

    // fork child
    pid_t pid = fork();
    if (pid == 0) 
    {
        // child process
//        PrintAllEnvironment();
        char** p = GetEnvVar(search);
        if (p == NULL)
            die("Can't find TERM in forked child\n");

        fprintf(stderr, "Forked process: %s\n", *p);
        fflush(stderr);
    } 
    else if (pid > 0) 
    {
        // parent stuff
        // put variable back
        char** term = GetEnvVar(search);
        set_environ(term, old_term_value);

        char** p = GetEnvVar(search);
        if (p == NULL)
            die("Can't find TERM in main process\n");

        fprintf(stderr, "main process: %s\n", *p);
        fflush(stderr);
    } 
    else 
    {
        die("fork failed. %m\n");
    }

    free(search);
    return 0;
}
