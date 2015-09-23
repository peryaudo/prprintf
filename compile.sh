#!/bin/sh
gcc -m32 -c prprintf.s -o prprintf.o
gcc -m32 -c main.c -o main.o
gcc -m32 main.o prprintf.o -o prprintf
./prprintf
