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
 *
 * vMain() is effectively the demo application entry point.  It is called by
 * the main() function generated by the Processor Expert application.  
 *
 * vMain() creates all the demo application tasks, then starts the scheduler.
 * The WEB	documentation provides more details of the demo application tasks.
 *
 * Main.c also creates a task called "Check".  This only executes every three 
 * seconds but has the highest priority so is guaranteed to get processor time.  
 * Its main function is to check that all the other tasks are still operational.
 * Each task (other than the "flash" tasks) maintains a unique count that is 
 * incremented each time the task successfully completes its function.  Should 
 * any error occur within such a task the count is permanently halted.  The 
 * check task inspects the count of each task to ensure it has changed since
 * the last time the check task executed.  If all the count variables have 
 * changed all the tasks are still executing error free, and the check task
 * toggles the onboard LED.  Should any task contain an error at any time 
 * the LED toggle rate will change from 3 seconds to 500ms.
 *
 * This file also includes the functionality normally implemented within the 
 * standard demo application file integer.c.  Due to the limited memory 
 * available on the microcontroller the functionality has been included within
 * the idle task hook [vApplicationIdleHook()] - instead of within the usual
 * separate task.  See the documentation within integer.c for the rationale 
 * of the integer task functionality.
 *
 *
 * 
 * The demo applications included with other FreeRTOS ports make use of the
 * standard ComTest tasks.  These use a loopback connector to transmit and
 * receive RS232 characters between two tasks.  The test is important for two
 * reasons:
 *
 *	1) It tests the mechanism of context switching from within an application
 *	   ISR.
 *
 *	2) It generates some randomised timing.
 *
 * The demo board used to develop this port does not include an RS232 interface
 * so the ComTest tasks could not easily be included.  Instead these two tests
 * are created using a 'Button Push' task.  
 * 
 * The 'Button Push' task blocks on a queue, waiting for data to arrive.  A
 * simple interrupt routine connected to the PP0 input on the demo board places
 * data in the queue each time the PP0 button is pushed (this button is built 
 * onto the demo board).  As the 'Button Push' task is created with a 
 * relatively high priority it will unblock and want to execute as soon as data
 * arrives in the queue - resulting in a context switch within the PP0 input
 * ISR.  If the data retrieved from the queue is that expected the 'Button Push'
 * task toggles LED 5.  Therefore correct operation is indicated by the LED
 * toggling each time the PP0 button is pressed.
 *
 * This test is not as satisfactory as the ComTest method - but the simple 
 * nature of the port makes is just about adequate.
 * 
 */

/* Kernel includes. */
#include "FreeRTOS.h"
#include "task.h"
#include "queue.h"

/* Demo application includes. */
#include "flash.h"
#include "PollQ.h"
#include "dynamic.h"
#include "partest.h"

/* Processor expert includes. */
#include "ButtonInterrupt.h"

/*-----------------------------------------------------------
	Definitions.
-----------------------------------------------------------*/

/* Priorities assigned to demo application tasks. */
#define mainFLASH_PRIORITY			( tskIDLE_PRIORITY + 2 )
#define mainCHECK_TASK_PRIORITY		( tskIDLE_PRIORITY + 3 )
#define mainBUTTON_TASK_PRIORITY	( tskIDLE_PRIORITY + 3 )
#define mainQUEUE_POLL_PRIORITY		( tskIDLE_PRIORITY + 2 )

/* LED that is toggled by the check task.  The check task periodically checks
that all the other tasks are operating without error.  If no errors are found
the LED is toggled with mainCHECK_PERIOD frequency.  If an error is found 
then the toggle rate increases to mainERROR_CHECK_PERIOD. */
#define mainCHECK_TASK_LED			( 7 )
#define mainCHECK_PERIOD			( ( TickType_t ) 3000 / portTICK_PERIOD_MS  )
#define mainERROR_CHECK_PERIOD		( ( TickType_t ) 500 / portTICK_PERIOD_MS )

