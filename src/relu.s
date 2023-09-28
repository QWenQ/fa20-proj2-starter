.globl relu
.text
# ==============================================================================
# FUNCTION: Performs an inplace element-wise ReLU on an array of ints
# Arguments:
# 	a0 (int*) is the pointer to the array
#	a1 (int)  is the # of elements in the array
# Returns:
#	None
# Exceptions:
# - If the length of the vector is less than 1,
#   this function terminates the program with error code 78.
# ==============================================================================
relu:
    # Error check
    blt x0, a1, no_exception
    li a1, 78
    j exit2
    
no_exception:
    # Prologue
    addi sp, sp, -4
    sw ra, 0(sp)
    
loop_start:
    addi t0, x0, 0  # t0 -> int i = 0

loop_continue:
    bge t0, a1, loop_end    # if i < n
    lw t1, 0(a0)
    bge t1, x0, next
    sw x0, 0(a0)    # if arr[i] < 0, arr[i] = 0
next:
    addi t0, t0, 1
    addi a0, a0, 4
    j loop_continue
    
loop_end:

    # Epilogue
    lw ra, 0(sp)
    addi sp, sp, 4
    
	ret
