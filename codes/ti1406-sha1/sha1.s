.global sha1_chunk

sha1_chunk:

    pushq %rbp
    movq %rsp, %rbp

	pushq %r12
	pushq %r13
	pushq %r14
	pushq %r15
    pushq %rbx

    # RDI : address of h0
    # RSI : address of the first 32-bit word (w[0])

    # for(i = 16; i < 80; i++)
    #   w[i] = (w[i-3] xor w[i-8] xor w[i-14] xor w[i-16]) leftrotate 1

    # we use %r8 for i

    movq $16, %r8

    message_schedule:

        pushq %r8 # save initial value of i 
                  # to reset it at the end of the loop
     
        subl $3, %r8d
        movl (%rsi, %r8, 4), %r10d # w[%r8 - 3]

        subl $5, %r8d
        movl (%rsi, %r8, 4), %r11d # w[%r8 - 8]

        xorl %r10d, %r11d
        // movl $0, %r10d

        subl $6, %r8d
        movl (%rsi, %r8, 4), %r10d # w[%r8 - 14]

        xorl %r10d, %r11d
        // movl $0, %r10d

        subl $2, %r8d
        movl (%rsi, %r8, 4), %r10d # w[%r8 - 16]

        xorl %r10d, %r11d
        roll $1, %r11d # rotate left 1 (long)

        popq %r8
        movl %r11d, (%rsi, %r8, 4) # copy the value into w[i]

        incl %r8d
        cmpl $80, %r8d
        jl message_schedule # if (r8 < 80) jump

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

        cmpl $20, %r8d
        jl c0
        cmpl $40, %r8d
        jl c1
        cmpl $60, %r8d
        jl c2
        cmpl $80, %r8d
        jl c3

        jmp end_main_loop

    c0:
        # f = (b and c) or ((not b) and d)
        movl %edx, %r12d
        notl %r12d # !b
        andl %edx, %r9d # c = b and c
        andl %r12d, %r10d # d = !b and d
        orl %r9d, %r10d # d = c or d
        movl %r10d, %r12d
        # so f = d (in R12)
        ####
        movl $0x5A827999, %ebx # k = ...

        jmp c_exit

    c1:
        # f = b xor c xor d
        xorl %edx, %r9d # c = b xor c
        xorl %r9d, %r10d # d = c xor d
        movl %r10d, %r12d # f = d

        movl $0x6ED9EBA1, %ebx # k = ...

        jmp c_exit

    c2:
        # f = (b and c) or (b and d) or (c and d)
        pushq %r10 # d
        pushq %r9 # c
        pushq %rdx # b

        andl %edx, %r9d # c = b and c
        movl %r9d, %r13d # (b and c) is now in r13 and r9 is free
        
        popq %rdx
        andl %edx, %r10d # d = b and d

        popq %r9 # c is now the initial c
        popq %r12 # pop d into r12
        andl %r9d, %r12d
        # NOW:
        # %r13 : (b and c)
        # %r10 : (b and d)
        # %r12 : (c and d)
        orl %r13d, %r10d
        orl %r10d, %r12d
        # result is in r12 = f

        movl $0x8F1BBCDC, %ebx # k = ...

        jmp c_exit

    c3:
        # f = b xor c xor d
        xorl %edx, %r9d # c = b xor c
        xorl %r9d, %r10d # d = c xor d
        movl %r10d, %r12d # f = d

        movl $0xCA62C1D6, %ebx # k = ...

        jmp c_exit


    c_exit:
        popq %r11
        popq %r10 
        popq %r9 
        popq %rdx
        popq %rcx # reset to their initial values

        #######
        # r12 : f = temp
        # r8  : i
        # rbx : k
        # rcx : a = h0
        # rdx : b = h1
        # r9  : c = h2
        # r10 : d = h3
        # r11 : e = h4

        # copy a
        movl %ecx, %r14d

        roll $5, %ecx # a = a leftrotate 5
        addl %ecx, %r12d #      f = f + a
        addl %r11d, %r12d #            + e
        addl %ebx, %r12d #            + k
        addl (%rsi, %r8, 4), %r12d # + w[i]
        # f = temp
        

        movl %r10d, %r11d # e = d
        movl %r9d, %r10d # d = c
        roll $30, %edx # b = b leftrotate 30
        movl %edx, %r9d # c = b
        // rorl $5, %ecx # (hopefully) returns to initial a
        // movl %ecx, %edx
        movl %r14d, %edx # b = a
        movl %r12d, %ecx # a = temp
        
        #######
        incl %r8d
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

    popq %rbx
    popq %r15 # restore callee-saved registers
	popq %r14
	popq %r13
	popq %r12 

    movq %rbp, %rsp
    popq %rbp

	ret
