.bss
    # Declaring the variables needed for the subroutine
    exp: .quad
    base: .quad


.text
.global main

# Defining the strings used for I/O
test_print: .asciz "Please write two non-negative numbers:\n"
input: .asciz "%ld"
output: .asciz "Result: %ld\n"


main:
    #prologue
    push %rbp         # push the base pointer
    mov %rsp, %rbp    # copy stack pointer value to base pointer

    mov $test_print, %rdi #asking for 2 non-negative
    mov $0, %rax      # use normal calling convention
    call printf

    # Reading the variables
    #######################

    # Reading base
    mov $input, %rdi
    mov $base, %rsi
    mov $0, %rax # C calling convention
    call scanf

    # Reading exp
    mov $input, %rdi
    mov $exp, %rsi
    mov $0, %rax
    call scanf

    #######################

    mov base, %rdi
    mov exp, %rsi
    mov $0, %rax
    call pow

    # Printing the result
    mov $output, %rdi 
    mov %rax, %rsi
    mov $0, %rax
    call printf


    #epilogue
    mov %rbp, %rsp
    pop %rbp

    mov $0, %rdi
    call exit

pow:
    #prologue
    push %rbp
    mov %rsp, %rbp

    push %rdi

    mov %rsi, %rcx
    mov $1, %rax #initialising RAX with 1

while:
    cmp $0, %rcx # if RCX <=0
                 # ends the loop 
    jle end # jump if lower/equal than    
    
    mulq %rdi
    # In %RAX we have the value 1, and by repetitively multiplying it
    # by base, we get base^exp
    dec %rcx
    jmp while

end:
    #epilogue
    mov %rbp, %rsp
    pop %rbp

    ret