/* LED that is toggled by the button push interrupt. */
#define mainBUTTON_PUSH_LED			( 5 )

/* The constants used in the idle task calculation. */
#define intgCONST1				( ( long ) 123 )
#define intgCONST2				( ( long ) 234567 )
#define intgCONST3				( ( long ) -3 )
#define intgCONST4				( ( long ) 7 )
#define intgEXPECTED_ANSWER		( ( ( intgCONST1 + intgCONST2 ) * intgCONST3 ) / intgCONST4 )

/* The length of the queue between is button push ISR and the Button Push task
is greater than 1 to account for switch bounces generating multiple inputs. */
#define mainBUTTON_QUEUE_SIZE 6

/*-----------------------------------------------------------
	Local functions prototypes.
-----------------------------------------------------------*/

/*
 * The 'Check' task function.  See the explanation at the top of the file.
 */
static void vErrorChecks( void* pvParameters );

/*
 * The 'Button Push' task.  See the explanation at the top of the file.
 */
static void vButtonTask( void *pvParameters );

/*
 * The idle task hook - in which the integer task is implemented.  See the
 * explanation at the top of the file.
 */
void vApplicationIdleHook( void );

/*
 * Checks the unique counts of other tasks to ensure they are still operational.
 */
static long prvCheckOtherTasksAreStillRunning( void );



/*-----------------------------------------------------------
	Local variables.
-----------------------------------------------------------*/

/* A few tasks are defined within this file.  This flag is used to indicate
their status.  If an error is detected in one of the locally defined tasks then
this flag is set to pdTRUE. */
portBASE_TYPE xLocalError = pdFALSE;

/* The queue used to send data from the button push ISR to the Button Push 
task. */
static QueueHandle_t xButtonQueue;


/*-----------------------------------------------------------*/

/* 
 * This is called from the main() function generated by the Processor Expert.
 */
void vMain( void )
{
	/* Start some of the standard demo tasks. */
	vStartLEDFlashTasks( mainFLASH_PRIORITY );
	vStartPolledQueueTasks( mainQUEUE_POLL_PRIORITY );
	vStartDynamicPriorityTasks();
	
	/* Start the locally defined tasks.  There is also a task implemented as
	the idle hook. */
	xTaskCreate( vErrorChecks, "Check", configMINIMAL_STACK_SIZE, NULL, mainCHECK_TASK_PRIORITY, NULL );
	xTaskCreate( vButtonTask, "Button", configMINIMAL_STACK_SIZE, NULL, mainBUTTON_TASK_PRIORITY, NULL );
	
	/* All the tasks have been created - start the scheduler. */
	vTaskStartScheduler();
	
	/* Should not reach here! */
	for( ;; );
}
/*-----------------------------------------------------------*/

static void vErrorChecks( void *pvParameters )
{
TickType_t xDelayPeriod = mainCHECK_PERIOD;
TickType_t xLastWakeTime;

	/* Initialise xLastWakeTime to ensure the first call to vTaskDelayUntil()
	functions correctly. */
	xLastWakeTime = xTaskGetTickCount();

	for( ;; )
	{
		/* Delay until it is time to execute again.  The delay period is 
		shorter following an error. */
		vTaskDelayUntil( &xLastWakeTime, xDelayPeriod );

		/* Check all the demo application tasks are executing without 
		error. If an error is found the delay period is shortened - this
		has the effect of increasing the flash rate of the 'check' task
		LED. */
		if( prvCheckOtherTasksAreStillRunning() == pdFAIL )
		{
			/* An error has been detected in one of the tasks - flash faster. */
			xDelayPeriod = mainERROR_CHECK_PERIOD;
		}

		/* Toggle the LED each cycle round. */
		vParTestToggleLED( mainCHECK_TASK_LED );
	}
}
/*-----------------------------------------------------------*/

