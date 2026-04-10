#struct offset 
#offset 0 is val (4 bytes)
#offset 4 is padding (4 bytes)
#offset 8 is left (8 bytes bcuzpointer)
#offset 16 is right (8 bytes bcuz pointer)

.text

.globl make_node
make_node:
    addi sp, sp, -16  #need 8 bt multiple of 16
    sd ra, 8(sp)   # return address store at sp+8
    sd s0, 0(sp)   #saved register
    #from reg to mem

    mv s0, a0   #a0 has input so copy to s0 now saved through calls

    li a0, 24           # (4 val + 4 pad + 8 left + 8 right)
    jal ra, malloc #call malloc12 back to ra

    sw s0, 0(a0)  #s0 has root val as a0+0 is root
    sd zero, 8(a0)    #basically left ie at add a0+4 store 0 ie NULL
    sd zero, 16(a0)     #also right NULL

    ld ra, 8(sp)      #from mem into reg
    ld s0, 0(sp)  #restore back val of s0 from mem add it was stored input
    addi sp, sp, 16 #restore stack
    jalr x0, 0(ra) #jump to ra like return to caller fn

.globl insert
insert:
    addi sp, sp, -32  
    sd ra, 24(sp) #save return add
    sd s0, 16(sp) #using it to store root
    sd s1, 8(sp) #and val
 #sd from reg to mem

    mv s0, a0    #s0 = root
    mv s1, a1    #s1= val

    bne a0, zero, insert_notnull  #if root is not null
    #go to insert not null

    mv a0, s1           #val in a1 now
    jal ra, make_node  #rec call for make_node(val)
    jal x0, insert_done       # Result in a0 is the new node

insert_notnull:
    lw t0, 0(s0)        #has root->val
    bge s1, t0, insert_right #if val > root

#otherwise:

insert_left:
    ld a0, 8(s0)   #this is root left so now a0 has rooot left
    mv a1, s1 #a1 has val
    jal ra, insert #so now call insert for a0
    sd a0, 8(s0)        #uppdate root->left with returned pointer
    jal x0, insert_return_root

insert_right:
    beq s1, t0, insert_return_root #if equal
    #do nothing
    ld a0, 16(s0)     #load root->right
    mv a1, s1 #a1 is val now
    jal ra, insert #recursive insert call for root right
    sd a0, 16(s0) #update root->right

insert_return_root:
    mv a0, s0     #return s0 ir og root

insert_done:
    ld ra, 24(sp) #restore
    ld s0, 16(sp)
    ld s1, 8(sp)
    addi sp, sp, 32 
    jalr x0, 0(ra)

.globl get
get:
    addi sp, sp, -32
    sd ra, 24(sp)
    sd s0, 16(sp) #store root here
    sd s1, 8(sp)  # and val here

    mv s0, a0  #root at s0
    mv s1, a1 #val at s1

    bne s0, zero, get_check  #if root is not null
    li a0, 0  #otherwise root is null so return null
    jal x0, get_done #go to end

get_check:
    lw t0, 0(s0)  #t0 root val
    beq s1, t0, get_found  # if val is root go to found 
    blt s1, t0, get_left  #if its less go to left

get_right:
    ld a0, 16(s0) #a0 now has root right
    mv a1, s1  #a1 has val
    jal ra, get #rec call for root right
    jal x0, get_done 

get_left:
    ld a0, 8(s0) #a0 has root left
    mv a1, s1  #a1 has val
    jal ra, get #rec call for root left
    jal x0, get_done  #jump to done

get_found:
    mv a0, s0  #return curr node pointer

get_done:
    ld ra, 24(sp)  #restore
    ld s0, 16(sp)
    ld s1, 8(sp)
    addi sp, sp, 32 
    jalr x0, 0(ra)

.globl getAtMost
getAtMost:
    addi sp, sp, -32  #space allocation 
    sd ra, 24(sp)
    sd s1, 16(sp)  #to storeroot
    sd s0, 8(sp)   #to store val

    mv s0, a0  #s0 has val
    mv s1, a1   #s1 has root

    bne s1, zero, getAtMost_check #if root is not null then check
    li a0, -1           #not found ret -1
    j getAtMost_done #final done

getAtMost_check:
    lw t0, 0(s1)  #t0 root value

    blt s0, t0, getAtMost_go_left #target is smaller than root so go left
    beq s0, t0, getAtMost_exact #if exact match

    #otherwise if smaller
    mv a0, s0 #a0 now has val
    ld a1, 16(s1) #now has root right
    jal ra, getAtMost #so rec call for root right

    li t1, -1 
    beq a0, t1, getAtMost_use_current #if right is empty like ret -1 current is best
    jal ra, getAtMost_done #so rec call for root right

getAtMost_use_current:
    lw a0, 0(s1)  #like exact match ret root val
    jal x0, getAtMost_done 

getAtMost_exact:
    lw a0, 0(s1) #if it was exact jst ret root val
    jal x0, getAtMost_done 

getAtMost_go_left:
    mv a0, s0 
    ld a1, 8(s1) #a1 now has root left
    jal ra, getAtMost #rec call for root left

getAtMost_done:
    ld ra, 24(sp) #restore
    ld s1, 16(sp)
    ld s0, 8(sp)
    addi sp, sp, 32 
    jalr x0, 0(ra)
