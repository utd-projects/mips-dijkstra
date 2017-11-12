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

distance:	.word	2147483647:6 # Initilize size 6 array where every element equals INT_MAX
is_shortest:	.word	0:6 # Initilze size 6 array where every element is false
verticies:	.word	6

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
		addi	$sp,	$sp,	-4
		sw	$ra,	($sp)
		addi	$sp,	$sp,	-4
		sw	$a0,	($sp)

		move	$a0,	$s0
		# $a2 = Starting Vertex
		jal	init_starting_vertex

		lw	$a0,	($sp)
		addi	$sp,	$sp,	4
		lw	$ra,	($sp)
		addi	$sp,	$sp,	4
	# Set starting vertex to have a distance 0 }}}

	li	$s3,	0	# int i = $s3 = 0
	move	$s4,	$a1	# $s4 = $a1 = verticies
	dijkstra_main_loop:
	#  {{{
		bge	$s3,	$s4,	end_dijkstra_main_loop # if $s3 < $s4, loop

		# Return current minimum distance vertex {{{
			addi	$sp,	$sp,	-4	# Push $ra into stack
			sw	$ra,	($sp)
			addi	$sp,	$sp,	-4	# Push matrix into stack
			sw	$a0,	($sp)

			move	$a0,	$s0	# $a0 = distance array
			move	$a1,	$s1	# $a1 = is_shortest array
			move	$a2,	$s4	# $a2 = $s4 = verticies
			jal	set_minimum_distance
			move	$s2,	$v0 # $s2 = current shortest vertex = $v0

			lw	$a0,	($sp)
			addi	$sp,	$sp,	4
			lw	$ra,	($sp)
			addi	$sp,	$sp,	4
		# Return current minimum distance vertex }}}

		# Update is_shortest for the new shortest vertex {{{
			addi	$sp,	$sp,	-4	# Put $ra into stack
			sw	$ra,	($sp)
			addi	$sp,	$sp,	-4	# Put matrix into stack
			sw	$a0,	($sp)

			move	$a0,	$s1	# $a0 = is_shortest array
			move	$a1,	$s2	# $a1 = current shortest vertex
			jal	update_is_shortest

			lw	$a0,	($sp)
			addi	$sp,	$sp,	4
			lw	$ra,	($sp)
			addi	$sp,	$sp,	4
		# Update is_shortest for the new shortest vertex  }}}

		# Optimize Shortest Path {{{
			addi	$sp,	$sp,	-4	# Put $ra into stack
			sw	$ra,	($sp)

			# $a0 = adj_matrix
			move	$a1,	$s0	# $a1 = distance array
			move	$a2,	$s1	# $a2 = is_shortest array
			move	$a3,	$s2	# $a3 = current shortest vertex
			jal	optimize_distance

			lw	$ra,	($sp)
			addi	$sp,	$sp,	4
		# Optimize Shortest Path }}}

		addi	$s3,	$s3,	1
		j	dijkstra_main_loop
	#  }}}

	end_dijkstra_main_loop:

		# Print Distance Array {{{
		addi	$sp,	$sp,	-4	# Put $ra into stack
		sw	$ra,	($sp)
		addi	$sp,	$sp,	-4	# Put matrix into stack
		sw	$a0,	($sp)

		move	$a0,	$s0
		jal	print_array

		lw	$a0,	($sp)
		addi	$sp,	$sp,	4
		lw	$ra,	($sp)
		addi	$sp,	$sp,	4
		# }}}

	jr	$ra
#  }}}

init_starting_vertex:	# Sets the starting vertex to have a distance 0
#  {{{
	sll	$t0,	$a2,	2	# $t0 is pointer to element we want
	add	$t0,	$a0,	$t0	# Get pointer to element we want
	lw	$t1,	0($t0)	# $t1 = distance[starting vertex]
	move	$t1,	$zero	# distance[starting vertex] = 0
	sw	$t1,	($t0)	# Store the value back into the distance array

	jr	$ra
#  }}}

