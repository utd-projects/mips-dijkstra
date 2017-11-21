#################################################################################################
##                  MIP implementation of Dijkstra's shortest path algorithm                   ##
##                                                                                             ##
##    A straight-forward implementation of Dijkstra's shortest path algorithm using an         ##
##    adjacency matrix for 6 vertices in a graph.                                              ##
##    Resources and source code can be found at https://github.com/PratikBhusal/mips-dijkstra. ##
##                                                                                             ##
##    Authors:   Pratik Bhusal, Caleb Fung                                                     ##
##    Date:      November 20, 2017                                                             ##
##    Course:    CS 3340.003                                                                   ##
##    Professor: Dr. Karen Mazidi                                                              ##
##                                                                                             ##
#################################################################################################

	.data # {{{
adj_matrix:	.word	0,3,5,9,0,0,
			3,0,3,4,7,0,
			5,3,0,2,6,0,
			9,4,2,0,2,2,
			0,7,6,2,0,5,
			0,0,0,2,5,0

distance:		.word	2147483647:6 # Initilize size 6 array where every element equals INT_MAX
is_shortest:	.word	0:6 # Initilze size 6 array where every element is false

vertices:		.word	6
vertices_msg:	.asciiz	"vertices:\nA B C D E F"

path:		.word	-1:6 # Initilize size 6 array where every element equals -1
path_msg:		.asciiz	"\nPath:\n"
next_vertex_msg:	.asciiz 	" > "

print_vertices_options:	.asciiz "A=0 B=1 C=2 D=3 E=4 F=5\n"
in_starting_vertex:	.asciiz "What is the starting vertex (0-5)? "
starting_vertex:	.word	0 # A=0, B=1, C=2, D=3, E=4, F=5

error_msg:	.asciiz	"Sorry, you did not enter a valid input."

# }}}

	.text # {{{
main: # {{{
	# Ask user for starting vertex {{{
		# Print Vertex Options {{{
			la	$a0,	print_vertices_options
			jal	print_string
		# Print Vertex Options }}}

		# Print Message asking for starting vertex {{{
			la	$a0,	in_starting_vertex
			jal	print_string
		# Print Message asking for starting vertex }}}

		# Get Starting Vertex {{{
			lw	$a0,	starting_vertex
			jal	get_int
			sw	$v0,	starting_vertex
		# Get Starting Vertex }}}
	# Ask user for starting vertex }}}

	# Force Quit if invalid input {{{
		bgt     $v0, 5, error       # Display an error message if starting_vertex > 5
		blt     $v0, 0, error       # Display an error message if starting_vertex < 0
	# Force Quit if invalid input }}}

	# Find Shortest Path from starting vertex to every other vertex {{{
		la	$a0,	adj_matrix
		lw	$a1,	vertices
		lw	$a2,	starting_vertex
		jal	dijkstra
	# Find Shortest Path from starting vertex to every other vertex }}}

	# End Program {{{
		j exit
	# End Program }}}

	# Error Exit {{{
	error:
		la	$a0,	error_msg
		jal	print_string

		j	exit
	# Error Exit }}}
# }}}

dijkstra: #  {{{
	la	$s0,	distance
	la	$s1,	is_shortest
	la	$s5,	path

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
	move	$s4,	$a1	# $s4 = $a1 = vertices
	dijkstra_main_loop: #  {{{
		bge	$s3,	$s4,	end_dijkstra_main_loop # if $s3 < $s4, loop

		# Return current minimum distance vertex {{{
			addi	$sp,	$sp,	-4	# Push $ra into stack
			sw	$ra,	($sp)
			addi	$sp,	$sp,	-4	# Push matrix into stack
			sw	$a0,	($sp)

			move	$a0,	$s0	# $a0 = distance array
			move	$a1,	$s1	# $a1 = is_shortest array
			move	$a2,	$s4	# $a2 = $s4 = vertices
			jal	set_minimum_distance
			move	$s2,	$v0 # $s2 = current shortest vertex = $v0

			lw	$a0,	($sp)
			addi	$sp,	$sp,	4
			lw	$ra,	($sp)
			addi	$sp,	$sp,	4
		# }}}

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
		# }}}

		# Optimize Shortest Path {{{
			addi	$sp,	$sp,	-4	# Put $ra into stack
			sw	$ra,	($sp)

			# $a0 = adj_matrix
			move	$a1,	$s0	# $a1 = distance array
			move	$a2,	$s1	# $a2 = is_shortest array
			# move	$a3,	$s2	# $a3 = current shortest vertex
			move	$a3,	$s5	# $a3 = path array
			jal	optimize_distance

			lw	$ra,	($sp)
			addi	$sp,	$sp,	4
		# }}}

		addi	$s3,	$s3,	1
		j	dijkstra_main_loop

	end_dijkstra_main_loop:
	#  }}}

	# Print Shortest Distance Length {{{
	addi	$sp,	$sp,	-4	# Put $ra into stack
	sw	$ra,	($sp)

	la	$a0,	vertices_msg
	li	$v0,	4
	syscall

	li	$a0,	'\n'
	li	$v0,	11
	syscall

	move	$a0,	$s0	# $a0 = distance array
	jal	print_array

	lw	$ra,	($sp)
	addi	$sp,	$sp,	4
	# }}}

	li	$s3,	0	# int i = $s3 = 0
	# $s4 = vertices

	la	$a0,	path_msg # Print Path Message
	li	$v0	4
	syscall
	path_print_loop: # {{{
		bge	$s3,	$s4	end_path_print_loop

		# Print Path {{{
		addi	$sp,	$sp,	-4	# Put $ra into stack
		sw	$ra,	($sp)

		move	$a1,	$s5	# $a0 = path array
		move	$a2,	$s3	# $a1 = $s3 = End vertex
		jal	print_path

		lw	$ra,	($sp)
		addi	$sp,	$sp,	4
		# }}}

		addi	$s3,	$s3,	1
		j	path_print_loop

	end_path_print_loop:
	# }}}
	jr	$ra
