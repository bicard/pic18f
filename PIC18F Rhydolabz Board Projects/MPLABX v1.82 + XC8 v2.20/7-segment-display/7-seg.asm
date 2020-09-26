;/* Microchip MPLAB Version 7.4  			   	  */
;/* PIC C - HI-TECH PICC Compiler Version 8.05PL2 */
;
;/*
;*************************************************************************************************
;*    						       7-SEGMENT DISPLAY    										*
;*    		          																			*
;*************************************************************************************************
;																								*
;*  Description  : Source code TO DISPLAY 1 2 3 4 IN  7-SEGMENT DISPLAY							*
;*																								*
;*************************************************************************************************



			dCnt1 equ 30H			;label 30H address as dCnt1
			dCnt2 equ 31H			;label 31H address as dCnt2

			INCLUDE"P18F4520.INC"		;include PIC18F4580 definitions
			ORG 0000H				;reset vector location
			CLRF PCLATH				;clearing program counter higher bits
			GOTO START				;jump to start up location defined at30H
			ORG 0030H

START								;start of program

			MOVLW 0XF0
			MOVWF TRISA				;make PORTA (0-3 pins) as o/p for module select
			CLRF TRISD 				;make PORTD as o/p pins for individual segment display
			MOVLW 0X0F				;
			MOVWF ADCON2			;make all PORTA pins digital

AGAIN
			BSF PORTA,3				;selects 1st module from right
			MOVLW 0X2D				;value to be loaded for displaying 4
			MOVWF PORTD				;in the module segments
			CALL DELAY				;delay for approximate 2.4ms

			BSF PORTA,2				;selects 2nd module from right
			MOVLW 0X6B
			MOVWF PORTD				;displays - 3
			CALL DELAY

			BSF PORTA,1				;selects 2nd module from left
			MOVLW 0XDB
			MOVWF PORTD				;displays - 2.
			CALL DELAY

			BSF PORTA,0				;selects 1st module from left
			MOVLW 0X21
			MOVWF PORTD				;displays - 1
			CALL DELAY

			GOTO AGAIN				;do it again

DELAY								;delay sub-routine
				MOVLW 0X0F
				MOVWF dCnt1			;load 0x0f to dCnt1
D2
				MOVWF dCnt2			;load 0x0f to dCnt2
D1
				DECFSZ dCnt2,1		;decrement dCnt2 and skip if zero
				GOTO D1				;jump to label D1
				DECFSZ dCnt1,1		;decrement dCnt1 and skip if zero
				GOTO D2				;jump to label D2
				RETURN				;return from delay sub-routine

				END					;end of program