set_minimum_distance:	# Find next shortest vertex
#  {{{
	li	$t0,	2147483647 # $t0 = min_value (initilized to INT_MAX)
	li	$v0,	0	# $v0 = min_index

	li	$t1,	0	#int i = $t1 = 0
set_minimum_distance_loop:
	bge	$t1,	$a2,	end_set_minimum_distance

	# if (*(found_path+i) == false && *(distance+i) <= min_value) {{{
		sll	$t2,	$t1,	2	# Anchor pointer to element we want
		add	$t2,	$a1,	$t2	# Set $t2 to address of is_shortest[i]
		lw	$t3,	0($t2)	# $t3 = is_shortest[i]
		seq	$t4,	$t3,	$zero	# Set $t4 to true if is_shortest[i] = false
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

update_is_shortest:	# Update is_shortest array for new shortest vertex
#  {{{
	sll	$t0,	$a1,	2	# Get the correct value
	add	$t0,	$a0,	$t0
	lw	$t1,	0($t0)

	addi	$t1,	$zero,	1	# Set is_found for the vertex to true
	sw	$t1,	($t0)

	jr	$ra
#  }}}

optimize_distance:	# Update distance array values
#  {{{
	li	$t0,	0	# int j = $t0 = 0
	move	$t1,	$s4	# $s1 = $s4 = verticies
optimize_distance_loop:
	bge	$t0,	$t1,	end_optimize_distance

	# Find Shorter Distance {{{
		sll	$t2,	$t0,	2	# Anchor pointer to element we want
		add	$t2,	$a2,	$t2	# Set $t2 to address of is_shortest[j]
		lw	$t3,	0($t2)	# $t3 = is_shortest[j]
		bnez	$t3	increment_optimize_distance # Skip if $t3 is true

		sll	$t2,	$a3,	2	# Anchor pointer to element we want
		add	$t2,	$a1,	$t2	# Set $t2 to address of distance[checker]
		lw	$t3,	0($t2)		# $t3 = distance[checker]
		li	$t4,	2147483647
		beq	$t3,	$t4,	increment_optimize_distance # Skip if $t3 = INT_MAX

		mul	$t4,	$t1,	$a3 # Anchor $t2 = verticies*checker + j
		add	$t4,	$t4,	$t0
		sll	$t2,	$t4,	2
		add	$t2,	$a0,	$t2
		lw	$t4,	0($t2)		# $t4 = *(graph + (verticies*checker + j))
		beqz	$t4,	increment_optimize_distance # Skip if $t4 == 0

		add	$t5,	$t4,	$t3 # $t6 = distance[checker] + graph[verticies*checker +j]

		sll	$t2,	$t0,	2	# Anchor pointer to distance[j]
		add	$t2,	$a1,	$t2
		lw	$t6,	0($t2)		# $t7 = distance[j]

		# Branch if distance[j] < distance[checker] + graph[verticies*checker +j]
		blt	$t6,	$t5,	increment_optimize_distance

		# distance[j] = distance[checker] + graph[verticies*checker +j]
		sw	$t5,	($t2)
	# Find Shorter Distance }}}

increment_optimize_distance:
	addi	$t0,	$t0, 1
	j	optimize_distance_loop

end_optimize_distance:
	jr	$ra
#  }}}

print_array:
#  {{{
	li	$t0,	0	# i = $t0 = 0
	lw	$t1,	verticies
loop_print_array:
	bge	$t0,	$t1,	end_print_array # Check if we are are done with looping
	sll	$t2,	$t0,	2	# $t0 is pointer to element we want
	add	$t2,	$a0,	$t2	# Get pointer to element we want

	addi	$sp,	$sp,	-4
	sw	$a0,	($sp)

	lw	$a0,	0($t2)	# $t1 = distance[starting vertex]
	li	$v0,	1
	syscall

	li	$a0,	'\n'	# Store a new line character into $a0
	li	$v0,	11	# List immediate to print a character
	syscall

	lw	$a0,	($sp)
	addi	$sp,	$sp,	4

	addi	$t0,	$t0,	1
	j	loop_print_array

end_print_array:
	jr	$ra
#  }}}

exit:
# {{{
	li	$v0,	10
	syscall
# }}}
