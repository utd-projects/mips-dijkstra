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

	       .data
adj_matrix:    .word   0,3,5,9,0,0, # The adjacency matrix 
		       3,0,3,4,7,0, # based on https://github.com/PratikBhusal/mips-dijkstra/blob/master/Graph.PNG
		       5,3,0,2,6,0,
		       9,4,2,0,2,2,
		       0,7,6,2,0,5,
		       0,0,0,2,5,0
distances:     .word   2147483647:6
found_paths:   .word   0:6
vertices:      .word   6
paths:	       .word   -1:6         # Array to store the paths from the starting vertex to all other vertices
distance_msg:  .asciiz "\nShortest distance from vertex "
               .align   2
nodes_msg:     .asciiz ":\nA B C D E F\n"
               .align  2
paths_msg:     .asciiz "\nPath:\n"
               .align  2
A:             .word   0            # Values for A to F (add 65 to obtain the ASCII value)
B:             .word   1
C:             .word   2
D:             .word   3
E:             .word   4
F:             .word   5
path_stack:    .word   0:5          # Stack for print the traversed path
end_node_pmpt: .asciiz "A=0, B=1, C=2, D=3, E=4, F=5 \nWhat is the starting vertex (0-5)? "
               .align 2
error_msg:     .asciiz "Sorry, you did not enter a valid input."


               .text
main:
	la      $a0, end_node_pmpt  # Prompt the use for the starting vertex
	li      $v0, 4
	syscall
	li      $v0, 5              # Obtain user input
	syscall

	move    $s2, $v0            # Starting node
	lw      $s0, vertices       # Total vertices in the graph

	bgt     $s2, 5, error       # Display an error message if the input exceed number of vertices
	move    $a0, $s0            # Define the parameters for the dijkstra subprocedure
	move    $a1, $s2
	jal dijkstra                # Implement the main logic for Dijkstra's shortest path algorithm

	end_main:                   # Terminate the program
		li      $v0, 10
		syscall
	error:
		la      $a0, error_msg    # Display the error message and terminate the program
		li      $v0, 4
		syscall
		j       end_main


# Implements the main logic for Dijkstra's shortest path algorithm
# Inputs: $a0 - the number of vertices
#         $a1 - the starting vertex
dijkstra:
	move    $s3, $a0        # Store input parameters in S-registers for further use
	move    $s5, $a1
	li      $t0, 0          # Counter for initialize loop
	li      $t4, 2147483647 # $t4, $t1 are values use to initialize the distances, 
	li      $t1, -1         # found_paths, and paths arrays 
	
	initialize:             # Initialize the element for 
		beq     $s3, $t0, end_initialize
		sll     $t3, $t0, 2        # Obtain the index pointer for arrays
		sw      $t4, distances($t3)
		sw      $0,  found_paths($t3)
		sw      $t1, paths($t3)
		addi    $t0, $t0, 1
		j       initialize
		end_initialize:
			li      $t0, 0              # Counter for dijkstra_loop
			sll     $t3, $s5, 2
			sw      $0, distances($t3)  # Store 0 as the starting vertex value of the path
	
	dijkstra_loop:
		beq     $s3, $t0, end_dijkstra_loop
		addi    $sp, $sp, -8       # Prepare the stack for the set_min_distance subprocedure
		sw      $ra, 4($sp)
		sw      $t0, 0($sp)
		move    $a0, $s3
		move    $a1, $t1
		move    $a2, $t2
		jal     set_min_distance
		move    $t3, $v0           # $t3/"checker" - For finding the correct column in the adjacency matrix
		lw      $t0, 0($sp)
		lw      $ra, 4($sp)
		addi    $sp, $sp, 8
		sll     $t8, $t3, 2        # Obtain the array index based on $t3
		li      $t5, 1                  
		sw      $t5, found_paths($t8)       # found_paths[checker] = true
		li      $t4, 0                      # "j" - Counter for the inner_loop
		inner_loop:
			beq     $s3, $t4, end_inner_loop
			sll     $t5, $t4, 2              # Obtain the array index based on the counter
			lw      $t6, found_paths($t5)    # found_paths[j]
			bnez    $t6, bottom_inner_loop
			mul     $t6, $s3, $t3
			add     $t6, $t6, $t4
			sll     $t6, $t6, 2              # vertices*checker + j array index
			lw      $t6, adj_matrix($t6)     # adj_matrix(vertices*checker + j)
			beqz    $t6, bottom_inner_loop
			lw      $t7, distances($t8)      # distances[checker]
			beq     $t7, 2147483647, bottom_inner_loop
			add     $t7, $t7, $t6            # distances[checker] + adj_matrix(vertices*checker + j)
			lw      $t6, distances($t5)      # distances[j]
			bge     $t7, $t6, bottom_inner_loop
			        # !found_paths[j] &&
                                # graph[(vertices*checker + j)] != 0 &&
                                # distances[checker] != INT_MAX &&
                                # distances[checker] + graph[vertices*checker + j] < distances[j]
			sw      $t7, distances($t5)           # distances[j] = distances[checker] + adj_matrix(vertices*checker + j)
			sw $t3 paths($t5) #paths[j] = checker
			bottom_inner_loop:
				addi $t4, $t4, 1
				j inner_loop
			end_inner_loop:
				addi $t0, $t0, 1
				j dijkstra_loop

		end_dijkstra_loop:
			la      $a0, distance_msg             # Output message for distance from starting vertex
			li      $v0, 4
			syscall
			addi    $a0, $s5, 65                  # Obtain ASCII equivalent of the starting vertex
			li      $v0, 11                       # Output starting vertex
			syscall
			la      $a0, nodes_msg                # Output message for nodes' distance values
			li      $v0, 4
			syscall
			
			li      $t4, 0                        # "j" - Counter for distance_loop
			distance_loop:                        # Print distance values from starting vertex to other vertices
				beq     $s3, $t4, end_distance_loop
				sll     $t5, $t4, 2           # Array index based on the counter
				lw      $a0, distances($t5)   # distances[j]
				li      $v0, 1
				syscall
				li      $a0, ' '              # Output space for formatting
				li      $v0, 11
				syscall
				addi    $t4, $t4, 1
				j       distance_loop
				end_distance_loop:
					la $a0, paths_msg
					li $v0, 4
					syscall
			
			li      $t4, 0                        # "i" - Counter for path_loop
			path_loop:                            # Calls print_path subprocedure to print travsed paths to other vertices
				beq     $s3, $t4, end_path_loop
				addi    $sp, $sp, -8          # Prepare stack for calling subprocedure
				sw      $ra 4($sp)
				sw      $t4 0($sp)
				move    $a0, $t4
				jal     print_path            # Call helper subprocedure to print traversed paths
				lw      $t4 0($sp)
				lw      $ra 4($sp)
				addi    $sp, $sp, 8
				addi    $t4, $t4, 1
				j       path_loop
	end_path_loop:
		jr      $ra


