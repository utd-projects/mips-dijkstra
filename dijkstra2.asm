# Pratik Bhusal, Caleb Fung
# November 20, 2017
# CS 3340.003
# Dr. Mazidi


	       .data
adj_matrix:    .word 0,3,5,9,0,0,
		     3,0,3,4,7,0,
		     5,3,0,2,6,0,
		     9,4,2,0,2,2,
		     0,7,6,2,0,5,
		     0,0,0,2,5,0
distances:     .word 2147483647:6
found_paths:   .word 0:6
vertices:      .word 6
paths:	       .word -1:6
distance_msg:  .asciiz "\nShortest distance from vertex "
               .align 2
nodes_msg:     .asciiz ":\nA B C D E F\n"
               .align 2
paths_msg:     .asciiz "\nPath:\n"
               .align 2
A:             .word 0
B:             .word 1
C:             .word 2
D:             .word 3
E:             .word 4
F:             .word 5
path_stack:    .word 0:5
end_node_pmpt: .asciiz "A=0, B=1, C=2, D=3, E=4, F=5 \nWhat is the starting vertex (0-5)? "
               .align 2
error_msg:     .asciiz "Sorry, you did not enter a valid input."


               .text
main:
	la      $a0, end_node_pmpt
	li      $v0, 4
	syscall
	li      $v0, 5
	syscall

	move    $s2, $v0 #end_node
	lw      $s0, vertices
	la      $s1, adj_matrix

	bgt     $s2, 5, error
	move    $a0, $s0
	move    $a1, $s1
	move    $a2, $s2
	jal dijkstra

	end_main:
		li      $v0, 10
		syscall
	error:
		la      $a0, error_msg
		li      $v0, 4
		syscall
		j       end_main


#vertices, adj_main, i (start)
dijkstra:
	move    $s3, $a0
	move    $s4, $a1
	move    $s5, $a2
	li      $t0, 0
	li      $t4, 2147483647
	li      $t1, -1
	
	initialize:
		beq     $s3, $t0, end_initialize
		sll     $t3, $t0, 2
		sw      $t4, distances($t3)
		sw      $0,  found_paths($t3)
		sw      $t1, paths($t3)
		addi    $t0, $t0, 1
		j       initialize
		end_initialize:
		li      $t0, 0
		sll $t3, $s5, 2
		sw $zero, distances($t3)
	
	dijkstra_loop:
		beq $s3, $t0, end_dijkstra_loop
		
		addi $sp, $sp, -8
		sw $ra, 4($sp)
		sw $t0, 0($sp)
		move $a0, $s3
		move $a1, $t1
		move $a2, $t2
		jal set_min_distance
		move $t3, $v0 #checker
		lw $t0, 0($sp)
		lw $ra, 4($sp)
		addi $sp, $sp, 8

		sll $t8, $t3, 2 #checker array index
		li $t5, 1
		sw $t5, found_paths($t8) #found_paths[checker] = true

		li $t4, 0 #j
		
		inner_loop:
			beq $s3, $t4, end_inner_loop

			sll $t5, $t4, 2 #j array index
			lw $t6, found_paths($t5)
			bnez $t6, bottom_inner_loop
			mul $t6, $s3, $t3
			add $t6, $t6, $t4
			sll $t6, $t6, 2 #vertices*checker + j array index
			lw $t6, adj_matrix($t6) #adj_matrix(vertices*checker + j)
			beqz $t6, bottom_inner_loop
			lw $t7, distances($t8) #distances[checker]
			beq $t7, 2147483647, bottom_inner_loop
			add $t7, $t7, $t6 #distances[checker] + adj_matrix(vertices*checker + j)
			lw $t6, distances($t5) #distances[j]
			bge $t7, $t6, bottom_inner_loop

			sw $t7, distances($t5) #distances[j] = distances[checker] + adj_matrix(vertices*checker + j)
			sw $t3 paths($t5) #paths[j] = checker

			bottom_inner_loop:
				addi $t4, $t4, 1
				j inner_loop
			end_inner_loop:
				addi $t0, $t0, 1
				j dijkstra_loop

		end_dijkstra_loop:
			la $a0, distance_msg
			li $v0, 4
			syscall
			addi $a0, $s5, 65
			li $v0, 11
			syscall
			la $a0, nodes_msg
			li $v0, 4
			syscall
			
			li $t4, 0 #j
			distance_loop:
				beq $s3, $t4, end_distance_loop
				sll $t5, $t4, 2
				lw $a0, distances($t5)
				li $v0, 1
				syscall
				li $a0, ' '
				li $v0, 11
				syscall
				addi $t4, $t4, 1
				j distance_loop
				
				end_distance_loop:
					la $a0, paths_msg
					li $v0, 4
					syscall
			
			li $t4, 0 #i
			path_loop:
				beq $s3, $t4, end_path_loop
				addi $sp, $sp, -8
				sw $ra 4($sp)
				sw $t4 0($sp)
				move $a0, $t4
				jal print_path
				lw $t4 0($sp)
				lw $ra 4($sp)
				addi $sp, $sp, 8
				addi $t4, $t4, 1
				j path_loop
				
	end_path_loop:
		jr $ra


#vertices, distances, found_paths
set_min_distance:
	move $t0, $a0
	move $t1, $a1
	move $t2, $a2
	li $t3, 0 #i
	li $t4, 2147483647 #min_value
	li $t5, 0 #min_index
	
	loop_min_distance:
		beq $t0, $t3, end_set_min_distance

		sll $t6, $t3, 2 #array index i
		lw $t7 found_paths($t6) #found_paths[i]
		lw $t8 distances($t6) #distances[i]

		bnez $t7, bottom_set_min_distance
		bgt $t8, $t4, bottom_set_min_distance
		move $t4, $t8
		move $t5, $t3

	bottom_set_min_distance:
		addi $t3, $t3, 1
		j loop_min_distance
	end_set_min_distance:
		move $v0, $t5
		jr $ra


#i (end_vertex)
print_path:
	move $t0, $a0 #i
	li $t1, -1
	li $t3, 0 #path_stack index
	
	path_stack_loop:
		sll $t2, $t0, 2
		lw $t2, paths($t2)

		sll $t4, $t3, 2
		sw $t0, path_stack($t4)
		addi $t3, $t3, 1

		beq $t1, $t2, print_path_loop
		move $t0, $t2
		j path_stack_loop
	print_path_loop:
		addi $t3, $t3, -1
		sll $t4, $t3, 2
		beqz $t3, end_print_path
		lw $t5, path_stack($t4)
		addi $a0, $t5, 65
		li $v0, 11
		syscall
		li $a0, '>'
		li $v0, 11
		syscall
		j print_path_loop
	end_print_path:
		lw $t5, path_stack($t4)
		addi $a0, $t5, 65
		li $v0, 11
		syscall
		li $a0, '\n'
		li $v0, 11
		syscall
		jr $ra