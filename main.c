#include <linux/personality.h>
#include <stdbool.h>
#include <stddef.h>

#ifndef NAME
#define NAME "evil-ld"
#endif

#ifndef REAL_LD
#define REAL_LD "/lib/ld-linux.so.2"
#endif

#define STDOUT_FILENO 1
#define STDERR_FILENO 2

#define BOLD "\x1b[1m"
#define DIM "\x1b[2m"
#define UNDERLINE "\x1b[4m"
#define RESET "\x1b[0m"

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

// Exported by entry.s
extern void exit(int status) __attribute__((noreturn));
extern size_t write(int fd, const char *buf, size_t len);
extern int personality(unsigned long persona);
extern int run(const char *linker, int argc, char *const target_argv[],
               char *const target_envp[]);

int main(int argc, char **argv, char **envp) {
  int target_argc = argc;
  char **target_argv = argv;

#ifdef DEBUG
  debug("linker argv: ");
  debug_argv(argv);
  print("\n");
#endif

  // If argv[0] is the real executable, then omit this from the argv we are
  // going to pass to the target program. This allows running the program like
  // this:
  //
  // $ ./evil-ld /bin/ls
  //
  // And also allows this:
  //
  // $ env --arg0=/bin/ls ./evil-ld
  //
  if (streq(basename(argv[0]), NAME)) {
    target_argc -= 1;
    target_argv = &argv[1];
  }

  if (target_argc == 0) {
    print("usage: " DIM);
    print(argv[0]);
    println(RESET " " BOLD UNDERLINE "program" RESET " " BOLD "args..." RESET);
    exit(1);
  }

#ifdef DEBUG
  debug("target argv: ");
  debug_argv(target_argv);
  print("\n");
#endif

  int err;

#ifdef DISABLE_ASLR
  err = personality(ADDR_NO_RANDOMIZE);
  if (err < 0) {
    println("failed to set the no-ASLR personality");
    return -err;
  }
#endif

  err = run(REAL_LD, target_argc, target_argv, envp);
  println("failed to execute target program");
  return -err;  // The underlying `execve` returns -errno on any error. Let's
                // return the raw errno and let the user figure it out.
}

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
