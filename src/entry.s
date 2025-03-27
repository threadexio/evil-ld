section .text

extern main
extern exit

global _start
_start:
    ; setup the stack
    mov ebp, esp

    ; argc is [ebp]
    ; argv is ebp + 4
    ; envp is ebp + 4 + 4*argc + 4

    ; envp
    mov eax, [ebp]
    add eax, 2
    imul eax, 4
    add eax, ebp
    push eax

    ; argv
    mov eax, ebp
    add eax, 4
    push eax

    ; argc
    mov eax, [ebp]
    push eax

    call main

    push eax
    call exit

