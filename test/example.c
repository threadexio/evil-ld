#define _GNU_SOURCE

#include <stdio.h>
#include <stdlib.h>
#include <sys/personality.h>
#include <unistd.h>

static void fatal(const char* s) {
  perror(s);
  exit(1);
}

#define isset(x, v) (((x) & (v)) == (v))

int main(int argc, const char** argv) {
  printf("Hello world!\n");

  printf("argv: '%s'", argv[0]);
  for (int i = 1; i < argc; i++) printf(", '%s'", argv[i]);
  printf("\n");

  uid_t ruid, euid, suid;
  if (getresuid(&ruid, &euid, &suid) != 0) fatal("getresuid");
  printf("ruid=%d euid=%d suid=%d\n", ruid, euid, suid);

  int persona = personality(0xffffffff);
  if (isset(persona, ADDR_NO_RANDOMIZE))
    printf("[*] address randomization is disabled!\n");

  return 0;
}
