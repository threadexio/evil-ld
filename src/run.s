section .text

; int run(const char* linker, int target_argc, char** target_argv, char** target_envp)
global run
run:
    push ebp
    mov ebp, esp
    push ebx
    push esi

    ; Calculate how many bytes the `new_argv` array will take up.
    ; 
    ;   new_argv = [ linker ] + target_argv
    ;
    ; Therefore:
    ;
    ;   sizeof(new_argv) = sizeof(linker) + sizeof(target_argv)
    ;                    = 4 + (target_argc * 4 + 4)
    ;                    = 4 * (1 + target_argc + 1)
    ;                    = 4 * (target_argc + 2)
    ;
    ; Save the size in `esi`. We are going to need it later to "free" the
    ; `new_argv` array.
    mov esi, [ebp+12] ; [ebp+12] is `target_argc`
    add esi, 2
    imul esi, 4
    sub esp, esi

    mov eax, [ebp+16] ; [ebp+16] is `target_argv` - source
    mov ebx, esp      ; esp is `new_argv`         - destination

    ; Prepend the real linker.
    mov ecx, [ebp+8] ; [ebp+8] is `linker`
    mov [ebx], ecx
    add ebx, 4

    ; Copy over all remaining arguments.
  _copy_next_arg:
    mov ecx, [eax]
    mov [ebx], ecx
    add eax, 4
    add ebx, 4

    cmp ecx, 0
    jne _copy_next_arg

    ;;;;

    mov edx, [ebp+20]       ; target_envp
    mov ecx, esp            ; new_argv
    mov ebx, [ebp+8]        ; linker
    mov eax, 11             ; execve
    int 0x80                ; execve(linker, new_argv, target_envp)

    ; We need to "free" the `new_argv` array now. 
    add esp, esi

    pop esi
    pop ebx
    pop ebp
    ret
