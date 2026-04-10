.data
fmt_int:  .asciz "%d "
fmt_last: .asciz "%d\n"

.text
.globl main

main:
    addi sp, sp, -64     
    sd ra, 56(sp)
    sd s0, 48(sp)   #n 
    sd s1, 40(sp)   #arr pointer
    sd s2, 32(sp)   #result pointer
    sd s3, 24(sp)   #stack pointer
    sd s4, 16(sp)   #stack top index
    sd s5, 8(sp)    # argv pointer
    sd s6, 0(sp)    #loop counter (i)

    addi s0, a0, -1      # s0 = n
    mv s5, a1            # s5 = argv

    ble s0, zero, main_exit #if n is <= 0 exit

    slli a0, s0, 2   #n * 4 bytes
    jal ra, malloc #call malloc
    mv s1, a0     #s1 = arr

    slli a0, s0, 2 #doing same for result
    jal ra, malloc
    mv s2, a0        #s2 = result

    slli a0, s0, 2  #doing same for stack array
    jal ra, malloc
    mv s3, a0     #s3 =stack_array

    li s6, 0  #i = 0 loop starts

parse_loop:
    bge s6, s0, parse_done  # i >= n then done

    addi t0, s6, 1       # i + 1
    slli t0, t0, 3  #(i+1) * 8 (pointers are 8 bytes)
    add t0, s5, t0  #add to base address

    ld a0, 0(t0)  #load pointer to string
    jal ra, atoi #convert to int

    slli t1, s6, 2  #do the same addressing for result
    add t1, s1, t1
    sw a0, 0(t1)      #store int in arr[i]

    addi s6, s6, 1 #i++
    jal x0, parse_loop

parse_done:
    li s6, 0  #i=0 reset

init_loop:
    bge s6, s0, init_done #if i >= n done
    slli t0, s6, 2  #multiply by 4 i*4
    add t0, s2, t0  # add to base address 
    li t1, -1
    sw t1, 0(t0)  # result[i] = -1

    addi s6, s6, 1  #i++
    jal x0, init_loop

init_done:
    li s4, -1   #stack top = -1
    addi s6, s0, -1   #i = n - 1 (Right to Left)

algo_loop:
    blt s6, zero, algo_done  #loop counter < 0 done
    slli t0, s6, 2
    add t0, s1, t0
    lw t0, 0(t0)         #t0 = arr[i]

pop_loop:
    li t1, -1 #stack top
    beq s4, t1, pop_done #stack empty then done
    slli t2, s4, 2   #stack top * 4
    add t2, s3, t2    #add to base add
    lw t2, 0(t2)     #t2 = stack[top] (index)

    slli t3, t2, 2  #multiply with 4 like idx*4
    add t3, s1, t3  # add to base add
    lw t3, 0(t3)       #t3 = arr[stack[top]]
    
    blt t0, t3, pop_done  #if arr[i] < arr[top] then done
    addi s4, s4, -1      #pop
    jal x0, pop_loop

pop_done:
    li t1, -1
    beq s4, t1, skip_result #if empty skip result storing

    slli t2, s4, 2  #stack top * 4
    add t2, s3, t2    # add to base
    lw t2, 0(t2)         #t2=stac[s4]

    slli t3, s6, 2
    add t3, s2, t3
    sw t2, 0(t3)         # result[i] = stack index

skip_result:
    addi s4, s4, 1    # top++
    slli t1, s4, 2
    add t1, s3, t1
    sw s6, 0(t1)         # stack[top] = i
    addi s6, s6, -1      # i--
    j algo_loop

algo_done:
    li s6, 0

print_loop:
    bge s6, s0, print_done
    slli t0, s6, 2
    add t0, s2, t0
    lw a1, 0(t0)    #load result[i] into a1

    addi t1, s0, -1
    beq s6, t1, print_last

    la a0, fmt_int    
    jal x0, do_printf

print_last:
    la a0, fmt_last  

do_printf:
    addi sp, sp, -32
    sd ra, 24(sp)
    jal ra, printf  
    ld ra, 24(sp)
    addi sp, sp, 32

    addi s6, s6, 1
    jal x0, print_loop

print_done:
    jal x0, main_exit

main_exit:
    li a0, 0   #restore
    ld ra, 56(sp)
    ld s0, 48(sp)
    ld s1, 40(sp)
    ld s2, 32(sp)
    ld s3, 24(sp)
    ld s4, 16(sp)
    ld s5, 8(sp)
    ld s6, 0(sp)
    addi sp, sp, 64
    ret
    