#  }}}

init_starting_vertex:	# Sets the starting vertex to have a distance 0 #  {{{
	sll	$t0,	$a2,	2	# $t0 is pointer to element we want
	add	$t0,	$a0,	$t0	# Get pointer to element we want
	lw	$t1,	0($t0)	# $t1 = distance[starting vertex]
	move	$t1,	$zero	# distance[starting vertex] = 0
	sw	$t1,	($t0)	# Store the value back into the distance array

	jr	$ra
#  }}}

set_minimum_distance:	# Find next shortest vertex #  {{{
	li	$t0,	2147483647 # $t0 = min_value (initilized to INT_MAX)
	li	$v0,	0	# $v0 = min_index

	li	$t1,	0	#int i = $t1 = 0
set_minimum_distance_loop:
	bge	$t1,	$a2,	end_set_minimum_distance

	# if (*(found_path+i) == false && *(distance+i) <= min_value) {{{
		sll	$t2,	$t1,	2	# Anchor pointer to element we want
		add	$t2,	$a1,	$t2	# Set $t2 to address of is_shortest[i]
		lw	$t3,	0($t2)	# $t3 = is_shortest[i]
		bnez	$t3,	increment_set_minimum_distance_loop # Skip if is_shortest[i] = true

		sll	$t2,	$t1,	2	# Anchor pointer to element we want
		add	$t2,	$a0,	$t2	# Set $t2 to address of distance[i]
		lw	$t3,	0($t2)		# $t3 = distance[i]
		sle	$t4,	$t3,	$t0	# Set $t4 to 1 if distance[i] <= $t0(min_value)
		bgt	$t3,	$t0,	increment_set_minimum_distance_loop # Skip if distance[i] > $t0(min_value)
	#  }}}
	move	$t0,	$t3 # min_value = *(distance + i);
	move	$v0,	$t1 # min_index = i;

increment_set_minimum_distance_loop:

	addi	$t1,	$t1,	1
	j	set_minimum_distance_loop

end_set_minimum_distance:
	jr	$ra
#  }}}

update_is_shortest: # Update is_shortest array for new shortest vertex #  {{{
	sll	$t0,	$a1,	2	# Get the correct value
	add	$t0,	$a0,	$t0
	lw	$t1,	0($t0)

	addi	$t1,	$zero,	1	# Set is_found for the vertex to true
	sw	$t1,	($t0)

	jr	$ra
#  }}}

optimize_distance:	# Update distance array values #  {{{
	li	$t0,	0	# int j = $t0 = 0
	move	$t1,	$s4	# $s1 = $s4 = vertices

