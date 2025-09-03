%include "Boot.inc"

[bits 64]
[default rel]

extern hdRead
extern syscallInit
extern apStack

global apInit

__CPU_COUNT equ 4

apInit:

    push rdx
    push rsi
    push rdi

    mov rdi, __BOOT_ADDR
    mov rsi, 1
    mov rdx, 1
    call hdRead

    sgdt [abs __BOOT_ADDR + 0x8]
    sidt [abs __BOOT_ADDR + 0x18]
    mov rdx, apBoot64
    mov [abs __BOOT_ADDR + 0x28], rdx

    mov rdi, 0xffff8000fee00300
    mov dword [rdi], 0x000c4500
    db 0xeb, 0x0
    mov dword [rdi], 0x000c4600 | (__BOOT_ADDR >> 12)

.__waitAP:

    cmp dword [apInitFlag], __CPU_COUNT
    jne .__waitAP

    pop rdi
    pop rsi
    pop rdx

    ret

apBoot64:

    lgdt [abs __BOOT_ADDR + 0x8]
    lidt [abs __BOOT_ADDR + 0x18]

    mov r8, 0xffff8000fee00020
    mov r8d, [r8]
    shr r8, 24

    mov r9, apStack
    lea rax, [r8 - 1]
    shl rax, 12
    add r9, rax

    lea rsp, [r9 + 0x1000]

    mov rbx, 0xffff8000fee00000
    bts dword [rbx + 0xf0], 8
    mov dword [rbx + 0x320], 0x20020
    mov dword [rbx + 0x3e0], 0xb
    mov dword [rbx + 0x380], 0xffff

    mov rbx, 0xffff8000fec00000
    mov dword [rbx], 0x12
    mov dword [rbx + 0x10], 0x21
    mov dword [rbx], 0x13
    mov dword [rbx + 0x10], 0x0

    lea rax, [r8 * 2 + 7]
    shl rax, 3
    ltr ax

    mov ecx, 0xc0000101
    lea rax, [r9 + 0x28]
    mov rdx, rax
    shr rdx, 32
    wrmsr

    call syscallInit

    lock inc dword [apInitFlag]

    sti

.__idle:

    hlt
    jmp .__idle

apInitFlag:
    dd 0x1
