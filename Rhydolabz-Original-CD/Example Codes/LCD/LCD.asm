

;/* Microchip MPLAB Version 7.4  			   	  */
;/* PIC C - HI-TECH PICC Compiler Version 8.05PL2 */
;
;/*
;*************************************************************************************************
;*    						     				  LCD    										 * 
;*    		          																			 *
;*************************************************************************************************
;																								*
;*  Description  : Source code TO DISPLAY HELLO IN LCD  *
;   
;*																								*
;*************************************************************************************************
	

dCnt1 equ 30H		;label 30H address as dCnt1
dCnt2 equ 31H		;label 31H address as dCnt2			
			INCLUDE"P18F4520.INC"	;PIC18F4580 definitions
			ORG 0000H			;reset vector location
			CLRF PCLATH			;clearing program counter higher bits
			GOTO START			;jumping to start up location defined at 30H
			ORG 0030H
		
START							;start of program		
		  	CLRF TRISC			;set PORTC pins as output
			CLRF TRISD			;set PORTD pins as output	
			;LCD initialization		
			CALL DELAY15MS					 
			MOVLW H'30'			;8-bit single line display selection
			CALL COMMAND		;call command sub-routine
			CALL DELAY5MS
			MOVLW H'30'			;8-bit single line display selection
			CALL COMMAND		;call command sub-routine
			CALL DELAY100MICRO
			MOVLW H'30'			;8-bit single line display selection
			CALL COMMAND		;call command sub-routine
			MOVLW H'38'			;8-bit double line display selection
			CALL COMMAND		;call command sub-routine
			MOVLW H'01'			;clear display
			CALL COMMAND
			MOVLW H'06'			;auto-address increment
			CALL COMMAND
			MOVLW H'0C'			;display on cursor off
			CALL COMMAND
			;LCD display - HELLO
		
			MOVLW 'H'			;ASCII form of data for display
			CALL DISPLAY		;call data sub-routine
			MOVLW 'E'
			CALL DISPLAY
			MOVLW 'L'
			CALL DISPLAY
			MOVLW 'L'
			CALL DISPLAY
			MOVLW 'O'
			CALL DISPLAY 		
			GOTO $				;infinite halt
			
COMMAND 						;command sub-routine
			MOVWF PORTD			;move command to LCD port
			BCF PORTC,1			;command register select
			BCF PORTC,0			;register write select
			BSF PORTC,5			;enable ie,H->L 		
			CALL DELAY5MS			;delay for write
			BCF PORTC,5			
			RETURN				;return from command sub-routine
		
DISPLAY							;display sub-routine
			MOVWF PORTD			;move data to LCD port
			BSF PORTC,1			;data register select
			BCF PORTC,0			;register write select
			BSF PORTC,5		;enable ie,H->L 
			CALL DELAY5MS			;delay for write
			BCF PORTC,5		;return from command sub-routine
			RETURN
	
DELAY100MICRO							;delay sub-routine for 100 microsecond
			MOVLW 0X01
			MOVWF dCnt1			;load 0xff to dCnt1
D2
			MOVLW 0XFF
			MOVWF dCnt2			;load 0xff to dCnt2
D1
			DECFSZ dCnt2,1		;decrement dCnt2 and skip if zero
			GOTO D1				;jump to label D1
			DECFSZ dCnt1,1		;decrement dCnt1 and skip if zero
			GOTO D2				;jump to label D2
			RETURN				;return from delay sub-routine
			
DELAY15MS							;delay sub-routine for 15 MilliSecond 
			MOVLW 0X60
			MOVWF dCnt1			;load 0xff to dCnt1
D4
			MOVLW 0XFF
			MOVWF dCnt2			;load 0xff to dCnt2
D3
			DECFSZ dCnt2,1		;decrement dCnt2 and skip if zero
			GOTO D3				;jump to label D1
			DECFSZ dCnt1,1		;decrement dCnt1 and skip if zero
			GOTO D4				;jump to label D2
			RETURN				;return from delay sub-routine
			
DELAY5MS							;delay sub-routine for 5 millisecond
			MOVLW 0X20
			MOVWF dCnt1			;load 0xff to dCnt1
D6
			MOVLW 0XFF
			MOVWF dCnt2			;load 0xff to dCnt2
D5
			DECFSZ dCnt2,1		;decrement dCnt2 and skip if zero
			GOTO D5				;jump to label D1
			DECFSZ dCnt1,1		;decrement dCnt1 and skip if zero
			GOTO D6				;jump to label D2
			RETURN				;return from delay sub-routine
			
			END					;end of program
