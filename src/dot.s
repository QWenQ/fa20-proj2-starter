.globl dot

.text
# =======================================================
# FUNCTION: Dot product of 2 int vectors
# Arguments:
#   a0 (int*) is the pointer to the start of v0
#   a1 (int*) is the pointer to the start of v1
#   a2 (int)  is the length of the vectors
#   a3 (int)  is the stride of v0
#   a4 (int)  is the stride of v1
# Returns:
#   a0 (int)  is the dot product of v0 and v1
# Exceptions:
# - If the length of the vector is less than 1,
#   this function terminates the program with error code 75.
# - If the stride of either vector is less than 1,
#   this function terminates the program with error code 76.
# =======================================================
dot:

    # Prologue
    # addi sp, sp, -4
    # sw ra, 0(sp)


loop_start:
    addi t0, x0, 0  # t0 -> dot product
    addi t1, x0, 0  # t1 -> int i = 0

loop_continue:
    bge t1, a2, loop_end
    lw t2, 0(a0)    # t2 -> *(vec1)
    lw t3, 0(a1)    # t3 -> *(vec2)
    mul t3, t2, t3  # product = *(vec1) * *(vec2)
    add t0, t0, t3
    addi t1, t1, 1
    slli t2, a3, 2  # t2 -> stride to next element 
    slli t3, a4, 2  # t3 -> stride to next element
    add a0, a0, t2
    add a1, a1, t3
    j loop_continue

loop_end:
    mv a0, t0   # a0 -> dot product
    # Epilogue
    # lw ra, 0(sp)
    # addi sp, sp, 4
    
    ret
