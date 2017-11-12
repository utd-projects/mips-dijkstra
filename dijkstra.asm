# Pratik Bhusal, Caleb Fung
# November 11, 2017
# CS 3340.003
# Dr. Mazidi

	.data
# {{{
adj_matrix:	.word	0,3,5,9,0,0,
			3,0,3,4,7,0,
			5,3,0,2,6,0,
			9,4,2,0,2,2,
			0,7,6,2,0,5,
			0,0,0,2,5,0

distance:	.word	2147483647:7
# distance:	.word	1,2,3,4,5,6,7
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
		la	$a0,	adj_matrix
		la	$a1,	verticies
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
	addi	$sp,	$sp,	-4
	sw	$ra,	($sp)
	addi	$sp,	$sp,	-4
	sw	$a0,	($sp)

	la	$a0,	distance
	jal	init_starting_vertex

	lw	$a0,	($sp)
	addi	$sp,	$sp,	4
	lw	$ra,	($sp)
	addi	$sp,	$sp,	4
	# Set starting vertex to have a distance 0 }}}

	li	$s6,	0	# int i = $s6 = 0
	li	$s7,	0	# int j = $s7 = 0
	dijkstra_main_loop:
	#  {{{
		# bge	$s6,	$s2,	dijkstra_main_loop # Check if we are are done with looping

		# Set the current minimum distance {{{
		addi	$sp,	$sp,	-4	# Put $ra into stack
		sw	$ra,	($sp)
		addi	$sp,	$sp,	-4	# Put distance arr into stack
		sw	$s0,	($sp)
		addi	$sp,	$sp,	-4	# Put is_shortest arr into stack
		sw	$s1,	($sp)
		addi	$sp,	$sp,	-4	# Put verticies into stack
		sw	$a2,	($sp)

		move	$a0,	$s0
		move	$a1,	$s1
		lw	$a2,	verticies
		jal	set_minimum_distance

		lw	$a2,	($sp)
		addi	$sp,	$sp,	4
		lw	$s1,	($sp)
		addi	$sp,	$sp,	4
		lw	$s0,	($sp)
		addi	$sp,	$sp,	4
		lw	$ra,	($sp)
		addi	$sp,	$sp,	4
		# Set the current minimum distance }}}
	#  }}}

	jr	$ra
#  }}}

init_starting_vertex: # Sets the starting vertex to have a distance 0
#  {{{
	sll	$t0,	$a2,	2	# $t0 is pointer to element we want
	add	$t0,	$a0,	$t0	# Get pointer to element we want
	lw	$t1,	0($t0)	# $t1 = distance[starting vertex]
	move	$t1,	$zero	# distance[starting vertex] = 0
	sw	$t1,	($t0)	# Store the value back into the distance array

	jr	$ra
#  }}}

set_minimum_distance: # $a0 is distance $a1 is is_shortest $a2 is verticies
#  {{{
	li	$t0,	2147483647 # $t0 = min_value
	li	$v0,	0	# $v0 = min_index

	li	$t1,	0	#int i = $t1 = 0
	set_minimum_distance_loop:
	bge	$t1,	$a2,	end_set_minimum_distance

	# if (*(found_path+i) == false && *(distance+i) <= min_value) {{{
	sll	$t2,	$t1,	2	# Anchor pointer to element we want
	add	$t2,	$a1,	$t2	# Set $t2 to address of is_shortest[i]
	lw	$t3,	0($t2)	# $t3 = is_shortest[i]
	seq	$t4,	$t3,	$zero	# Set $t6 to true if is_shortest[i] = false
	beq	$t4,	$zero,	increment_set_minimum_distance_loop # Skip if $t4 is false

	sll	$t2,	$t1,	2	# Anchor pointer to element we want
	add	$t2,	$a0,	$t2	# Set $t2 to address of distance[i]
	lw	$t3,	0($t2)	# $t3 = distance[i]
	sle	$t4,	$t3,	$t0 # Set $t4 to 1 if distance[i] <= $t0
	beq	$t4,	$zero,	increment_set_minimum_distance_loop # Skip if $t4 is false
	#  }}}
	move	$t0,	$t3 # min_value = *(distance + i);
	move	$v0,	$t1 # min_index = i;

	increment_set_minimum_distance_loop:

	addi	$t1,	$t1,	1
	j	set_minimum_distance_loop

	end_set_minimum_distance:
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
