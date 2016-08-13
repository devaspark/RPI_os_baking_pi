/******************************************************************************
*	main.s
*	 by Rex Kung
*
*	This is a modified source code from Alex Chadwick to continue with the OS
*	on R_PI
*	Changes since OK02 are marked with NEW.
******************************************************************************/

/*
* .section is a directive to our assembler telling it to place this code first.
* .globl is a directive to our assembler, that tells it to export this symbol
* to the elf file. Convention dictates that the symbol _start is used for the 
* entry point, so this all has the net effect of setting the entry point here.
* Ultimately, this is useless as the elf itself is not used in the final 
* result, and so the entry point really doesn't matter, but it aids clarity,
* allows simulators to run the elf, and also stops us getting a linker warning
* about having no entry point. 
*/
.section .init
.globl _start
_start:

/* NEW
* Branch to the actual main code.
*/
b main

/* NEW
* This command tells the assembler to put this code with the rest.
*/
.section .text

/* NEW
* main is what we shall call our main operating system method. It never 
* returns, and takes no parameters.
* C++ Signature: void main(void)
*/
main:

/* NEW
* Set the stack point to 0x8000.
*/
mov sp, #0x8000

/* New
* Set the GPIO function select. Set pin #16 and pin function code to 1.
*/
pinNum .req r0
pinFunc .req r1
mov pinNum,#16
mov pinFunc, #1
bl SetGpioFunction
.unreq pinNum
.unreq pinFunc

/* NEW
* Label the next line loop$ for the infinite looping
*/
loop$: 

/* New
* Set GPIO 16 to low, causing the LED to turn on.
*/
pinNum .req r0
pinVal .req r1
mov pinNum,#16
mov pinVal, #0
bl SetGpio
.unreq pinNum
.unreq pinVal

/* NEW
* Now, to create a delay, we busy the processor on a pointless quest to 
* decrement the number 0x3F0000 to 0!
*/
mov r0,#0x3F0000
bl waitTime

/* NEW
* Set GPIO 16 to high, causing the LED to turn off.
*/
pinNum .req r0
pinVal .req r1
mov pinNum,#16
mov pinVal, #1
bl SetGpio
.unreq pinNum
.unreq pinVal

/* NEW
* Now, to create a delay, we busy the processor on a pointless quest to 
* decrement the number 0x3F0000 to 0!
*/
mov r0,#0x3F0000
bl waitTime

/*
* Loop over this process forevermore
*/
b loop$