# Determine from the remaining vertices that have the smallest weight
# Input:  $a0 - vertices
# Output: $v0 - the "checker", or pointer for the column of the adjacency matrix
set_min_distance:
	move      $t0, $a0
	li        $t3, 0                         # "i" - The counter for loop_min_distance
	li        $t4, 2147483647                # "min_value" - Minimum weight value, initialized to INT_MAX
	li $t5, 0                                # "min_index" - Index of vertex with minimum weight
	loop_min_distance:
		beq     $t0, $t3, end_set_min_distance
		sll     $t6, $t3, 2              # Array index equivalent of the counter
		lw      $t7 found_paths($t6)     # found_paths[i]
		lw      $t8 distances($t6)       # distances[i]
		bnez    $t7, bottom_set_min_distance
		bgt     $t8, $t4, bottom_set_min_distance
		        # found_paths[i] && distances[i] <= min_value
		move    $t4, $t8
		move    $t5, $t3
	bottom_set_min_distance:                 # If the previous conditions failed
		addi    $t3, $t3, 1
		j       loop_min_distance
	end_set_min_distance:
		move    $v0, $t5
		jr      $ra


# Helper subprocedure to print the traversed path from a start vertex to all other vertices
# Input: $a0 - The end vertex of the path
print_path:
	move    $t0, $a0                         # "i" - Counter for path_stack_loop
	li      $t1, -1                          # path_stack_loop exit condition
	li      $t3, 0                           # "p" - Index for path_stack
	path_stack_loop:                         # Reverses the path node entries using a stack
		sll     $t2, $t0, 2              # Array index based on the counter
		lw      $t2, paths($t2)          # paths[i]
		sll     $t4, $t3, 2              # Pointer for the path_stack
		sw      $t0, path_stack($t4)     # Push i into path_stack[p]
		addi    $t3, $t3, 1              # Increment path_stack index
		beq     $t1, $t2, print_path_loop
		move    $t0, $t2                 # i = paths[i]
		j       path_stack_loop
	print_path_loop:
		addi    $t3, $t3, -1             # Decrement path_stack index
		sll     $t4, $t3, 2              # Array index based on p
		beqz    $t3, end_print_path
		lw      $t5, path_stack($t4)     # Pop i from path_stack[p]
		addi    $a0, $t5, 65             # Obtain and print ASCII equivalent of the vertex traversed to
		li      $v0, 11
		syscall
		li      $a0, '>'                 # Format output
		li      $v0, 11
		syscall
		j       print_path_loop
	end_print_path:                          # Pop the last traversed vertex in the path and output its ASCII value
		lw      $t5, path_stack($t4)     
		addi    $a0, $t5, 65
		li      $v0, 11
		syscall
		li      $a0, '\n'                # Format output
		li      $v0, 11
		syscall
		jr      $ra
