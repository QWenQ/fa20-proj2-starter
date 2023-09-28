.globl classify

.text
classify:
    # =====================================
    # COMMAND LINE ARGUMENTS
    # =====================================
    # Args:
    #   a0 (int)    argc
    #   a1 (char**) argv
    #   a2 (int)    print_classification, if this is zero, 
    #               you should print the classification. Otherwise,
    #               this function should not print ANYTHING.
    # Returns:
    #   a0 (int)    Classification
    # Exceptions:
    # - If there are an incorrect number of command line args,
    #   this function terminates the program with exit code 89.
    # - If malloc fails, this function terminats the program with exit code 88.
    #
    # Usage:
    #   main.s <M0_PATH> <M1_PATH> <INPUT_PATH> <OUTPUT_PATH>
    
    # Error check:
    # If there are an incorrect number of command line args, this function terminates the program with exit code 89.
    li t0, 5
    beq a0, t0, no_exception
    li a1, 89
    j exit2
    
no_exception:
    # Prelogue:
    addi sp, sp, -52
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
    sw s10, 40(sp)
    sw s11, 44(sp)
    sw ra, 48(sp)
    
    mv s0, a0   # s0 -> argc
    mv s1, a1   # s1 -> argv[]
    mv s2, a2   # s2 -> print
    
	# =====================================
    # LOAD MATRICES
    # =====================================

    # Load pretrained m0
    
    addi a0, x0, 4
    jal malloc
    mv s3, a0   # s3 -> int* m0_row
    
    addi a0, x0, 4
    jal malloc
    mv s4, a0   # s4 -> int* m0_col
    
    addi a0, s1, 4  # a0 -> argv[1]
    mv a1, s3   # a1 -> int* m0_row
    mv a2, s4   # a2 -> int* m0_col
    jal read_matrix
    mv s5, a0   # s5 -> int* m0

    # Load pretrained m1
    addi a0, x0, 4
    jal malloc
    mv s6, a0   # s6 -> int* m1_row
    
    addi a0, x0, 4
    jal malloc
    mv s7, a0   # s7 -> int* m1_col
    
    addi a0, s1, 8  # a0 -> argv[2]
    mv a1, s6   # a1 -> int* m1_row
    mv a2, s7   # a2 -> int* m1_col
    jal read_matrix
    mv s8, a0   # s8 -> int* m1

    # Load input matrix
    addi a0, x0, 4
    jal malloc
    mv s9, a0   # s9 -> int* input_row
    
    addi a0, x0, 4
    jal malloc
    mv s10, a0   # s10 -> int* input_col
    
    addi a0, s1, 12 # a0 -> argv[3]
    mv a1, s9   # a1 -> int* input_row
    mv a2, s10  # a2 -> int* input_col
    jal read_matrix
    mv s11, a0  # s11 -> int* input

    # =====================================
    # RUN LAYERS
    # =====================================
    
    lw t0, 0(s4)
    lw t1, 0(s9)
    mul a0, t0, t1
    slli a0, a0, 2  # a0 -> size of int* hidden_layer
    jal malloc
    # - If malloc fails, this function terminats the program with exit code 88.
    beq a0, x0, linear_layer1
    li a1, 88
    j exit2
    
linear_layer1:
    mv s0, a0   # s0 -> int* hidden_layer
    # 1. LINEAR LAYER:    m0 * input
    mv a0, s5   # a0 -> int* m0
    lw a1, 0(s3)   # a1 -> *m0_row
    lw a2, 0(s4)   # a2 -> *m0_col
    mv a3, s11  # a3 -> int* input
    lw a4, 0(s9)   # a4 -> *input_row
    lw a5, 0(s10)  # a5 -> *input_col
    mv a6, s0   # a6 -> int* hidden_layer
    jal matmul
    
    # 2. NONLINEAR LAYER: ReLU(m0 * input)
    mv a0, s0   # a0 -> int* hidden_layer
    lw t0, 0(s4)
    lw t1, 0(s9)
    mul a1, t0, t1  # a1 -> (*m0_col) * (*input_row)
    jal relu
    
    
    # allocate memory for int* scores
    lw t0, 0(s7)
    lw t1, 0(s4)
    mul a0, t0, t1
    slli a0, a0, 2
    jal malloc
    bne a0, x0, linear_layer2
    li a1, 88
    j exit2
linear_layer2:
    mv s11, a0  # s11 -> int* scores
    # 3. LINEAR LAYER:    m1 * ReLU(m0 * input)
    mv a0, s8   # a0 -> int* m1
    lw a1, 0(s6)   # a1 -> *m1_row
    lw a2, 0(s7)   # a2 -> *m1_col
    mv a3, s0   # a3 -> int* hidden_layer
    lw a4, 0(s4)   # a4 -> *m0_col
    lw a5, 0(s9)   # a5 -> *input_row
    mv a6, s11  # a6 -> int* scores
    jal matmul

    # =====================================
    # WRITE OUTPUT
    # =====================================
    # Write output matrix
    addi a0, s1, 16 # a0 -> argv[4](char* output)
    mv a1, s11  # a1 -> int* scores
    lw a2, 0(s7)    # a2 -> *m1_col
    lw a3, 0(s4)    # a3 -> *m0_col
    jal write_matrix

    # =====================================
    # CALCULATE CLASSIFICATION/LABEL
    # =====================================
    # Call argmax
    mv a0, s11  # a0 -> int* scores
    lw t0, 0(s7)
    lw t1, 0(s4)
    mul a1, t0, t1  # a1 -> (*m1_col) * (*m0_col)
    jal argmax

    # Print classification
    bne s2, x0, next
    mv a1, a0   # a1 -> int classification
    jal print_int
    
next:
    # TODO: free allocated memory space
    # Print newline afterwards for clarity
    li a1, '\n'
    jal print_char
    
    #Epilogue
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
    lw s10, 40(sp)
    lw s11, 44(sp)
    lw ra, 48(sp)
    addi sp, sp, 52

    ret
