.globl read_matrix

.text
# ==============================================================================
# FUNCTION: Allocates memory and reads in a binary file as a matrix of integers
#
# FILE FORMAT:
#   The first 8 bytes are two 4 byte ints representing the # of rows and columns
#   in the matrix. Every 4 bytes afterwards is an element of the matrix in
#   row-major order.
# Arguments:
#   a0 (char*) is the pointer to string representing the filename
#   a1 (int*)  is a pointer to an integer, we will set it to the number of rows
#   a2 (int*)  is a pointer to an integer, we will set it to the number of columns
# Returns:
#   a0 (int*)  is the pointer to the matrix in memory
# Exceptions:
# - If malloc returns an error,
#   this function terminates the program with error code 88.
# - If you receive an fopen error or eof, 
#   this function terminates the program with error code 90.
# - If you receive an fread error or eof,
#   this function terminates the program with error code 91.
# - If you receive an fclose error or eof,
#   this function terminates the program with error code 92.
# ==============================================================================
read_matrix:

    # Prologue
    addi sp, sp, -32
    sw s0, 0(sp)
    sw s1, 4(sp)
    sw s2, 8(sp)
    sw s3, 12(sp)
    sw s4, 16(sp)
    sw s5, 20(sp)
    sw s6, 24(sp)
    sw ra, 28(sp)
    
    mv s0, a0   # s0 -> int* matrix
    mv s1, a1   # s1 -> int* row
    mv s2, a2   # s2 -> int* col

open_file:
    mv a1, s0
    li a2, 0
    jal fopen
    # if fd == EOF(-1)
    li t0, -1
    bne a0, t0, get_row
    li a1, 90
    j exit2
    
get_row:
    mv s4, a0   # s4 -> file descriptor
    mv a1, s4
    mv a2, s1
    li a3, 4
    jal fread
    # if the number of read bytes != specified bytes
    #li t0, 4
    #beq a0, t0, check_rows_val
    #li a1, 91
    #j exit2
    
check_rows_val:
    lw t0, 0(s1)
    bne t0, x0, get_col
    li a1, 91
    j exit2

get_col:
    mv a1, s4
    mv a2, s2
    li a3, 4
    jal fread
    # if the number of read bytes != specified bytes
    #li t0, 4
    #beq a0, t0, check_cols_val
    #li a1, 91
    #j exit2
    
check_cols_val:
    lw t0, 0(s2)
    bne t0, x0, allocate_for_new_matrix
    li a1, 91
    j exit2

allocate_for_new_matrix:
    lw t0, 0(s1)
    lw t1, 0(s2)
    mul a0, t0, t1
    slli a0, a0, 2
    jal malloc
    # if malloc returns NULL
    bne a0, x0, fill_matrix_content
    li a1, 88
    j exit2

fill_matrix_content:
    mv s5, a0   # s5 -> int* new_matrix
    mv a1, s4
    mv a2, s5
    lw a3, 0(s1)
    lw t0, 0(s2)
    mul a3, a3, t0
    slli a3, a3, 2
    mv s6, a3   # s6 -> the bytes should read from file
    jal fread
    # if the number of read bytes != specified bytes
    beq a0, s6, close_file
    # free the allocated memory
    mv a0, s5
    jal free
    mv a0, x0
    li a1, 91
    j exit2
    
close_file:
    mv a1, s4
    jal fclose
    # if fclose fails, return EOF
    beq a0, x0, end
    # free the allocated memory
    mv a0, s5
    jal free
    mv a0, x0
    li a1, 92
    j exit2

end:
    mv a0, s5

    # Epilogue
    lw s0, 0(sp)
    lw s1, 4(sp)
    lw s2, 8(sp)
    lw s3, 12(sp)
    lw s4, 16(sp)
    lw s5, 20(sp)
    lw s6, 24(sp)
    lw ra, 28(sp)
    addi sp, sp, 32

    ret
