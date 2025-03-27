#include "common.h"
#include "syscalls.h"

#ifndef NAME
#define NAME "evil-ld"
#endif

#ifndef REAL_LD
#define REAL_LD "/lib/ld-linux.so.2"
#endif

int main(int argc, char **argv, char **envp) {
  int target_argc = argc;
  char **target_argv = argv;

#ifdef DEBUG
  debugln(
      "built with:\n"
      "\n"
      "  REAL_LD        " YELLOW REAL_LD RESET
      "\n"
      "  KEEP_SUID      "
#ifdef KEEP_SUID
      BOLD GREEN "Yes" RESET
#else
      BOLD RED "No" RESET
#endif
      "\n"
      "  DISABLE_ASLR   "
#ifdef DISABLE_ASLR
      BOLD GREEN "Yes" RESET
#else
      BOLD RED "No" RESET
#endif
      "\n");

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

#ifdef KEEP_SUID
  err = setresuid(0, 0, 0);
  if (err < 0) {
    println("failed to set r/e/s uids");
  }
#endif

#ifdef DISABLE_ASLR
  err = personality(ADDR_NO_RANDOMIZE);
  if (err < 0) {
    println("failed to set the no-ASLR personality");
  }
#endif

  err = run(REAL_LD, target_argc, target_argv, envp);
  println("failed to execute target program");
  return -err;  // The underlying `execve` returns -errno on any error. Let's
                // return the raw errno and let the user figure it out.
}
