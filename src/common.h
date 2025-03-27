#ifndef COMMON_H
#define COMMON_H

#include <stdbool.h>
#include <stddef.h>

#define STDOUT_FILENO 1
#define STDERR_FILENO 2

#define BOLD "\x1b[1m"
#define DIM "\x1b[2m"
#define UNDERLINE "\x1b[4m"
#define RESET "\x1b[0m"

#define RED "\x1b[31m"
#define GREEN "\x1b[32m"
#define YELLOW "\x1b[33m"

void print(const char *s);
void println(const char *s);
void debug(const char *s);
void debugln(const char *s);
void debug_argv(char **argv);

void *memrchr(const void *s, int c, size_t n);
size_t strlen(const char *s);
bool streq(const char *a, const char *b);
const char *basename(const char *path);
const char* strerror(int errno);

#endif
