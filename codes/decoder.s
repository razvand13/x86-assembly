.text
.global main
format: .asciz "%c"
string_format: .asciz "%s"
foreground: .asciz "\x1B[38;5;%dm"
background: .asciz "\x1B[48;5;%dm"

reset: .asciz "\x1B[0m"
stop_blink: .asciz "\x1B[25m"
bold: .asciz "\x1B[1m"
faint: .asciz "\x1B[2m"
conceal: .asciz "\x1B[8m"
reveal: .asciz "\x1B[28m"
blink: .asciz "\x1B[5m"

.include "final.s"

decode:
	# prologue
	pushq	%rbp 			# push the base pointer (and align the stack)
	movq	%rsp, %rbp		# copy stack pointer value to base pointer

	# your code goes here
	pushq %rbx
	pushq %r12 # char
	pushq %r13 # cnt
	pushq %r14 # $MESSAGE
	pushq %r15 # the next address
	movq %rdi, %r14 # $MESSAGE

	loop:
		#displacement
		movq (%r14, %r15, 8), %rbx
		# RBX holds an address to be decoded
		movb %bl, %r12b # char
		shr $8, %rbx
		movb %bl, %r13b # cnt
		shr $8, %rbx
		movl %ebx, %r15d # the next address is now in r15

		shr $32, %rbx #the first two bytes are now the last two bytes
		movq $0, %r10
		movq $0, %r11
		movb %bl, %r10b # byte 2 (foreground)
		shr $8, %rbx
		

		# Printing char cnt times
		cmpq $0, %r13 # if cnt is 0 to begin with, we skip the print
		je skip

		# coloring the background and foreground:
	
		cmpq %r10, %rbx # if the colors are equal
		je switch


	color:

		movq $foreground, %rdi
		movq %r10, %rsi # foreground color
		movq $0, %rax
		call printf

		movq $0, %r11
		movb %bl, %r11b # byte 1 (background)

		movq $background, %rdi
		movq %r11, %rsi # background color
		movq $0, %rax
		call printf

		printchar:

			movq $format, %rdi
			movq %r12, %rsi
			movq $0, %rax
			call printf

			decq %r13
			cmpq $1, %r13
			jge printchar

		skip:

		cmpq $0, %r15
		jne loop

	popq %r15
	popq %r14
	popq %r13
	popq %r12
	popq %rbx

	# epilogue
	movq	%rbp, %rsp		# clear local variables from stack
	popq	%rbp			# restore base pointer location 
	ret

main:
	pushq %rbp 			# push the base pointer (and align the stack)
	movq %rsp, %rbp		# copy stack pointer value to base pointer

	movq $MESSAGE, %rdi	# first parameter: address of the message
	call decode			# call decode

	movq %rbp, %rsp
	popq %rbp			# restore base pointer location 
	movq $0, %rdi		# load program exit code
	call exit			# exit the program

switch:

	cmpq $0, %rbx
	je case0
	cmpq $37, %rbx
	je case37
	cmpq $42, %rbx
	je case42
	cmpq $66, %rbx
	je case66
	cmpq $105, %rbx
	je case105
	cmpq $153, %rbx
	je case153
	cmpq $182, %rbx
	je case182

	jmp printchar # if none of the cases apply

case0: 
	movq $reset, %rdi
	movq $0, %rax
	call printf
	jmp printchar

case37: 
	movq $stop_blink, %rdi
	movq $0, %rax
	call printf
	jmp printchar

case42: 
	movq $bold, %rdi
	movq $0, %rax
	call printf
	jmp printchar

case66: 
	movq $faint, %rdi
	movq $0, %rax
	call printf
	jmp printchar

case105: 
	movq $conceal, %rdi
	movq $0, %rax
	call printf
	jmp printchar

case153: 
	movq $reveal, %rdi
	movq $0, %rax
	call printf
	jmp printchar

case182: 
	movq $blink, %rdi
	movq $0, %rax
	call printf
	jmp printchar
