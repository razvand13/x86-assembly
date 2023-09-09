.global sha1_chunk

sha1_chunk:

    pushq %rbp
    movq %rsp, %rbp

	pushq %r12
	pushq %r13
	pushq %r14
	pushq %r15

    # RDI : address of h0
    # RSI : address of the first 32-bit word

    # for(i = 16; i < 80; i++)
    #   w[i] = (w[i-3] xor w[i-8] xor w[i-14] xor w[i-16]) leftrotate 1

    # we use %r8 for i

    movq $16, %r8

    message_schedule:

        pushq %r8
    
        # we calculate the result in %RBX
        movq $0, %rbx
        subq $3, %r8
        movl (%rsi, %r8, 4), %r10d # w[%r9 - 3]

        subq $5, %r8
        movl (%rsi, %r8, 4), %r11d # w[%r9 - 8]

        xorq %r10, %r11
        movq $0, %r10

        subq $6, %r8
        movl (%rsi, %r8, 4), %r10d # w[%r9 - 14]

        xorq %r10, %r11
        movq $0, %r10

        subq $2, %r8
        movl (%rsi, %r8, 4), %r10d # w[%r9 - 16]

        xorq %r10, %r11
        rolq $1, %r11 # rotate left

        popq %r8
        movq %r11, (%rsi, %r8, 4) # copy the value into w[i]

        incq %r8
        cmpq $80, %r8
        jl message_schedule # if (r9 < 80) jump

    # rcx : a = h0
    # rdx : b = h1
    # r9  : c = h2
    # r10 : d = h3
    # r11 : e = h4

    movl (%rdi), %ecx
    movl 4(%rdi), %edx
    movl 8(%rdi), %r9d
    movl 12(%rdi), %r10d
    movl 16(%rdi), %r11d

    # for(i = 0; i < 80; i++)
    # rbx : k
    # r8  : i
    # r12 : f

    movq $0, %r8 # i = 0
    main_loop:

        pushq %rcx
        pushq %rdx
        pushq %r9 
        pushq %r10 
        pushq %r11 # pushing a,b,c,d,e because
                   # we will need the initial values later

        cmpq $20, %r8
        jl c0
        cmpq $40, %r8
        jl c1
        cmpq $60, %r8
        jl c2
        cmpq $80, %r8
        jl c3

        jmp end_main_loop

    c0:
        # f = (b and c) or ((not b) and d)
        movq %rdx, %r12
        not %r12 # !b
        and %rdx, %r9 # c = b and c
        and %r10, %r12 # d = !b and d
        or %r9, %r12 # d = c or d
        # so f = d (in R12)
        ####
        movq $0x5A827999, %rbx # k = ...

        incq %r8
        jmp c_exit

    c1:
        # f = b xor c xor d
        xor %rdx, %r9 # c = b xor c
        xor %r9, %r10 # d = c xor d
        movq %r10, %r12 # f = d

        movq $0x6ED9EBA1, %rbx # k = ...

        incq %r8
        jmp c_exit

    c2:
        # f = (b and c) or (b and d) or (c and d)
        pushq %r10 # d
        pushq %r9 # c
        pushq %rdx # b

        and %rdx, %r9 # c = b and c
        movq %r9, %r13 # (b and c) is now in r13 and r9 is free
        
        popq %rdx
        and %rdx, %r10 # d = b and d

        popq %r9 # c is now the initial c
        popq %r12 # pop d into r12
        and %r9, %r12
        # NOW:
        # %r13 : (b and c)
        # %r10 : (b and d)
        # %r12 : (c and d)
        or %r13, %r10
        or %r10, %r12
        # result is in r12 = f

        movq $0x8F1BBCDC, %rbx # k = ...

        incq %r8
        jmp c_exit

    c3:
        # f = b xor c xor d
        xor %rdx, %r9 # c = b xor c
        xor %r9, %r10 # d = c xor d
        movq %r10, %r12 # f = d

        movq $0xCA62C1D6, %rbx # k = ...

        incq %r8
        jmp c_exit


    c_exit:
        popq %r11
        popq %r10 
        popq %r9 
        popq %rdx
        popq %rcx # reset to their initial values

        #######
        # r12 : f / temp
        # r8  : i
        # rbx : k
        # rcx : a = h0
        # rdx : b = h1
        # r9  : c = h2
        # r10 : d = h3
        # r11 : e = h4

        rolq $5, %rcx # a = a leftrotate 5
        add %rcx, %r12 #      f = f + a
        add %r11, %r12 #            + e
        add %rbx, %r12 #            + k
        add (%rsi, %r8, 4), %r12 # + w[i]
        # f = temp

        movq %r10, %r11 # e = d
        movq %r9, %r10 # d = c
        rolq $30, %rdx # b = b leftrotate 30
        movq %rdx, %r9 # c = b
        rorq $5, %rcx # (hopefully) returns to initial a
        movq %rcx, %rdx # b = a
        movq %r12, %rcx # a = temp
        
        #######

        jmp main_loop

    end_main_loop:
        popq %r11 # e
        popq %r10 # d
        popq %r9  # c
        popq %rdx # b
        popq %rcx # a

        #update h0-h4

        addl %ecx, (%rdi)    # h0 = h0 + a
        addl %edx, 4(%rdi)   # .
        addl %r9d, 8(%rdi)   # . 
        addl %r10d, 12(%rdi) # .
        addl %r11d, 16(%rdi) # h4 = h4 + e

    popq %r15 # restore callee-saved registers
	popq %r14
	popq %r13
	popq %r12 

    movq %rbp, %rsp
    popq %rbp

	ret
