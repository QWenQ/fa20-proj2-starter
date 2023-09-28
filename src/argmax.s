.globl argmax

.text
# =================================================================
# FUNCTION: Given a int vector, return the index of the largest
#	element. If there are multiple, return the one
#	with the smallest index.
# Arguments:
# 	a0 (int*) is the pointer to the start of the vector
#	a1 (int)  is the # of elements in the vector
# Returns:
#	a0 (int)  is the first index of the largest element
# Exceptions:
# - If the length of the vector is less than 1,
#   this function terminates the program with error code 77.
# =================================================================
argmax:

    # Prologue
    addi sp, sp, -4
    sw ra, 0(sp)
    
loop_start:
    addi t0, x0, 0  # index of the largest element
    lw t1, 0(a0)    # t1 -> the current largest element
    addi t2, x0, 0  # t2 -> int i = 0

loop_continue:
    bge t2, a1, loop_end
    lw t3, 0(a0)    # t3 -> vector[i]
    bge t1, t3, next
    mv t0, t2
    mv t1, t3
next:
    addi t2, t2, 1
    addi a0, a0, 4
    j loop_continue
    
loop_end:
    mv a0, t0
    
    # Epilogue
    lw ra, 0(sp)
    addi sp, sp, 4

    ret
