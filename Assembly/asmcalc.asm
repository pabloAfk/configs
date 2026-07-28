;   minha calculadora em assemblyy
;   nasm -f elf64 asmcalc.asm -o asmcalc.o
;   ld asmcalc.o -o asmcalc
;   ./asmcalc


section .data
    prompt          db "asmcalc > "
    prompt_len       equ $ - prompt

    msg_eq          db " = "
    msg_eq_len       equ $ - msg_eq

    msg_bye         db "Ate mais!", 10
    msg_bye_len      equ $ - msg_bye

    msg_err_div0    db "Erro: divisao por zero", 10
    msg_err_div0_len equ $ - msg_err_div0

    msg_err_sint    db "Erro: expressao invalida", 10
    msg_err_sint_len equ $ - msg_err_sint

    msg_err_paren   db "Erro: parenteses desbalanceados", 10
    msg_err_paren_len equ $ - msg_err_paren

    cmd_exit        db "exit"
    cmd_sair        db "sair"

section .bss
    buffer      resb 256      
    line_len    resq 1        
    pos         resq 1        
    error_flag  resb 1        
    numbuf      resb 32       

section .text
    global _start


_start:
main_loop:
    
    mov     rax, 1
    mov     rdi, 1
    mov     rsi, prompt
    mov     rdx, prompt_len
    syscall

    call    read_line           ; rax = bytes lidos (0 = EOF/Ctrl-D)
    cmp     rax, 0
    je      .fim

    cmp     qword [line_len], 0
    je      main_loop           

    mov     qword [pos], 0
    call    skip_spaces
    mov     rbx, [pos]
    cmp     rbx, [line_len]
    je      main_loop           

    call    is_exit_cmd         
    cmp     rax, 1
    je      .fim

    mov     qword [pos], 0
    mov     byte  [error_flag], 0

    call    parse_expr          

    cmp     byte [error_flag], 0
    jne     .erro

    call    skip_spaces
    mov     rbx, [pos]
    cmp     rbx, [line_len]
    je      .ok
    mov     byte [error_flag], 2  
   .erro:
    call    print_error
    jmp     main_loop

.ok:
    call    print_result
    jmp     main_loop

.fim:
    mov     rax, 1
    mov     rdi, 1
    mov     rsi, msg_bye
    mov     rdx, msg_bye_len
    syscall

    mov     rax, 60
    xor     rdi, rdi
    syscall

read_line:
    push    r12
    push    r13
    xor     r12, r12            ; r12 = quantos bytes ja guardados no buffer
    xor     r13, r13            ; r13 = flag: 1 se leu algum byte (para EOF correto)

.byte_loop:
    cmp     r12, 255            ; limite do buffer
    jge     .fim_linha

    xor     rax, rax            ; sys_read
    mov     rdi, 0
    lea     rsi, [buffer + r12]
    mov     rdx, 1
    syscall                     ; rax = bytes lidos (0 = EOF, 1 = ok)

    cmp     rax, 0
    jle     .checa_eof

    mov     r13, 1              ; leu pelo menos 1 byte nesaa chamada
    mov     al, [buffer + r12]
    cmp     al, 10              ; '\n' ?
    je      .fim_linha
    inc     r12
    jmp     .byte_loop

.checa_eof:
    cmp     r12, 0
    jne     .fim_linha          ; ja tinha alguma coisa no buffer
    pop     r13
    pop     r12
    xor     rax, rax
    mov     qword [line_len], 0
    ret

.fim_linha:
    mov     [line_len], r12
    mov     rax, 1              ; sinaliza q "leu algo" pro chamador
    pop     r13
    pop     r12
    ret

is_exit_cmd:
    mov     rcx, [line_len]
    cmp     rcx, 4
    jne     .nao

    mov     rsi, buffer
    mov     rdi, cmd_exit
    mov     rcx, 4
    repe    cmpsb
    je      .sim

    mov     rsi, buffer
    mov     rdi, cmd_sair
    mov     rcx, 4
    repe    cmpsb
    je      .sim

.nao:
    xor     rax, rax
    ret
.sim:
    mov     rax, 1
    ret

skip_spaces:
    push    rax
    push    rbx
.loop:
    mov     rbx, [pos]
    cmp     rbx, [line_len]
    jge     .fim
    mov     al, [buffer + rbx]
    cmp     al, ' '
    je      .avanca
    cmp     al, 9             
    je      .avanca
    jmp     .fim
.avanca:
    inc     qword [pos]
    jmp     .loop
.fim:
    pop     rbx
    pop     rax
    ret

peek_char:
    mov     rbx, [pos]
    cmp     rbx, [line_len]
    jge     .fim
    mov     al, [buffer + rbx]
    ret
.fim:
    xor     al, al
    ret

parse_expr:
    cmp     byte [error_flag], 0
    jne     .fim

    call    parse_term          ; rax = valor acumulado (esquerda)

.loop:
    cmp     byte [error_flag], 0
    jne     .fim

    call    skip_spaces
    push    rax                 ; preserva acumulador (peek_char usa rax)
    call    peek_char
    mov     dl, al              ; guarda o caractere lido
    pop     rax                 ; restaura acumulador

    cmp     dl, '+'
    je      .soma
    cmp     dl, '-'
    je      .sub
    jmp     .fim

.soma:
    push    rax                 ; guarda esquerda
    inc     qword [pos]
    call    parse_term          ; rax = direita
    mov     rbx, rax
    pop     rax                 ; rax = esquerda
    add     rax, rbx
    jmp     .loop

