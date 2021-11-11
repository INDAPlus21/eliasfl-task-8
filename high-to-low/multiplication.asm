##
# Push value to application stack.
# PARAM: Registry with value.
##
.macro	PUSH (%reg)
	addi	$sp,$sp,-4              # decrement stack pointer (stack builds "downwards" in memory)
	sw	    %reg,0($sp)             # save value to stack
.end_macro

##
# Pop value from application stack.
# PARAM: Registry which to save value to.
##
.macro	POP (%reg)
	lw	    %reg,0($sp)             # load value from stack to given registry
	addi	$sp,$sp,4               # increment stack pointer (stack builds "downwards" in memory)
.end_macro

.data

.text
.globl multiply                  # define label multiply as externally accessable 
.globl faculty                   # define label faculty as externally accessable

    main:
        # test multiply coroutine
        li $a0, 2345 # first number to be multiplied
        li $a1, 5432 # second number to be multiplied
        PUSH($ra)                           # save return address
	    jal multiply                        # execute multiply with arguments $a0 and $a1
	    nop
        POP($ra)                            # get prev return address
        # print output
        move $a0, $v0
        li  $v0, 1                          # set system call code to "print integer"
        syscall                             # print square of input integer to output stream

        # print newline
        addi $a0, $0, 0xA #ascii code for LF, if you have any trouble try 0xD for CR.
        addi $v0, $0, 0xB #syscall 11 prints the lower 8 bits of $a0 as an ascii character.
        syscall

        # test faculty coroutine
		li $a0, 12 # number to facultate
		PUSH($ra)                           # save return address
		jal faculty                         # facultate the number in $a0
		nop
		POP($ra)                            # get prev return address
        # print output
        move $a0, $v0
        li  $v0, 1                          # set system call code to "print integer"
        syscall                             # print square of input integer to output stream
        
        # exit program
        li $v0, 10                          # system call code for exit
        syscall
        
    # Multiply given factors using addition.
    # @argumnet $a0 first number
    # @argumnet $a1 second number (index limit)
    # @return The product of the multiplication of the factors a and b.
    multiply:
        li $v0, 0                       # set return value/sum to 0
        li $t0, 0                       # $t0 = 0 (our index counter)
        
        multLoop:
            add $v0, $v0, $a1           # Add second argument to sum
            
            addi $t0, $t0, 1            # increment loop index
            bne $t0, $a0, multLoop          # if $t1 (counter) equals $a0 (index limit), loop

        # return
        jr      $ra                     # return to where main was called from
        nop
    
    # Calculate faculty using addition.
    # @argument $a0 the number to take factorial of
    # @return The facorial of n.
    faculty:
        PUSH($s0) # index counter
        PUSH($s1) # product
        PUSH($s2) # first argument, number to take factorial of (index limit)
        addi $s2, $a0, 1 # $s2 number to take factorial of (needs to add one because loop is exclusive)
        li $s0, 1 # set index counter to 1
    	li $s1, 1 # set product to 1
    	
        facLoop:
            move $a0, $s0 # first number equals index counter
            move $a1, $s1 # second number equals running product
            PUSH($ra)
            jal multiply  # multiply numbers
            nop
            POP($ra)
            move $s1, $v0 # set product to return value
            
            addi $s0, $s0, 1            # increment loop index
            bne $s0, $s2, facLoop      # if $s0 (counter) not equals $s2 (index limit), loop
        
        move $v0, $s1 # set return value to product
		POP($s2)
		POP($s1)
		POP($s0)
        # return
        jr      $ra                     # return to where main was called from
        nop
        
