/******************************************************************************
*	main.s
*	 by Rex Kung
*
*	This is a modified source code from Alex Chadwick to continue with the OS
*	on R_PI
*	Changes since OK02 are marked with NEW.
******************************************************************************/


/* New
* Putting in the new function for OK 3
* This is suppose to get the GPIO address and return it via r0
* Remember .globl is needed to make the function accessible from other files.
*/
.globl GetGpioAddress
GetGpioAddress
ldr r0,=0x20200000  //This is the address for the GPIO per spec
mov pc,lr

/* New
* Putting in new function to set the GPIO Pin and the function
*/
.globl SetGpioFunction
SetGpioFunction:
cmp r0,#53
cmpls r1,#7		//ls (less or same) after cmp applies to previous statement on whether this line gets executed
movhi pc,lr		//same as line above except hi means higher than
push {lr}		//Push Link register
mov r2,r0
bl GetGpioAddress	//Function Call

/* New
*  Loop to look at r2 and whether the pin in r2 is greater than 10. 
*  If it is, then it would subtract 10 from it (mod 10) and add 4 to
*  r0 (gpio peripheral address) since each block of 10 pins is represented by
*  4 bytes.
*/
functionLoop$:
cmp r2,#9
subhi r2,#10
addhi r0,#4
bhi functionLoop$

/* New
*  This block has r2 multiplied by 3 since r2 represents the pin number. 
*  Per the spec, each pin is represented by 3 bits..hence 3xpin number
*  So multiply by 3, then shift r1 (pin function) by the corresponding #.
*  Afterward, write to the address regarding the peripheral (gpio addr)
add r2, r2, lsl #1
pinAddr .req r0
pinFunction .req r1
pinNumber .req r2
mask .req r3
temp .req r4

lsl pinFunction,pinNumber	//shift pinFunction by corresponding pinNumber
mov mask,#7				//Set 111 (#7) to mask
lsl mask,pinNumber		//shift mask to desired pin number block
mvn mask,mask			//Create a mask of 111..00011111 where 000 is what we're interested in
adr temp,[pinAddr]		//Copy out current functions of pinNumber
and temp, mask			//Blank out the block of pins we're trying to change
orr temp, pinFunction	//Maintain current functions of pinNumber while setting the GPIO we're interested in
str r1,[pinAddr]
unreq pinAddr
unreq pinNumber
unreq pinMask
pop {pc}

.globl SetGpio
SetGpio:
pinNum .req r0
pinVal .req r1
cmp pinNum,#53
movhi pc,lr		//Branch if pin number is invalid, i.e., pin > 54
push {lr}		//Push lr to stack, i.e., pin less than or equal to 54.
mov r2,pinNum	//Valid pinNum...move to r2
.unreq pinNum

pinNum .req r2	//change pinNum to another register
bl GetGpioAddress	//call GetGpioAddress...get peripheral addr and store to r0
gpioAddr .req r0
pinBank .req r3
lsr pinBank,pinNum,#5	//Divide by 32...i.e., shift 5 to right
lsl pinBank,#2			//On off controlled by only 2 addr of 4 bytes each, hence divide by 32 and then add 4
add gpioAddr,pinBank	//Pin 0-31: 20200000, 32-53: 20200004
.unreq pinBank

/*THis is generate a number with the correct bit set.
* We try to get the remainder of the number after dividing by 32.
* To do this, we get the pinNum and "And" with #31 (32 eqiv in base 10)
* This is will get us the remainder back into pinNum. We then shift the 
* setBit by the pinNum by that much (after dividing by 32)
and pinNum, #31		//#31=0x11111 in binary 
setBit .req r3
mov setBit,#1
lsl setBit,pinNum
.unreq pinNum

/* We turn the pin off if pinVal is zero, turn on otherwise.
teq pinVal,#0		//Test if equal..
.unreq pinVal
streq setBit,[gpioAddr,#40]		//store if equal, i.e., turn off
strne setBit,[gpioAddr,#28]		//store if not equal, i.e., turn on
.unreq setBit
.unreq gpioAddr
pop {pc}

