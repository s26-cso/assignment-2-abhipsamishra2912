.text
.globl main
.data
fmt_int: .asciz "%d "
fmt_last: .asciz "%d\n"

main:
    addi sp, sp, -64     # Increased size for 8-byte alignment
    sd ra, 56(sp)
    sd s0, 48(sp)        # n
    sd s1, 40(sp)        # arr
    sd s2, 32(sp)        # result
    sd s3, 24(sp)        # stack array
    sd s4, 16(sp)        # stack top
    sd s5, 8(sp)         # argv
    sd s6, 0(sp)         # loop counter

    addi s0, a0, -1   #s0 = argc - 1
    mv s5, a1         # s5 = argv its a pointer to string of inputs

    ble s0, zero, main_exit #if n is <= 0 exit

main_alloc:
    slli a0, s0, 2       #multiply into 4(size of int)
    jal ra, malloc  #allocate memory that many bytes
    mv s1, a0  #s1 = arr (pointer to it)

    slli a0, s0, 2 #doing same for result
    jal ra, malloc
    mv s2, a0     #s2 = result also pointer

    slli a0, s0, 2 #doing same for stack array
    jal ra, malloc
    mv s3, a0    #s3 = stack array

    li s4, -1   #stack top = -1
    li s6, 0    #i = 0 loop starts

parse_loop:
    bge s6, s0, parse_done # i >= n then done

    addi t0, s6, 1 #i + 1
    slli t0, t0, 3    #multiply with 8 cuz 8 bytes
    add t0, s5, t0  # add to base address

    ld a0, 0(t0)         #load string pointer
    jal ra, atoi   #convert to integer

    slli t1, s6, 2  #do the same addressing for result
    add t1, s1, t1
    sw a0, 0(t1)         #store 4-byte int in arr

    addi s6, s6, 1  #i++
    jal x0, parse_loop  

parse_done:
    li s6, 0  #i=0 reset

init_loop:
    bge s6, s0, init_done  #if i >= n done
    slli t0, s6, 2   #multiply by 4 i*4
    add t0, s2, t0   # add to base address 
    li t1, -1 
    sw t1, 0(t0)   #result[i] = -1
     
    addi s6, s6, 1 #i++
    jal x0, init_loop

init_done:
    addi s6, s0, -1      # i = n - 1

algo_loop:
    blt s6, zero, algo_done  #loop counter < 0 done
    slli t0, s6, 2 #multiply i with 4
    add t0, s1, t0  # add to base add
    lw t0, 0(t0)         # t0 = arr[i]

pop_loop:
    li t1, -1  #stacktop
    beq s4, t1, pop_done  #if stack empty then done
    slli t2, s4, 2  #stack top * 4
    add t2, s3, t2  # add to base add
    lw t2, 0(t2)    #t2 = stack[top] (index)

    slli t3, t2, 2  #multiply with 4 like idx*4
    add t3, s1, t3  # add to base add
    lw t3, 0(t3)   #t3 = arr[stack.top]

    blt t0, t3, pop_done  #if arr[i] < arr[top] then done
    addi s4, s4, -1      #pop
    jal x0, pop_loop 

pop_done:
    li t1, -1
    beq s4, t1, skip_result  #if empty skip_result

    slli t2, s4, 2  #stack top * 4
    add t2, s3, t2  # add to base
    lw t2, 0(t2)    #t2 = stack[s4]

    slli t3, s6, 2  
    add t3, s2, t3  #s6 = i
    sw t2, 0(t3)    #result[i] = stack index

skip_result:
    addi s4, s4, 1 #top++
    slli t0, s4, 2 #multiply 4
    add t0, s3, t0 
    sw s6, 0(t0)         #push current index so stack[top] = i

    addi s6, s6, -1 #move to next as right to left traversal
    jal x0, algo_loop

algo_done:
    li s6, 0  #start from 0 again

print_loop:
    bge s6, s0, print_done 

    slli t0, s6, 2 
    add t0, s2, t0 
    lw a1, 0(t0)        # Result value to print in a1

    # Check if last element
    addi t1, s0, -1
    beq s6, t1, last_elem

    la a0, fmt_int      # "%d "
    j do_the_print

last_elem:
    la a0, fmt_last

do_the_print:
    addi sp, sp, -32
    sd ra, 24(sp)
    sd s6, 16(sp)       # Save s6 just in case printf is weird
    # (Optional: save t-regs if you need them later, but here we don't)

    jal ra, printf

    ld ra, 24(sp)
    ld s6, 16(sp)
    addi sp, sp, 32

    addi s6, s6, 1      # Increment loop counter
    j print_loop        # Repeat

print_done:
    j main_exit

main_exit:
    li a0, 0  #restore
    ld ra, 56(sp)
    ld s0, 48(sp)
    ld s1, 40(sp)
    ld s2, 32(sp)
    ld s3, 24(sp)
    ld s4, 16(sp)
    ld s5, 8(sp)
    ld s6, 0(sp)
    addi sp, sp, 64
    jalr x0, 0(ra)