optimize_distance_loop:
	bge	$t0,	$t1,	end_optimize_distance

	# Find Shorter Distance {{{
		sll	$t2,	$t0,	2	# Anchor pointer to element we want
		add	$t2,	$a2,	$t2	# Set $t2 to address of is_shortest[j]
		lw	$t3,	0($t2)	# $t3 = is_shortest[j]
		bnez	$t3	increment_optimize_distance # Skip if $t3 is true

		sll	$t2,	$s2,	2	# Anchor pointer to element we want
		add	$t2,	$a1,	$t2	# Set $t2 to address of distance[checker]
		lw	$t3,	0($t2)		# $t3 = distance[checker]
		li	$t4,	2147483647
		beq	$t3,	$t4,	increment_optimize_distance # Skip if $t3 = INT_MAX

		mul	$t4,	$t1,	$s2 # Anchor $t2 = vertices*checker + j
		add	$t4,	$t4,	$t0
		sll	$t2,	$t4,	2
		add	$t2,	$a0,	$t2
		lw	$t4,	0($t2)		# $t4 = *(graph + (vertices*checker + j))
		beqz	$t4,	increment_optimize_distance # Skip if $t4 == 0

		add	$t5,	$t4,	$t3 # $t6 = distance[checker] + graph[vertices*checker +j]

		sll	$t2,	$t0,	2	# Anchor pointer to distance[j]
		add	$t2,	$a1,	$t2
		lw	$t6,	0($t2)		# $t7 = distance[j]

		# Branch if distance[j] < distance[checker] + graph[vertices*checker +j]
		ble	$t6,	$t5,	increment_optimize_distance

		# distance[j] = distance[checker] + graph[vertices*checker +j]
		sw	$t5,	($t2)

		sll	$t2,	$t0,	2	# Anchor pointer to path[j]
		add	$t2,	$a3,	$t2
		sw	$s2,	($t2)	# path[j] = checker
	# }}}

increment_optimize_distance:
	addi	$t0,	$t0, 1
	j	optimize_distance_loop

end_optimize_distance:
	jr	$ra
#  }}}

# Print Functions {{{
	print_string: #  {{{
		li	$v0,	4	# Load Immediate for reading strings
		syscall
		jr	$ra	# Return back to where it was called
	#  }}}

	print_int: #  {{{
		li	$v0,	1
		syscall
		jr	$ra	# Return back to where it was called
	#  }}}

	print_array: #  {{{
		li	$t0,	0	# i = $t0 = 0
		move	$t1,	$s4	# $t1 = vertices

		loop_print_array: #  {{{

		bge	$t0,	$t1,	end_print_array # Check if we are are done with looping
		sll	$t2,	$t0,	2	# $t0 is pointer to element we want
		add	$t2,	$a0,	$t2	# Get pointer to element we want

		addi	$sp,	$sp,	-4
		sw	$a0,	($sp)

		lw	$a0,	0($t2)	# $t1 = distance[starting vertex]
		li	$v0,	1
		syscall

		li	$a0,	' '	# Store a new line character into $a0
		li	$v0,	11	# List immediate to print a character
		syscall

		lw	$a0,	($sp)
		addi	$sp,	$sp,	4

		addi	$t0,	$t0,	1
		j	loop_print_array

		end_print_array:

		addi	$sp,	$sp,	-4
		sw	$a0,	($sp)

		li	$a0,	'\n'
		li	$v0,	11
		syscall

		lw	$a0,	($sp)
		addi	$sp,	$sp,	4
		#  }}}

		jr	$ra
	#  }}}

	print_path: # {{{

		move	$t0,	$a2	# $t0 =  i = $a2 = End Vertex
		li	$t1,	0	# Stack pushing counter
		store_path_loop: #  {{{
			beq	$t0,	-1, end_store_path_loop # Loop until we add starting vertex to stack

			addi	$sp,	$sp,	-4
			sw	$t0,	($sp) # Put the current vertex
			addi	$t1,	$t1,	1	# Add 1 to stack pushing counter

			sll	$t2,	$t0,	2	# Anchor pointer to path[i]
			add	$t2,	$a1,	$t2
			lw	$t3,	($t2)
			move	$t0,	$t3	# $t0 = path[i]

			j	store_path_loop
		end_store_path_loop:
		#  }}}

		print_vertices_loop: # {{{
			ble	$t1,	1,	print_end_vertex

			lw	$a0,	($sp)	# $a0 = stack.top()
			addi	$a0,	$a0,	'A'	# Set $a0 to proper vertex char
			li	$v0,	11	# Print vertex
			syscall

			la	$a0,	next_vertex_msg # $a0 = " > "
			li	$v0,	4	# Load Immediate to print string
			syscall # Print next vertex string indicator

			addi	$sp,	$sp,	4	# Pop stack to next vertex
			addi	$t1,	$t1,	-1	# Decrement counter

			j	print_vertices_loop

		print_end_vertex:
			lw	$a0,	($sp)
			addi	$a0,	$a0,	'A'
			li	$v0,	11
			syscall
		# }}}

		li	$a0,	'\n'	# Store a new line character into $a0
		li	$v0,	11	# Load immediate to print character
		syscall

		addi	$sp,	$sp,	4
		jr	$ra
	# }}}
# }}}

get_int: #  {{{
	li	$v0,	5	# Load Immediate for accepting integers
	syscall
	jr	$ra	# Return back to where it was called
#  }}}

exit: # {{{
	li	$v0,	10
	syscall
# }}}
