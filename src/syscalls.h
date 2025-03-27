#ifndef SYSCALLS_H
#define SYSCALLS_H

#include <linux/personality.h>
#include <stddef.h>
#include <sys/types.h>

// Exported by syscalls.s
extern void exit(int status) __attribute__((noreturn));
extern size_t write(int fd, const char *buf, size_t len);
extern int personality(unsigned long persona);
extern int setresuid(uid_t ruid, uid_t euid, uid_t suid);
extern int run(const char *linker, int argc, char *const target_argv[],
               char *const target_envp[]);

#endif
