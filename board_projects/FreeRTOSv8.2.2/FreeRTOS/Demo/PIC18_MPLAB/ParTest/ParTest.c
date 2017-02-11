/*
    FreeRTOS V8.2.2 - Copyright (C) 2015 Real Time Engineers Ltd.
    All rights reserved

    VISIT http://www.FreeRTOS.org TO ENSURE YOU ARE USING THE LATEST VERSION.

    This file is part of the FreeRTOS distribution.

    FreeRTOS is free software; you can redistribute it and/or modify it under
    the terms of the GNU General Public License (version 2) as published by the
    Free Software Foundation >>!AND MODIFIED BY!<< the FreeRTOS exception.

    ***************************************************************************
    >>!   NOTE: The modification to the GPL is included to allow you to     !<<
    >>!   distribute a combined work that includes FreeRTOS without being   !<<
    >>!   obliged to provide the source code for proprietary components     !<<
    >>!   outside of the FreeRTOS kernel.                                   !<<
    ***************************************************************************

    FreeRTOS is distributed in the hope that it will be useful, but WITHOUT ANY
    WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
    FOR A PARTICULAR PURPOSE.  Full license text is available on the following
    link: http://www.freertos.org/a00114.html

    ***************************************************************************
     *                                                                       *
     *    FreeRTOS provides completely free yet professionally developed,    *
     *    robust, strictly quality controlled, supported, and cross          *
     *    platform software that is more than just the market leader, it     *
     *    is the industry's de facto standard.                               *
     *                                                                       *
     *    Help yourself get started quickly while simultaneously helping     *
     *    to support the FreeRTOS project by purchasing a FreeRTOS           *
     *    tutorial book, reference manual, or both:                          *
     *    http://www.FreeRTOS.org/Documentation                              *
     *                                                                       *
    ***************************************************************************

    http://www.FreeRTOS.org/FAQHelp.html - Having a problem?  Start by reading
    the FAQ page "My application does not run, what could be wrong?".  Have you
    defined configASSERT()?

    http://www.FreeRTOS.org/support - In return for receiving this top quality
    embedded software for free we request you assist our global community by
    participating in the support forum.

    http://www.FreeRTOS.org/training - Investing in training allows your team to
    be as productive as possible as early as possible.  Now you can receive
    FreeRTOS training directly from Richard Barry, CEO of Real Time Engineers
    Ltd, and the world's leading authority on the world's leading RTOS.

    http://www.FreeRTOS.org/plus - A selection of FreeRTOS ecosystem products,
    including FreeRTOS+Trace - an indispensable productivity tool, a DOS
    compatible FAT file system, and our tiny thread aware UDP/IP stack.

    http://www.FreeRTOS.org/labs - Where new FreeRTOS products go to incubate.
    Come and try FreeRTOS+TCP, our new open source TCP/IP stack for FreeRTOS.

    http://www.OpenRTOS.com - Real Time Engineers ltd. license FreeRTOS to High
    Integrity Systems ltd. to sell under the OpenRTOS brand.  Low cost OpenRTOS
    licenses offer ticketed support, indemnification and commercial middleware.

    http://www.SafeRTOS.com - High Integrity Systems also provide a safety
    engineered and independently SIL3 certified version for use in safety and
    mission critical applications that require provable dependability.

    1 tab == 4 spaces!
*/

/* 
Changes from V2.0.0

	+ Use scheduler suspends in place of critical sections.
*/

#include "FreeRTOS.h"
#include "task.h"
#include "partest.h"

/*-----------------------------------------------------------
 * Simple parallel port IO routines for the FED 40pin demo board.
 * The four LED's are connected to D4 to D7.
 *-----------------------------------------------------------*/

#define partstBIT_AS_OUTPUT			( ( unsigned short ) 0 )
#define partstSET_OUTPUT			( ( unsigned short ) 1 )
#define partstCLEAR_OUTPUT			( ( unsigned short ) 0 )

#define partstENABLE_GENERAL_IO		( ( unsigned char ) 7 )

/*-----------------------------------------------------------*/

void vParTestInitialise( void )
{
	/* Set the top four bits of port D to output. */
	TRISBbits.TRISB7 = partstBIT_AS_OUTPUT;
	TRISBbits.TRISB6 = partstBIT_AS_OUTPUT;
	TRISBbits.TRISB5 = partstBIT_AS_OUTPUT;
	TRISBbits.TRISB4 = partstBIT_AS_OUTPUT;
    TRISBbits.TRISB3 = partstBIT_AS_OUTPUT;
	TRISBbits.TRISB2 = partstBIT_AS_OUTPUT;
	TRISBbits.TRISB1 = partstBIT_AS_OUTPUT;
	TRISBbits.TRISB0 = partstBIT_AS_OUTPUT;

	/* Start with all bits off. */
	PORTBbits.RB7 = partstCLEAR_OUTPUT;
	PORTBbits.RB6 = partstCLEAR_OUTPUT;
	PORTBbits.RB5 = partstCLEAR_OUTPUT;
	PORTBbits.RB4 = partstCLEAR_OUTPUT;
	PORTBbits.RB3 = partstCLEAR_OUTPUT;
    PORTBbits.RB2 = partstCLEAR_OUTPUT;
    PORTBbits.RB1 = partstCLEAR_OUTPUT;
    PORTBbits.RB0 = partstCLEAR_OUTPUT;

	/* Enable the driver. */
	ADCON1 = partstENABLE_GENERAL_IO;
	TRISEbits.TRISE2 = partstBIT_AS_OUTPUT;
	PORTEbits.RE2 = partstSET_OUTPUT;	
}
/*-----------------------------------------------------------*/

void vParTestSetLED( unsigned portBASE_TYPE uxLED, portBASE_TYPE xValue )
{
	/* We are only using the top nibble, so LED 0 corresponds to bit 4. */	
	vTaskSuspendAll();
	{
		switch( uxLED )
		{
			case 3	:	PORTBbits.RB7 = ( short ) xValue;
						break;
			case 2	:	PORTBbits.RB6 = ( short ) xValue;
						break;
			case 1	:	PORTBbits.RB5 = ( short ) xValue;
						break;
			case 0	:	PORTBbits.RB4 = ( short ) xValue;
						break;
			default	:	/* There are only 4 LED's. */
						break;
		}
	}
	xTaskResumeAll();
}
/*-----------------------------------------------------------*/

void vParTestToggleLED( unsigned portBASE_TYPE uxLED )
{
	/* We are only using the top nibble, so LED 0 corresponds to bit 4. */	
	vTaskSuspendAll();
	{
#if 0
		switch( uxLED )
		{
			case 3	:	PORTBbits.RB7 = !( PORTBbits.RB7 );
						break;
			case 2	:	PORTBbits.RB6 = !( PORTBbits.RB6 );
						break;
			case 1	:	PORTBbits.RB5 = !( PORTBbits.RB5 );
						break;
			case 0	:	PORTBbits.RB4 = !( PORTBbits.RB4 );
						break;
			default	:	/* There are only 4 LED's. */
						break;
	    }   
#else
PORTBbits.RB0 = !( PORTBbits.RB0 );
PORTBbits.RB1 = !( PORTBbits.RB1 );
PORTBbits.RB2 = !( PORTBbits.RB2 );
PORTBbits.RB3 = !( PORTBbits.RB3 );
PORTBbits.RB4 = !( PORTBbits.RB4 );
PORTBbits.RB5 = !( PORTBbits.RB5 );
PORTBbits.RB6 = !( PORTBbits.RB6 );
PORTBbits.RB7 = !( PORTBbits.RB7 );
#endif
	}
	xTaskResumeAll();
}



