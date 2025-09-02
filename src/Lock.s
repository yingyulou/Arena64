[bits 64]
[default rel]

global lockInit
global lockAcquire
global lockRelease

lockInit:

    mov qword [rdi], 0x0
    mov qword [rdi + 0x8], 0x0

    ret

lockAcquire:

    push rax
    push rdx

    mov rdx, 0x1

.__tryLock:

    xor rax, rax
    lock cmpxchg [rdi], rdx
    jne .__tryLock

    pushf
    pop qword [rdi + 0x8]
    cli

    pop rdx
    pop rax

    ret

lockRelease:

    mov qword [rdi], 0x0

    push qword [rdi + 0x8]
    popf

    ret
