.globl write_matrix

.text
# ==============================================================================
# FUNCTION: Writes a matrix of integers into a binary file
# FILE FORMAT:
#   The first 8 bytes of the file will be two 4 byte ints representing the
#   numbers of rows and columns respectively. Every 4 bytes thereafter is an
#   element of the matrix in row-major order.
# Arguments:
#   a0 (char*) is the pointer to string representing the filename
#   a1 (int*)  is the pointer to the start of the matrix in memory
#   a2 (int*)   is the number of rows in the matrix
#   a3 (int*)   is the number of columns in the matrix
# Returns:
#   None
# Exceptions:
# - If you receive an fopen error or eof,
#   this function terminates the program with error code 93.
# - If you receive an fwrite error or eof,
#   this function terminates the program with error code 94.
# - If you receive an fclose error or eof,
#   this function terminates the program with error code 95.
# ==============================================================================
write_matrix:

    # Prologue
    addi sp, sp, -24
    sw s0, 0(sp)
    sw s1, 4(sp)
    sw s2, 8(sp)
    sw s3, 12(sp)
    sw s4, 16(sp)
    sw ra, 20(sp)
    
    mv s0, a0   # s0 -> char* filename
    mv s1, a1   # s1 -> int* matrix
    mv s2, a2   # s2 -> int* rows
    mv s3, a3   # s3 -> int* cols
    
    mv a1, s0
    li a2, 1
    jal fopen
    li t0, -1
    bne a0, t0, write_row_to_file
    li a1, 93
    j exit2
    
write_row_to_file:
    mv s4, a0   # s4 -> file descriptor
    mv a1, s4
    mv a2, s2
    li a3, 1
    li a4, 4
    jal fwrite
    #li t0, 1
    #beq a0, t0, write_col_to_file
    #li a1, 94
    #j exit2
    
write_col_to_file:
    mv a1, s4
    mv a2, s3
    li a3, 1
    li a4, 4
    jal fwrite
    #li t0, 1
    #beq a0, t0, write_array_to_file
    #li a1, 94
    #j exit2
    
write_array_to_file:
    mv a1, s4
    mv a2, s1
    lw t0, 0(s2)
    lw t1, 0(s3)
    mul a3, t0, t1
    li a4, 4
    jal fwrite
    lw t0, 0(s2)
    lw t1, 0(s3)
    mul t0, t0, t1
    beq a0, t0, close_file
    li a1, 94
    j exit2

close_file:
    mv a1, s4
    jal fclose
    beq a0, x0, end
    li a1, 95
    j exit2
end:

    # Epilogue
    lw s0, 0(sp)
    lw s1, 4(sp)
    lw s2, 8(sp)
    lw s3, 12(sp)
    lw s4, 16(sp)
    lw ra, 20(sp)
    addi, sp, sp, 24
    
    ret
