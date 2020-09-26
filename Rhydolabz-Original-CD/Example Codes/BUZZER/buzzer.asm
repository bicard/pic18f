
;/* Microchip MPLAB Version 7.4  			   	  */
;/* PIC C - HI-TECH PICC Compiler Version 8.05PL2 */
;
;/*
;*************************************************************************************************
;*    						            BUZZER    										         * 
;*    		          																		     *
;*************************************************************************************************
;																								 *
;*  Description  : Source code TO SWITCH ON AND OFF BUZZER ALTERNATIVELY						 *
;*																								 *
;*************************************************************************************************
		
			dCnt1 equ 30H		;label 30H address as dCnt1
			dCnt2 equ 31H		;label 31H address as dCnt2
	
		INCLUDE"P18F4520.INC"	;include PIC18F4580 definitions
			ORG 0000H			;reset vector location
			CLRF PCLATH			;clearing program counter higher bits
			GOTO START			;jump to start up location defined at 30H
			ORG 0030H			
			
		START					;start of program	  				
			MOVLW 0X0F
			MOVWF ADCON1
			MOVLW 0X00
			MOVWF TRISE			;make PORTE 0th pin as o/p for buzzer input
		;	MOVLW 0X0A			;
		;	MOVWF ADCON1		;make RE0 as digital pin
			
		AGAIN	
			CALL DELAY 			;delay
		    CALL DELAY 			;delay
			BSF PORTE,0			;set for buzzer beep
			CALL DELAY 			;delay
			CALL DELAY 			;delay
			BCF PORTE,0			;set for buzzer off			
			GOTO AGAIN			;infinite wait
			
		DELAY					;delay sub-routine
			MOVLW 0XFF
			MOVWF dCnt1			;load 0xff to dCnt1
		D2
			MOVWF dCnt2			;load 0xff to dCnt2
		D1
			DECFSZ dCnt2,1		;decrement dCnt2 and skip if zero
			GOTO D1				;jump to label D1
			DECFSZ dCnt1,1		;decrement dCnt1 and skip if zero
			GOTO D2				;jump to label D2
			RETURN				;return from delay sub-routine
			
			END					;end of program
			
		
