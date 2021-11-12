.data
	primes:		.space 1000 # reserves a block of 1000 bytes in application memory (truth table for prime)
	err_msg:	.asciiz "Invalid input! Expected integer n, where 1 < n <= 1000.\n"
	comma:		.asciiz ", "


.text
main:
	# get input
	li		$v0, 5						# set system call code to "read integer"
	syscall								# read integer from standard input stream to $v0

	# store input as $s0
	move	$s0, $v0

	# validate input
	bgt		$s0, 1000, invalid_input 	# if input is grater than 1000, invalid input
	nop
	blt		$s0, 1, invalid_input		# if input is less than 1, invalid_input
	nop

	### INIT PRIMES ARRAY (truth-table) ###
	li		$t0, 0						# set index counter
	li		$t1, 1						# constant 1 (to initialize primes array)
init_loop:
	sb		$t1, primes($t0)			# primes[i] = 1
	addi	$t0, $t0, 1					# increment pointer
	blt		$t0, $s0, init_loop			# loop if counter is less than target prime ceiling

	### SIEVE OUT NON PRIMES ###
	li		$t0, 1						# init sieve increment/step
sieve_loop:
	addi	$t0, $t0, 1					# increment step
	add		$t1, $zero, $t0				# init nested loop counter/index
nested_loop:
	add		$t1, $t1, $t0				# add step to nested counter
	sb		$zero, primes($t1)			# set primes[i] to 0
	blt 	$t1, $s0, nested_loop		# loop if counter is less than target prime ceiling

	blt		$t0, $s0, sieve_loop		# loop to next prime if sieve step is less than target prime ceiling

	### PRINT PRIMES ###
	li		$t0, 2						# set print index counter (start from first prime, 2 has index 3)
print_primes:
	addi	$t0, $t0, 1					# increment index counter
	lb		$t1, primes($t0)			# $t1 equals 1 or 0 if prime or not
	beqz	$t1, print_primes			# loop if $t1 is not prime, otherwise continue and print

	# print prime number
	li		$v0, 1						# load syscal for print integer
	move	$a0, $t0					# set print argument to counter
	syscall								# execute print

	# print comma
	li		$v0, 4						# syscall code for print string
	la		$a0, comma					# load comma as print argument
	syscall								# execute print

	blt		$t0, $s0, print_primes		# loop if index is less than target prime ceiling

	# exit program
	j		exit_program
	nop

invalid_input:
	# print error message
	li		$v0, 4						# set system call code "print string"
	la		$a0, err_msg				# load address of string err_msg into the system call argument registry
	syscall								# print the message to standard output stream

exit_program:
	# exit program
	li $v0, 10							# set system call code to "terminate program"
	syscall								# exit program
