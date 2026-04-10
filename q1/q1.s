//offset 0 -> val (4 bytes)
//offset 4 -> left (8 bytes, pointer 4 bytes)
//offset 8 -> right (8 bytes, pointer 4 bytes)

.text

.globl make_node
make_node:
    addi sp, sp, -16 //need 8 but padding
    sw ra, 12(sp) //return address store at sp+12
    sw s0, 8(sp) //saved register
    //sw from reg to mem

    mv s0, a0 //a0 has input so copy to s0 now saved through calls

    li a0, 12 //3ints * 4bytes mem required
    jal ra, malloc //call malloc12 back to ra 
    //a0 is now pointer

    sw s0, 0(a0) //s0 has root val as a0+0 is root
    sw zero, 4(a0) //basically left ie at add a0+4 store 0 ie NULL
    sw zero, 8(a0) //also right NULL

    lw ra, 12(sp) //lw form mem into reg 
    //ie from sp to return address
    lw s0, 8(sp) //restore back val of s0 from mem add it was stored input
    //ie sp + 8
    addi sp, sp, 16 //restore stack
    jalr x0, 0(ra) //jump to add in ra 
    //like return to caller func

.globl insert
insert:
    addi sp, sp, -24
    sw ra, 20(sp) //save return add
    sw s0, 16(sp) //using it to store root
    sw s1, 12(sp)//and val 

    mv s0, a0 //s0 = root
    mv s1, a1 //s1 has val

    bne a0, zero, insert_notnull //if root is not NULL 
    //go to insertnot null
    //if null:
    mv a0, s1 //val in a1
    jal ra, make_node //calls make_node(val)
    jal x0, insert_done //unconditional jump go to end

insert_notnull:
    lw t0, 0(s0) //has root val
    bge s1, t0, insert_right // if val > root

//else:
insert_left:
    lw a0, 4(s0) //this is root left so now a0 has rooot left
    mv a1, s1 //a1 val
    jal ra, insert //so now call insert for a0
    sw a0, 4(s0) //a0 is returned store it
    jal x0, insert_return_root

insert_right:
    beq s1, t0, insert_return_root //if equal 
    //do nothing
    //return root
    lw a0, 8(s0) //a0 is root right
    mv a1, s1 //a1 is val now
    jal ra, insert //so jmp to insert call for root right 
    //thts in a0 now
    sw a0, 8(s0) //so root right is returned

insert_return_root:
    mv a0, s0 //return s0 ie original

insert_done:
    lw ra, 20(sp) //restore
    lw s0, 16(sp)
    lw s1, 12(sp)
    addi sp, sp, 24
    jalr x0, 0(ra)

.globl get
get:
    addi sp, sp, -24
    sw ra, 20(sp)
    sw s0, 16(sp) //store root here
    sw s1, 12(sp) //store val here

    mv s0, a0 //root at s0
    mv s1, a1 //val at s1

    bne s0, zero, get_check //if root is not null
    //call check function
    li a0, 0 //store 0 in a0 to return null
    jal x0, get_done //go to end

get_check:
    lw t0, 0(s0) //t0 root val
    beq s1, t0, get_found //if val is root
    //go to found
    blt s1, t0, get_left //if its less 
    //go to left

get_right:
    lw a0, 8(s0) //a0 now has root right
    mv a1, s1 //a1 has val
    jal ra, get //recursive call 
    jal x0, get_done //jump to done

get_left:
    lw a0, 4(s0) //a0 has root left
    mv a1, s1 //a1 is val
    jal ra, get //call for root left 
    jal x0, get_done //jump to done

get_found:
    mv a0, s0 //return curr node pointer

get_done:
    lw ra, 20(sp) //restore
    lw s0, 16(sp)
    lw s1, 12(sp)
    addi sp, sp, 24
    jalr x0, 0(ra)

.globl getAtMost
getAtMost:
    addi sp, sp, -32 //space allocation
    sw ra, 28(sp) 
    sw s0, 24(sp) //to store val
    sw s1, 20(sp) //to store root

    mv s0, a0 //s0 has val
    mv s1, a1 //s1 has root

    bne s1, zero, getAtMost_check //if root is not null then go
    //to check otherwise its null no match obv:
    li a0, -1 //ret -1
    jal x0, getAtMost_done //final done

getAtMost_check:
    lw t0, 0(s1) //t0 root val

    blt s0, t0, getAtMost_go_left //target is smaller thn root
    //so go left
    beq s0, t0, getAtMost_exact //exact match this is the ans

    mv a0, s0 //now has val
    lw a1, 8(s1) //now has root right
    jal ra, getAtMost //so rec call for root right

    li t1, -1 
    beq a0, t1, getAtMost_use_current //if res from right subtree is -1
    //then current node is best

    jal x0, getAtMost_done //if other val then done

getAtMost_use_current:
    lw a0, 0(s1) //so jst ret root val
    jal x0, getAtMost_done

getAtMost_exact:
    lw a0, 0(s1) //if it was exact jst return root val
    jal x0, getAtMost_done 

getAtMost_go_left:
    mv a0, s0
    lw a1, 4(s1) //so a1 now has root left
    jal ra, getAtMost //rec call root left

getAtMost_done:
    lw ra, 28(sp) //restore
    lw s0, 24(sp)
    lw s1, 20(sp)
    addi sp, sp, 32
    jalr x0, 0(ra)