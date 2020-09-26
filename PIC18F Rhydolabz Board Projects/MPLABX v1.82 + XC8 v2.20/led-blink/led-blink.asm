
;/* Microchip MPLAB Version 7.4  			   	  */
;/* PIC C - HI-TECH PICC Compiler Version 8.05PL2 */
;
;/*
;*************************************************************************************************
;*    						       LED    										 					*
;*    		          																			 *
;*************************************************************************************************
;																								*
;*  Description  : Source code TO BLINK LED CONNECTED TO PORTB *
;
;*																								*
;*************************************************************************************************



			   ON equ 0xff		;equating value 0xff to ON
			  OFF equ 0x00		;equating value 0x00 to OFF
			dCnt1 equ 30H		;label 30H address as dCnt1
			dCnt2 equ 31H		;label 31H address as dCnt2

		INCLUDE"P18F4520.INC"	;include PIC18F4580 definitions
			ORG 0000H			;reset vector location
			CLRF PCLATH			;clearing program counter higher bits
			GOTO START			;jump to start up location defined at 30H
			ORG 0030H

	START						;start of program

			CLRF TRISB			;PORTB pins configured as output

	AGAIN
			MOVLW ON			;make all PORTB pins high
			MOVWF PORTB			;all LEDs in ON state
			CALL DELAY			;delay
			CALL DELAY			;delay
			MOVLW OFF			;make all PORTB pins low
			MOVWF PORTB			;all LEDs in OFF state
			CALL DELAY			;delay
			CALL DELAY			;delay
			GOTO AGAIN			;do it again

	DELAY						;delay sub-routine
			MOVLW 0XFF
			MOVWF dCnt1			;load dCnt1 with 0xff
		D2	MOVWF dCnt2			;load dCnt2 with 0xff
		D1	DECFSZ dCnt2,1		;decrement dCnt2 and skip if zero
			GOTO D1				;jump to label D1
			DECFSZ dCnt1,1		;decrement dCnt1 and skip if zero
			GOTO D2				;jump to label D2
			RETURN				;return from delay sub-routine

			END					;end of program




