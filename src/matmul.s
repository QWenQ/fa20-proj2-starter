.globl matmul

.text
# =======================================================
# FUNCTION: Matrix Multiplication of 2 integer matrices
# 	d = matmul(m0, m1)
# Arguments:
# 	a0 (int*)  is the pointer to the start of m0 
#	a1 (int)   is the # of rows (height) of m0
#	a2 (int)   is the # of columns (width) of m0
#	a3 (int*)  is the pointer to the start of m1
# 	a4 (int)   is the # of rows (height) of m1
#	a5 (int)   is the # of columns (width) of m1
#	a6 (int*)  is the pointer to the the start of d
# Returns:
#	None (void), sets d = matmul(m0, m1)
# Exceptions:
#   Make sure to check in top to bottom order!
#   - If the dimensions of m0 do not make sense,
#     this function terminates the program with exit code 72.
#   - If the dimensions of m1 do not make sense,
#     this function terminates the program with exit code 73.
#   - If the dimensions of m0 and m1 don't match,
#     this function terminates the program with exit code 74.
# =======================================================
matmul:
    
    # Error checks
    blt x0, a1, check_next1    # r0 < 0
    li a1, 72
    j exit2

check_next1:    
    blt x0, a2, check_next2   # c0 < 0
    li a1, 72
    j exit2

check_next2:    
    blt x0, a4, check_next3   # r1 < 0
    li a1, 73
    j exit2

check_next3:    
    blt x0, a5, check_next4   # c1 < 0
    li a1, 73
    j exit2
    
check_next4:    
    beq a2, a4, no_exception    # c0 != r1
    li a1, 74
    j exit2
    

no_exception:
    # Prologue
    addi sp, sp, -44
    sw s0, 0(sp)
    sw s1, 4(sp)
    sw s2, 8(sp)
    sw s3, 12(sp)
    sw s4, 16(sp)
    sw s5, 20(sp)
    sw s6, 24(sp)
    sw s7, 28(sp)
    sw s8, 32(sp)
    sw s9, 36(sp)
    sw ra, 40(sp)
    
    
    mv s0, a0
    mv s1, a1
    mv s2, a2
    mv s3, a3
    mv s4, a4
    mv s5, a5
    mv s6, a6
    mv s7, s3
    
    li s8, 0    # s8 -> int i = 0
outer_loop_start:
    bge s8, s1, outer_loop_end
    li s9, 0    # s9 -> int j = 0
inner_loop_start:
    bge s9, s5, inner_loop_end
    
    mv a0, s0   # a0 -> m0
    mv a1, s3   # a1 -> m1
    mv a2, s2   # a2 -> width of column of m1
    li a3, 1    # a3 -> stride1: 1
    mv a4, s5   # a4 -> stride2: width of column of m1
    jal dot
    sw a0 0(s6)
    addi s6, s6, 4
    addi s3, s3, 4
    addi s9, s9, 1
    j inner_loop_start

inner_loop_end:
    slli t0, s2, 2
    add s0, s0, t0  # m0[i][0] -> m0[i + 1][0]
    mv s3, s7   # m1[0][j] -> m[0][0]
    addi s8, s8, 1
    j outer_loop_start
    
outer_loop_end:

    # Epilogue
    lw s0, 0(sp)
    lw s1, 4(sp)
    lw s2, 8(sp)
    lw s3, 12(sp)
    lw s4, 16(sp)
    lw s5, 20(sp)
    lw s6, 24(sp)
    lw s7, 28(sp)
    lw s8, 32(sp)
    lw s9, 36(sp)
    lw ra, 40(sp)
    addi sp, sp, 44    
    
    ret
