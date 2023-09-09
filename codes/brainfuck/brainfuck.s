.global brainfuck

.bss
array: .skip 30000, 0 # make room for arr[30000]

.text
format_str: .asciz "We should be executing the following code:\n%s\n"
char_format: .asciz "%c" # only one character
debug: .asciz "%c" # was used for debugging

# Your brainfuck subroutine will receive one argument:
# a zero termianted string containing the code to execute.
brainfuck:
	pushq %rbp
	movq %rsp, %rbp

	pushq %rbx # push callee-saved registers
	pushq %r12
	pushq %r13
	pushq %r14
	pushq %r15
	pushq %r15 # observation : pushing only 5 registers makes the code segfault
			   # (misaligned stack) 

	movq %rdi, %rbx # the address of the brainfuck code

	movq %rdi, %rsi
	movq $format_str, %rdi
	call printf
	movq $0, %rax

	# RBX : the code
	# R12 : code pointer 
	# R13 : the current command
	# R14 : my array ( arr[0] )
	# R15 : array pointer

	movq $0, %r12
	movq $array, %r14
	movq $0, %r15
	

	main_loop:
		movq $0, %r13
		movb (%rbx, %r12), %r13b
		
		cmpq $62, %r13 # >
		je larger_than

		cmpq $60, %r13 # <
		je less_than

		cmpq $43, %r13 # +
		je plus

		cmpq $45, %r13 # -
		je minus

		cmpq $46, %r13 # . 
		je fullstop

		cmpq $44, %r13 # ,
		je comma

		cmpq $91, %r13 # [
		je open_sq_br

		cmpq $93, %r13 # ]
		je closed_sq_br

		cmpq $0, %r13 # we have reached the end of the code
		je skip_loop

		# skip over comments or non-code characters
		incq %r12
		jmp main_loop

skip_loop:

	popq %r15
	popq %r15 # pop callee-saved registers
	popq %r14
	popq %r13
	popq %r12
	popq %rbx

	movq %rbp, %rsp
	popq %rbp
	ret

larger_than:
	incq %r15
	incq %r12
	jmp main_loop

less_than:
	decq %r15
	incq %r12
	jmp main_loop

plus:
	incb (%r14, %r15)
	incq %r12
	jmp main_loop

minus:
	decb (%r14, %r15)
	incq %r12
	jmp main_loop

fullstop: # print one char
	movq $0, %r8
	movb (%r14, %r15), %r8b
	movq %r8, %rsi
	movq $char_format, %rdi
	movq $0, %rax
	call printf

	incq %r12
	jmp main_loop

comma: # read one char
	movq $char_format, %rdi
	leaq (%r14, %r15), %rsi
	movq $0, %rax
	call scanf

	incq %r12
	jmp main_loop


######## OPEN SQUARE BRACKET ########
open_sq_br:
	incq %r12
	cmpb $0, (%r14, %r15)
	jne main_loop
	
	decq %r12 # undo the incq

	movq $0, %r8 # count how many brackets we have

	open_sq_br_loop:
		# jump to matching " ] "
		
		incq %r12 

		cmpb $91, (%rbx, %r12) # [
		je inc_cnt1
		cmpb $93, (%rbx, %r12) # ]
		je dec_cnt1

		jmp open_sq_br_loop

	inc_cnt1:
		incq %r8
		jmp open_sq_br_loop

	dec_cnt1:
		incq %r12
		cmpq $0, %r8
		je main_loop
		decq %r12 # undo the incq

		decq %r8
		jmp open_sq_br_loop

######## CLOSED SQUARE BRACKET ########
closed_sq_br:
	incq %r12
	cmpb $0, (%r14, %r15)
	je main_loop
	
	decq %r12 # undo the incq
	movq $0, %r8 # count how many brackets we have

	closed_sq_br_loop:
		# jump to matching " [ "
		
		decq %r12
		
		cmpb $91, (%rbx, %r12) # [
		je dec_cnt2
		cmpb $93, (%rbx, %r12) # ]
		je inc_cnt2

		jmp closed_sq_br_loop

	inc_cnt2:
		incq %r8
		jmp closed_sq_br_loop

	dec_cnt2:
		incq %r12
		cmpq $0, %r8
		je main_loop
		decq %r12 # undo the incq

		decq %r8
		jmp closed_sq_br_loop
