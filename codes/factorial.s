.data
    # Declaring the variables needed for the subroutine
    var: .quad 0


.text
.global main

# Defining the strings used for I/O
test_print: .asciz "Please write a non-negative integer:\n"
input: .asciz "%ld"
output: .asciz "Result: %ld\n"


main:
    #prologue
    push %rbp         # push the base pointer
    mov %rsp, %rbp    # copy stack pointer value to base pointer

    mov $test_print, %rdi #asking for 2 non-negative
    mov $0, %rax      # use normal calling convention
    call printf

    mov $input, %rdi
    mov $var, %rsi
    mov $0, %rax # C calling convention
    call scanf

    movq var, %rdi  # Calculate var!
	movq $1, %rax # we will multiply over it, so
				  # the initial value will be 1
	call factorial # calling the function
	# result is stored in %rax

	# Printing the result
	//movq %rdi, %rsi # The result is in RDI
	movq %rax, %rsi # The result is in RAX
	movq $output, %rdi # the output string
	movq $0, %rax
	call printf

	#epilogue
	movq %rbp, %rsp
	pop %rbp

	call exit

factorial:

	#prologue
	push %rbp
	movq %rsp, %rbp

	cmpq $1, %rdi
	jle end #if rdi<=1, jumps to the end label

	//movq $1, %rax
	mulq %rdi
	dec %rdi

	call factorial

end:
	#epilogue
	movq %rbp, %rsp
	popq %rbp

	//movq %rax, %rdi

	ret #returns to main
