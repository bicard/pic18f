
;/* Microchip MPLAB Version 7.4  			   	  */
;/* PIC C - HI-TECH PICC Compiler Version 8.05PL2 */
;
;/*
;*************************************************************************************************
;*    						       PULLUP KEY BOARD    										 * 
;*    		          																			 *
;*************************************************************************************************
;

;*************************************************************************************************
;																								 * 
;*  Description  : Source code TO TRANSMIT THE PULLUP KEYBORD ENTRY USING USART					     *
;   (PRESS THE KEY BOARD AFTER CONNECTING THE BOARD TO THE COMPUTER USING SERIAL CABLE
;               OPEN THE HYPER-TERMINAL WITH REQUIRED BAUDRATE
;   			(RESULT WILL BE SHOWED IN THE HYPER-TERMINAL )
;*																								*
;*************************************************************************************************

dCnt1 equ 31H		;label 30H address as dCnt1
dCnt2 equ 32H		;label 31H address as dCnt2
TEMP equ 33H		;label 30H address location as TEMP

		INCLUDE"P18F4520.INC"	;include PIC18F4580 definitions
		ORG 0000H			;reset vector location
		CLRF PCLATH			;clearing program counter higher bits
		GOTO START			;jump to start up location defined at 30H
		ORG 0030H
		
START						;start of program

  	   ;------PULL-UP KEY & TXD CONFIGURATION-------;
	   MOVLW 0X0F
	   MOVWF TRISC			;pull up keys connected : pin<0> to pin<3>(configured as input)
	   						;pin<6> : transmission pin (configured as o/p) 
	   						
	   ;---------USART INITIALISATION--------;	
	   
		BSF TXSTA,BRGH		; select high speed baud-rate(9600)
							
		; value loaded corresponding to baud-rate,9600
		MOVLW 0x81
		MOVWF SPBRG		
		BCF TXSTA,SYNC		; asynchronous mode select
		BSF TXSTA,TXEN		; 8-bit transmission enable
		BSF RCSTA,SPEN		; serial port enable	 

	   
	   ;----------SCAN FOR KEY PRESS-----------;		
CONT_SCAN:
		CALL DELAY				;delay for a key press to be detected
		MOVF PORTC,0			;
		ANDLW 0X0F				;read PORTC i/p pin status 
		MOVWF TEMP				;and store the status to a temprary location TEMP
		SUBLW 0X0F				;and PORTC i/p pin status is checked
		BTFSS STATUS,Z			;check for key press	
		GOTO   KEY_SCN			;skip for continuous key scan if no key press detected
	    GOTO CONT_SCAN			;go for continuous key scan
KEY_SCN	CALL KEYCHECK			;individual key scan and response to key press
		
		;--------ACKNOWLEDGE A KEY PRESS-------;
		MOVWF TXREG				;transmit respec. ASCII for a key press		
		BTFSS TXSTA,TRMT		;wait for transmion, skip if complete
		GOTO $-1
		CALL DELAY			
		CALL DELAY				;delay for a key-debounce
		GOTO CONT_SCAN			;go for continuous key scan
		
		;-----INDIVIDUAL KEY SCAN & ACKNOWLEDGE WITH ASCIIs-----;
KEYCHECK:
		MOVF TEMP,0
		SUBLW 0X07
		BTFSC STATUS,Z			;ASCII set for PORTC pin<3> key stoke is 'D'
		RETLW 'D'				;ASCII code loaded to working register & return
		MOVF TEMP,0
		SUBLW 0X0B
		BTFSC STATUS,Z			;ASCII set for PORTC pin<3> key stoke is 'C'
		RETLW 'C'				;ASCII code loaded to working register & return
		MOVF TEMP,0
		SUBLW 0X0D
		BTFSC STATUS,Z			;ASCII set for PORTC pin<3> key stoke is 'B'
		RETLW 'B'				;ASCII code loaded to working register & return
		MOVF TEMP,0
		SUBLW 0X0E
		BTFSC STATUS,Z			;ASCII set for PORTC pin<3> key stoke is 'A'
		RETLW 'A'				;ASCII code loaded to working register & return
		RETURN
		
		;------------DELAY SUBROUTINE----------;	
DELAY							;delay sub-routine
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
						
			END						;end of program


