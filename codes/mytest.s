#Attempt: print out hello word, ask for a number input, write that same number, exit
.data
var: .quad 0


.text

welcome: .asciz "Hello world!\n"
prompt: .asciz "Please type in a number: "
input: .asciz "%c"
output: .asciz "Your number was: %ld\n"

.global main

main:

    #prologue
    pushq %rbp
    movq %rsp, %rbp

    #hello world
    movq $welcome, %rdi
    movq $0, %rax
    call printf

    #input
    mov $input, %rdi
    mov $var, %rsi
    mov $0, %rax
    call scanf

    cmpq $62, var
    je test_bf

    done:

    movq $0, %rdi
    call exit

    #epilogue
    movq %rbp, %rsp
    popq %rbp


test_bf:
    #outputting the input
    mov $output, %rdi
    mov var, %rsi
    mov $0, %rax
    call printf

    jmp done
