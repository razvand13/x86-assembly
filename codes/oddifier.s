# Return the closest >= odd number to the input

.text

welcome: .asciz "Your program compiles!\n"
prompt: .asciz "Type in a positive number:\n"
input: .asciz "%ld"
output: .asciz "The closest odd number is: %ld \n"

.global main

main:

#prologue

push %rbp
mov %rsp, %rbp

mov $0, %rax #convention before calling functions
mov $welcome, %rdi
call printf #prints welcome
call inout #calls the subroutine inout, not yet defined


#epilogue

mov %rbp, %rsp
pop %rbp

end: #ends the program
mov $0, %rdi #still a convention (from what I understand)
call exit

inout: #the actual process behind the program
#increment if even, don't if odd, then print

#prologue

push %rbp
mov %rsp, %rbp

###############

mov $0, %rax
mov $prompt, %rdi #getting ready to call a function
call printf

sub $16, %rsp
mov $0, %rax
mov $input, %rdi #"getting ready" convention
lea -16(%rbp), %rsi
call scanf #read input

mov -16(%rbp), %rsi

mov %rsi, %rax
mov $2, %rcx
mov $0, %rdx
div %rcx #divides RAX by RCX     (rax/rcx)

cmp $0, %rdx #looks if rdx has 0 left in it
jne odd #if not equal, jumps to odd subroutine

###############

even:
inc %rsi #increments the value stored in RSI

odd:
mov $0, %rax
mov $output, %rdi #output string + number stored in RSI

call printf #prints the output

#epilogue
mov %rbp, %rsp
pop %rbp

ret
