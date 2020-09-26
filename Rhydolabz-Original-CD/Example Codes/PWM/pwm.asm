	
;/* Microchip MPLAB Version 7.4  			   	  */
;/* PIC C - HI-TECH PICC Compiler Version 8.05PL2 */
;
;/*
;*************************************************************************************************
;*    						       PWM    													* 
;*    		          																			*
;*************************************************************************************************
;																								*
;*  Description  : Source code TO generate a pulse with duty cycle 50% 
;   
;*																								*
;*************************************************************************************************


		INCLUDE"P18F4520.INC"		;include PIC18F4580 definitions
		ORG 0000H				;reset vector location
		CLRF PCLATH				;clearing program counter higher bits
		GOTO START				;jump to start up location defined at 30H
		ORG 0030H
		
	START						;start of program	
		
		BCF TRISC,2				;make PORTC 2nd pin as o/p		
	
		BCF CCP1CON,CCP1M0
		BCF CCP1CON,CCP1M1
		BSF CCP1CON,CCP1M2
		BSF CCP1CON,CCP1M3		;switch to pwm mode
		CLRF TMR2				;clear timer2 register,start value
		BCF T2CON,T2CKPS0
		BCF T2CON,T2CKPS1		;set to 1:1 timer2 prescale rate
		BSF T2CON,TMR2ON		;start timer
		MOVLW D'39'
		MOVWF PR2				;loading timer2 overflow value
		MOVLW D'20'
		MOVWF CCPR1L			;load timer duty cycle value 
		GOTO $
		END
		
		
