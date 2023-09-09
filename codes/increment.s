#gcc -no-pie -o dest src.s

# data readeable and usable, but does not compile
.data
variable: .quad 0

# main
.global main
.text

welcome: .asciz "Welcome to live coding!\n"
input: .asciz "%d"
output: .asciz "Incremented number is: %d!\n"

main:
        push %rbp         # push the base pointer
        mov %rsp, %rbp    # copy stack pointer value to base pointer

        mov $welcome, %rdi
        mov $0, %rax      # use normal calling convention
        call printf

        mov $input, %rdi
        mov $variable, %rsi
        mov $0, %rax
        call scanf

        mov $output, %rdi
        mov variable, %rsi
        inc %rsi #increment value in rsi
        mov $0, %rax
        call printf

        mov $0, %rdi
        call exit

        mov %rbp, %rsp
        pop %rbp
