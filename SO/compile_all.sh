#!/bin/bash

gcc -std=gnu99 f1.c -o f1
gcc -std=gnu99 f9.c -o f9
gcc -std=gnu99 f13.c -o f13
gcc -std=gnu99 f15.c -o f15
gcc -std=gnu99 a16.c -o a16
gcc -std=gnu99 d6.c -DVERBOSE2 -o d6

