#Priority queue with array in MIPS v1
#Push - O(1)
#Pop - O(n)

.data
arr:     .space  128
msg:     .asciiz "Popped: "
newline: .asciiz "\n"

.text
main:
li   $t1, 0 #size

li   $a0, 7 #push 7
move $a1, $t1
jal  push
move $t1, $v0

li   $a0, 2 #push 2
move $a1, $t1
jal  push
move $t1, $v0

li   $a0, 3 #push 3
move $a1, $t1
jal  push
move $t1, $v0

li   $a0, 4 #push 4
move $a1, $t1
jal  push
move $t1, $v0

move $a0, $t1
jal print
li   $v0, 4
la   $a0, newline
syscall

move $a0, $t1 #pop least value (highest priority)
jal  pop
move $t1, $v0
move $t3, $v1
li   $v0, 4
la   $a0, msg
syscall
li   $v0, 1
move $a0, $t3
syscall

li   $v0, 4
la   $a0, newline
syscall
move $a0, $t1
jal print

li   $v0, 10 #terminate program
syscall


#a0: item
#a1: size
#v0: size
push:
move $s0, $a1
sll  $a1, $a1, 2
sw   $a0, arr($a1)
addi $v0, $s0, 1
jr   $ra


#a0: size
#v0: size
#v1: item
pop:
move $t2, $a0
sll  $t2, $t2, 2
li   $t0, 0
li   $s0, 0 #bit index of min
lw   $t3, arr($zero)
j    pop_loop
pop_loop:
bge  $t0, $t2, exit_pop_loop
lw   $t1, arr($t0)
addi $t0, $t0, 4
blt  $t1, $t3, update_min
j    pop_loop
update_min:
move $t3, $t1
addi $s0, $t0 -4
j    pop_loop
exit_pop_loop:
addi $s1, $t2, -4
lw   $s2, arr($s1)
sw   $s2, arr($s0)
div  $s3, $t2, 4
addi $v0, $s3, -1
move $v1, $t3
jr   $ra

#a0: size
print:
move $t2, $a0
sll  $t2, $t2, 2
li   $t0, 0
j    print_loop
print_loop:
bge  $t0, $t2, exit_print_loop
lw   $t1, arr($t0)
li   $v0, 1
move $a0, $t1
syscall
addi $t0, $t0, 4
j    print_loop
exit_print_loop:
jr   $ra