section .text

global exit
exit:
    mov ebx, [esp+4]
    mov eax, 1
    int 0x80
    ud2

global write
write:
    push ebp
    mov ebp, esp
    push ebx

    mov edx, [ebp+16]
    mov ecx, [ebp+12]
    mov ebx, [ebp+8]
    mov eax, 4
    int 0x80

    pop ebx
    pop ebp
    ret

global personality
personality:
    push ebp
    mov ebp, esp
    push ebx

    mov ebx, [ebp+8]
    mov eax, 136
    int 0x80

    pop ebx
    pop ebp
    ret

global setresuid
setresuid:
    push ebp
    mov ebp, esp
    push ebx

    mov edx, [ebp+16]
    mov ecx, [ebp+12]
    mov ebx, [ebp+8]
    mov eax, 164
    int 0x80

    pop ebx
    pop ebp
    ret
