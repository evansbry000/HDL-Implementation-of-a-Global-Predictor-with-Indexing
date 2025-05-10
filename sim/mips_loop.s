# mips_loop.s
# Simulates:
# for (i = 0; i < 1000; i++) {
#     for (j = 0; j < 5; j++) {
#         c++;
#     }
# }

        .data
c:      .word 0

        .text
        .globl main

main:
        li $t0, 0          # i = 0
        li $t2, 1000       # upper bound for i

outer_loop:
        bge $t0, $t2, exit_outer  # if i >= 1000, break

        li $t1, 0          # j = 0
        li $t3, 5          # upper bound for j

inner_loop:
        bge $t1, $t3, exit_inner  # if j >= 5, break

        lw $t4, c
        addi $t4, $t4, 1
        sw $t4, c

        addi $t1, $t1, 1   # j++
        j inner_loop

exit_inner:
        addi $t0, $t0, 1   # i++
        j outer_loop

exit_outer:
        li $v0, 10
        syscall
