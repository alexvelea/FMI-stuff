# trace-children
The 2k18 way to trace a process children in linux

Tired of checking top every time to see the stats on that pesky crypto node?  
Do you like cool-looking, accurate and meaningful stats?
### Then trace-children is for you!

### How to install 🥇
```
git clone https://github.com/alexvelea/trace-children
cd trace-children
cmake CMakeLists.txt
sudo make install
```

### How to use 🏃
```
tracechildren 4607
```
Possible output 🌳
```
    ┌─────────────────────────────────────────────────────────────┐
    │ pid             53539       name            fork_test       │
 ╔═ │ cpu%            0.0         cputime         0:00.100        │
 ║  │ systime         0:00.000    walltime        4:56.868        │
 ║  │ virtual memory  4.3MB       real memory     0.7MB           │
 ║  └─────────────────────────────────────────────────────────────┘
 ║      ┌─────────────────────────────────────────────────────────────┐
 ║      │ pid             53540       name            fork_test       │
 ╚═══╦═ │ cpu%            1.0         cputime         0:03.440        │
     ║  │ systime         0:00.190    walltime        4:55.254        │
     ║  │ virtual memory  4.3MB       real memory     88KB            │
     ║  └─────────────────────────────────────────────────────────────┘
     ║      ┌─────────────────────────────────────────────────────────────┐
     ║      │ pid             53542       name            fork_test       │
     ╠═══╦═ │ cpu%            2.0         cputime         0:06.330        │
     ║   ║  │ systime         0:00.180    walltime        4:55.150        │
     ║   ║  │ virtual memory  4.3MB       real memory     92KB            │
     ║   ║  └─────────────────────────────────────────────────────────────┘
     ║   ║      ┌─────────────────────────────────────────────────────────────┐
     ║   ║      │ pid             53544       name            fork_test       │
     ║   ╠═══╦═ │ cpu%            3.0         cputime         0:09.630        │
     ║   ║   ║  │ systime         0:00.240    walltime        4:55.141        │
     ║   ║   ║  │ virtual memory  4.3MB       real memory     92KB            │
     ║   ║   ║  └─────────────────────────────────────────────────────────────┘
     ║   ║   ║      ┌─────────────────────────────────────────────────────────────┐
     ║   ║   ║      │ pid             53548       name            fork_test       │
     ║   ║   ╚═════ │ cpu%            2.0         cputime         0:04.750        │
     ║   ║          │ systime         0:00.230    walltime        4:55.142        │
     ║   ║          │ virtual memory  4.3MB       real memory     92KB            │
     ║   ║          └─────────────────────────────────────────────────────────────┘
     ║   ║      ┌─────────────────────────────────────────────────────────────┐
     ║   ║      │ pid             53545       name            fork_test       │
     ║   ╚═══╦═ │ cpu%            0.0         cputime         0:00.960        │
     ║       ║  │ systime         0:00.200    walltime        4:55.142        │
     ║       ║  │ virtual memory  4.3MB       real memory     92KB            │
     ║       ║  └─────────────────────────────────────────────────────────────┘
     ║       ║      ┌─────────────────────────────────────────────────────────────┐
     ║       ║      │ pid             53546       name            fork_test       │
     ║       ╚═════ │ cpu%            3.0         cputime         0:07.070        │
     ║              │ systime         0:00.180    walltime        4:55.143        │
     ║              │ virtual memory  4.3MB       real memory     92KB            │
     ║              └─────────────────────────────────────────────────────────────┘
     ║      ┌─────────────────────────────────────────────────────────────┐
     ║      │ pid             53543       name            fork_test       │
     ╚═════ │ cpu%            2.0         cputime         0:07.920        │
            │ systime         0:00.160    walltime        4:55.156        │
            │ virtual memory  4.3MB       real memory     92KB            │
            └─────────────────────────────────────────────────────────────┘
```

### Want to use as a library? 📖
```
#include <trace_children.h>
#include <unistd.h>

int main(int argc, char* argv[]) {
    struct ProcessStats* root = getProcessStats(1);
    sleep(1); // wait 1 sec for that juicy percentage information
    updateProcessStatsRecursive(root); 
    printProcessStats(root);
    dealloc(root); // we don't like leaks
    return 0;
}
```

### Do you like low compile times or you have a bigger project?
Use static library to solve all your problems! 🎉  
Just add the 2 magic flags: `-Dtracechildrenuselib -ltracechildrenlib`

### Want to test trace-children in your house with a nice example?
After installing, in the repository directory, run
```
 make; mkfifo a; ./build/bin/fork_test >a & ./build/bin/tracechildren <a && pkill fork_test; && rm a
```
