# Pratik Bhusal, Caleb Fung
# November 11, 2017
# CS 3340.003
# Dr. Mazidi

	.data
# {{{
verticies:	.word	7
adj_matrix:	.word	0,3,5,9,0,0,3,0,3,4,7,0,5,3,0,2,6,0,9,4,2,0,2,2,0,7,6,2,0,5,0,0,0,2,5,0
	# 0 3 5 9 0 0
	# 3 0 3 4 7 0
	# 5 3 0 2 6 0
	# 9 4 2 0 2 2
	# 0 7 6 2 0 5
	# 0 0 0 2 5 0
distance:	.word	0,0,0,0,0,0,0
is_shortest:	.word	0,0,0,0,0,0,0

# }}}

	.text
# {{{
main:
# {{{
	# End Program {{{
		j exit
	# End Program }}}
# }}}

# Print Functions {{{
print_string:
#  {{{
	li	$v0,	4	# Load Immediate for reading strings
	syscall
	jr	$ra	# Return back to where it was called
#  }}}

print_int:
#  {{{
	li	$v0,	1
	syscall
	jr	$ra	# Return back to where it was called
#  }}}
# Print Functions }}}

exit:
# {{{
	li	$v0,	10
	syscall
# }}}
