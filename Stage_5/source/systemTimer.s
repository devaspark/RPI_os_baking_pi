/******************************************************************************
*	systemTimer.s
*	 by Rex Kung
*
*	Creating a system Timer function on Raspberry Pi
*	Changes since stage_3 are marked with NEW.
******************************************************************************/

/* New
* This is suppose to get the Timer address and return it via r0
* Remember .globl is needed to make the function accessible from other files.
*/
.globl GetSystemTimerBase
GetSystemTimerBase:
ldr r0,=0x20003000  //This is the address for the GPIO per spec
mov pc,lr

/* New
* Get the time stamp from the system timer and return as r0 & r1
*/
.globl GetTimeStamp
GetTimeStamp:
push {lr}
bl GetSystemTimerBase
ldrd r0,r1, [r0,#4]
pop {pc}

/* New
* Main delay code, accepts r0 as the delay value, gets start time and
* subtracts current time from the start time to get the elapse time.
* After elapse time is greater than the delay time, it ends the function.
*/
.globl waitTime
waitTime:
delay .req r2
mov delay, r0	//Move input of delay time to r2
push {lr}
bl GetTimeStamp
start .req r3
mov start, r0	//Move r0 (timer tail) to start (r3)

loop$:
bl GetTimeStamp
elapse .req r1
sub elapse, r0, start
cmp elapse, delay
.unreq elapse
bls loop$
.unreq delay
.unreq start
pop {pc} 
