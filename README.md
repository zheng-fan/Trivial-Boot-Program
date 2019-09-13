This is a 16-bit program that can run without an operating system and do some work including booting an operating system. It's purely written in 8086 16-bit assembly language (Intel syntax). 

# Features

This program is an installer which can write the main program to the MBR of a floppy disk. When the computer starts, this program will be loaded to memory and executed first just after the BIOS program finished.

The main program has the following functions:

* **Reset PC**: Just reboot PC
* **Start system**: Boot operating system in the hard drive
* **Clock**: Display current time
* **Set clock**: Input and set the time in motherboard

# Environment

You need a Windows XP / Windows 98, or, a 32-bit Windows 7 to run this 16-bit program.

Using a virtual machine would be a good choice. It's easy to create a floppy disk. Actually, to write the hard disk's MBR is also OK, however, it will destroy the boot program of operating system in the hard drive.

# Build

You need a MASM and using the `MASM.EXE` and `LINK.EXE`to build. As you know, MASM is a very old program and is not easy to use. Therefore, I wrote some tools to make things easier. You can compile the program in the *tools* directory then run `asmr main.asm` to assemble, link and run the program, or, use `asm main.asm` to assemble and link it but without running.

For me, I also used the `debug.exe` program for single step debugging.

# Details and Demo

You can get more details by browsing [my blog](https://debug.fanzheng.org/post/an-operating-system-independent-assembly-program.html) (in Chinese) and there is a demo at the bottom of the post.
