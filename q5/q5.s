.section .data    #region of memory declare and store initialized static data
filename: .asciz "input.txt"  #string with null terminatore
yes_msg: .ascii "Yes\n"   #raw string no null term
no_msg: .ascii "No\n"


#uninitialized data
.section .bss
char_l: .byte 0     #reserve 1 byte
char_r: .byte 0     #store left and right characters


#code section
.section .text
.globl _start
#start is entry point like main

#a0-a7 are function syscall registers
#a7 is syscall number

_start:
    li a7, 56       #56 syscall for openat opens the file
    li a0, -100      #-100 is look in current directory
    la a1, filename  #load memory location of input.txt into a1 reg
    li a2, 0        #open in read only mode (0 here signifies read only)
    li a3, 0        #a3 is mode here unused so 0
    ecall           #make system call
    #here ecall calls openat -100 input.txt 0 0
    #after syscall a0 has file descriptor
    mv s0, a0     #we save it to s0

    li a7, 62            #62 is syscall lseek
    mv a0, s0            #first argument is file descriptor
    li a1, 0            #offset = 0 load to reg a1
    li a2, 2        #a2 = 2
    ecall           #call syscall
    #lseek(file descriptor, offset, 2(2 is seek_end))
    #0 is start, 1 is current, 2 is end
    mv s1, a0       #store result that is the file size in s1

    li t0, 1
    ble s1, t0, is_palindrome   #if filesize <= 1 then go to is_palindrome

    li s2, 0        #left pointer is start of file save to s2 
    addi s3, s1, -1     #file size - 1 is stored in s3 i.e. right pointer

#left pointer equals i say 
#right is j 
#s2 has left pointer
#s3 has right

loop:
    bge s2, s3, is_palindrome  #if i>= j is_palindrome proved

    li a7, 62       #load 62 syscall ie lseek
    mv a0, s0       #load file descriptor
    mv a1, s2       #left index is offset
    li a2, 0        #seek set from start because 0 is start
    ecall           #syscall
    #now this moves pointer to s2 ie the left index

    li a7, 63       #63 syscall is read
    mv a0, s0       #again load file descriptor
    la a1, char_l   #this is the buffer argument
    li a2, 1        #in order to signify that read 1 byte
    ecall           #so we read(fd, charl, 1)
    #i.e. we read 1byte that is 1char from the left char

    li a7, 62       #agin setting the right pointer
    mv a0, s0       #same as left
    mv a1, s3
    li a2, 0
    ecall

    li a7, 63       #read 1byte from right
    mv a0, s0       #same as reading left
    la a1, char_r
    li a2, 1
    ecall

    lb t1, char_l       #load byte into t1
    lb t2, char_r       #load byte into t2
    bne t1, t2, not_palindrome  #if not equal then not palindrome break

    addi s2, s2, 1      #i++
    addi s3, s3, -1     #j--
    jal x0, loop        #jump to loop ie loop again

is_palindrome:
    li a7, 64       #syscall 64 is write
    li a0, 1        #a0 load 1
    #because in 0 is stdin, 1 is stdout, 2 is stderr
    la a1, yes_msg      #load address of yesmsg
    li a2, 4        #4 characters so 4 bytes including \n
    ecall       #syscall now calls write(1, yes\n, 4)
    jal x0, exit        #go to exit

not_palindrome:
    li a7, 64       #same thing with no 
    li a0, 1
    la a1, no_msg
    li a2, 3
    ecall

exit:
    li a7, 93       #93 is exit
    li a0, 0        #this calls exit(0) that is just exit
    ecall
    