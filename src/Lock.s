[bits 64]
[default rel]

global lockInit
global lockAcquire
global lockRelease

lockInit:
lockRelease:

    mov qword [rdi], 0x0

    ret

lockAcquire:

    push rax
    push rdx

    mov rdx, 0x1

.__tryLock:

    xor rax, rax
    lock cmpxchg [rdi], rdx
    jne .__tryLock

    pop rdx
    pop rax

    ret
