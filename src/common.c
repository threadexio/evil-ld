#include "common.h"

#include "syscalls.h"

void print(const char *s) { write(STDERR_FILENO, s, strlen(s)); }

void println(const char *s) {
  print(s);
  print("\n");
}

#ifdef DEBUG
void debug(const char *s) {
  print("[" DIM NAME RESET "] ");
  print(s);
}

void debugln(const char *s) {
  debug(s);
  print("\n");
}

void debug_argv(char **argv) {
  print("'" YELLOW);
  print(argv[0]);
  print(RESET "'");

  argv += 1;
  while (*argv != NULL) {
    print(", '");
    print(*argv);
    print("'");
    argv += 1;
  }
}

#else
void debug(const char *s) { (void)s; }
void debugln(const char *s) { (void)s; }
void debug_argv(char **argv) { (void)argv; }
#endif

void *memrchr(const void *s, int c, size_t n) {
  const char *_s = (const char *)s;

  for (size_t i = 0; i < n; i++) {
    size_t k = n - i - 1;
    if (_s[k] == c) return (void *)(_s + k);
  }

  return NULL;
}

size_t strlen(const char *s) {
  size_t len = 0;
  while (*s++ != 0) len++;
  return len;
}

bool streq(const char *a, const char *b) {
  size_t len_a = strlen(a);
  size_t len_b = strlen(b);

  size_t len = (len_a < len_b) ? len_a : len_b;

  for (size_t i = 0; i < len; i++)
    if (a[i] != b[i]) return false;

  return true;
}

const char *basename(const char *path) {
  const char *r = (const char *)memrchr(path, '/', strlen(path));

  if (r == NULL) {
    return path;
  } else {
    return r + 1;
  }
}