.sub:
    push    rax
    inc     qword [pos]
    call    parse_term
    mov     rbx, rax            ; rbx = direita
    pop     rax                 ; rax = esquerda
    sub     rax, rbx
    jmp     .loop

.fim:
    ret

parse_term:
    cmp     byte [error_flag], 0
    jne     .fim

    call    parse_factor        ; rax = valor acumulado (esquerda)

.loop:
    cmp     byte [error_flag], 0
    jne     .fim

    call    skip_spaces
    push    rax                 ; preserva acumulador (peek_char usa rax)
    call    peek_char
    mov     dl, al              ; guarda o caractere lido
    pop     rax                 ; restaura acumulador

    cmp     dl, '*'
    je      .mul
    cmp     dl, '/'
    je      .div
    jmp     .fim

.mul:
    push    rax
    inc     qword [pos]
    call    parse_factor
    mov     rbx, rax
    pop     rax
    imul    rax, rbx
    jmp     .loop

.div:
    push    rax
    inc     qword [pos]
    call    parse_factor
    mov     rbx, rax            ; divisor
    pop     rax                 ; dividendo

    cmp     byte [error_flag], 0
    jne     .fim

    cmp     rbx, 0
    jne     .divok
    mov     byte [error_flag], 1     ; divisao por zero
    jmp     .fim
.divok:
    cqo                          ; estende sinal de rax em rdx:rax
    idiv    rbx
    jmp     .loop

.fim:
    ret

parse_factor:
    cmp     byte [error_flag], 0
    jne     .fim

    call    skip_spaces
    call    peek_char

    cmp     al, '-'
    je      .neg
    cmp     al, '('
    je      .parenteses
    jmp     .numero

.neg:
    inc     qword [pos]
    call    parse_factor
    neg     rax
    ret

.parenteses:
    inc     qword [pos]
    call    parse_expr
    cmp     byte [error_flag], 0
    jne     .fim

    call    skip_spaces
    push    rax                 ; preserva resultado (peek_char usa rax)
    call    peek_char
    mov     dl, al              ; guarda o caractere lido
    pop     rax                 ; restaura resultado
    cmp     dl, ')'
    jne     .erro_paren
    inc     qword [pos]
    ret
.erro_paren:
    mov     byte [error_flag], 3
    ret

.numero:
    ; lê um ou mais dígitos; se nenhum -> erro de sintaxe
    xor     rax, rax
    xor     rcx, rcx            ; rcx = contador de dígitos

.dig_loop:
    push    rax                 ; preserva acumulador (peek_char usa rax)
    call    peek_char
    mov     dl, al              ; guarda o caractere lido
    pop     rax                 ; restaura acumulador

    cmp     dl, '0'
    jl      .dig_fim
    cmp     dl, '9'
    jg      .dig_fim

    sub     dl, '0'
    movzx   rbx, dl
    imul    rax, 10
    add     rax, rbx
    inc     qword [pos]
    inc     rcx
    jmp     .dig_loop

.dig_fim:
    cmp     rcx, 0
    jne     .fim
    mov     byte [error_flag], 2     ; esperava um número
.fim:
    ret

; ---------------------------------------------------------
; print_result: imprime " = <resultado>\n"
; ---------------------------------------------------------
print_result:
    push    rax
    mov     rax, 1
    mov     rdi, 1
    mov     rsi, msg_eq
    mov     rdx, msg_eq_len
    syscall
    pop     rax

    call    print_signed_number

    mov     rax, 1
    mov     rdi, 1
    mov     rsi, newline_byte
    mov     rdx, 1
    syscall
    ret

print_signed_number:
    push    rbx
    push    rcx
    push    rdx
    push    rsi
    push    rdi

    mov     rdi, numbuf + 31    ; ponteiro para o fim do buffer
    mov     byte [rdi], 0
    mov     rbx, 10

    ; trata sinal
    xor     rcx, rcx            ; rcx = 1 se negativo
    cmp     rax, 0
    jge     .conv
    mov     rcx, 1
    neg     rax

.conv:
    cmp     rax, 0
    jne     .loop
    dec     rdi
    mov     byte [rdi], '0'
    jmp     .sinal

.loop:
    cmp     rax, 0
    je      .sinal
    xor     rdx, rdx
    div     rbx                 ; rax / 10 -> rax=quociente, rdx=resto
    add     dl, '0'
    dec     rdi
    mov     [rdi], dl
    jmp     .loop

.sinal:
    cmp     rcx, 1
    jne     .imprime
    dec     rdi
    mov     byte [rdi], '-'

.imprime:
    ; calcula tamanho da string
    mov     rsi, rdi
    mov     rdx, numbuf + 31
    sub     rdx, rdi            ; rdx = tamanho

    mov     rax, 1
    mov     rdi, 1
    syscall

    pop     rdi
    pop     rsi
    pop     rdx
    pop     rcx
    pop     rbx
    ret

print_error:
    mov     al, [error_flag]
    cmp     al, 1
    je      .div0
    cmp     al, 3
    je      .paren
    ; default = sintaxe
    mov     rax, 1
    mov     rdi, 1
    mov     rsi, msg_err_sint
    mov     rdx, msg_err_sint_len
    syscall
    ret
.div0:
    mov     rax, 1
    mov     rdi, 1
    mov     rsi, msg_err_div0
    mov     rdx, msg_err_div0_len
    syscall
    ret
.paren:
    mov     rax, 1
    mov     rdi, 1
    mov     rsi, msg_err_paren
    mov     rdx, msg_err_paren_len
    syscall
    ret

section .data
    newline_byte db 10
