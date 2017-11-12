# Pratik Bhusal, Caleb Fung
# November 11, 2017
# CS 3340.003
# Dr. Mazidi

	.data
# {{{
adj_matrix:	.word	0,3,5,9,0,0,3,0,3,4,7,0,5,3,0,2,6,0,9,4,2,0,2,2,0,7,6,2,0,5,0,0,0,2,5,0
	# 0 3 5 9 0 0
	# 3 0 3 4 7 0
	# 5 3 0 2 6 0
	# 9 4 2 0 2 2
	# 0 7 6 2 0 5
	# 0 0 0 2 5 0
distance:	.word	2147483647:7
is_shortest:	.word	0:7
verticies:	.word	7

A:	.word	0
B:	.word	1
C:	.word	2
D:	.word	3
E:	.word	4
F:	.word	5

# }}}

	.text
# {{{
main:
# {{{
	# Find Shortest Path from A to every other vertex {{{
		# la	$a0,	adj_matrix
		lw	$a1,	verticies
		lw	$a2,	A
		jal	dijkstra
	# Find Shortest Path from A to every other vertex }}}
	# End Program {{{
		j exit
	# End Program }}}
# }}}

dijkstra:
#  {{{
	la	$s0,	distance
	la	$s1,	is_shortest

	# Set starting vertex to have a distance 0 {{{
	sll	$t0,	$a2,	2	# $t0 is pointer to element we want
	add	$t0,	$s0,	$t1	# Get pointer to element we want
	lw	$t1,	0($t0)	# Load into $t1.
	move	$t1,	$zero	# Modify $t1 to be 0
	sw	$t1,	($s0)	# Store the value back into the distance array
	# Set starting vertex to have a distance 0 }}}

	jr	$ra
#  }}}

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