static long prvCheckOtherTasksAreStillRunning( void )
{
portBASE_TYPE xAllTasksPassed = pdPASS;

	if( xArePollingQueuesStillRunning() != pdTRUE )
	{
		xAllTasksPassed = pdFAIL;
	}

	if( xAreDynamicPriorityTasksStillRunning() != pdTRUE )
	{
		xAllTasksPassed = pdFAIL;
	}

	/* Also check the status flag for the tasks defined within this function. */
	if( xLocalError != pdFALSE )
	{
		xAllTasksPassed = pdFAIL;
	}

	return xAllTasksPassed;
}
/*-----------------------------------------------------------*/

void vApplicationIdleHook( void )
{
/* This variable is effectively set to a constant so it is made volatile to
ensure the compiler does not just get rid of it. */
volatile long lValue;

	/* Keep performing a calculation and checking the result against a constant. */
	for( ;; )
	{
		/* Perform the calculation.  This will store partial value in
		registers, resulting in a good test of the context switch mechanism. */
		lValue = intgCONST1;
		lValue += intgCONST2;
		lValue *= intgCONST3;
		lValue /= intgCONST4;

		/* Did we perform the calculation correctly with no corruption? */
		if( lValue != intgEXPECTED_ANSWER )
		{
			/* Error! */
			portENTER_CRITICAL();
				xLocalError = pdTRUE;
			portEXIT_CRITICAL();
		}

		/* Yield in case cooperative scheduling is being used. */
		#if configUSE_PREEMPTION == 0
		{
			taskYIELD();
		}
		#endif		
	}
}
/*-----------------------------------------------------------*/

static void vButtonTask( void *pvParameters )
{
unsigned portBASE_TYPE uxExpected = 1, uxReceived;

	/* Create the queue used by the producer and consumer. */
	xButtonQueue = xQueueCreate( mainBUTTON_QUEUE_SIZE, ( unsigned portBASE_TYPE ) sizeof( unsigned portBASE_TYPE ) );

	if( xButtonQueue )
	{
		/* Now the queue is created it is safe to enable the button interrupt. */
		ButtonInterrupt_Enable();
	
		for( ;; )
		{
			/* Simply wait for data to arrive from the button push interrupt. */
			if( xQueueReceive( xButtonQueue, &uxReceived, portMAX_DELAY ) == pdPASS )	
			{
				/* Was the data we received that expected? */
				if( uxReceived != uxExpected )
				{
					/* Error! */
					portENTER_CRITICAL();
						xLocalError = pdTRUE;
					portEXIT_CRITICAL();				
				}
				else
				{
					/* Toggle the LED for every successful push. */
					vParTestToggleLED( mainBUTTON_PUSH_LED );	
				}
				
				uxExpected++;
			}
		}
	}
	
	/* Will only get here if the queue could not be created. */
	for( ;; );		
}
/*-----------------------------------------------------------*/

#pragma CODE_SEG __NEAR_SEG NON_BANKED

	/* Button push ISR. */
	void interrupt vButtonPush( void )
	{
		static unsigned portBASE_TYPE uxValToSend = 0;
		static unsigned long xHigherPriorityTaskWoken;

		xHigherPriorityTaskWoken = pdFALSE;
		
		/* Send an incrementing value to the button push task each run. */
		uxValToSend++;		

		/* Clear the interrupt flag. */
		PIFP = 1;

		/* Send the incremented value down the queue.  The button push task is
		blocked waiting for the data.  As the button push task is high priority
		it will wake and a context switch should be performed before leaving
		the ISR. */
		xQueueSendFromISR( xButtonQueue, &uxValToSend, &xHigherPriorityTaskWoken );

		if( xHigherPriorityTaskWoken )
		{
			/* NOTE: This macro can only be used if there are no local
			variables defined.  This function uses a static variable so it's
			use is permitted.  If the variable were not static portYIELD() 
			would have to be used in it's place. */
			portTASK_SWITCH_FROM_ISR();
		}		
	}

#pragma CODE_SEG DEFAULT


