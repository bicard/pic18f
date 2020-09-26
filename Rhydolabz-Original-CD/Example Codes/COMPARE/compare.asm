
;/* Microchip MPLAB Version 7.4  			   	  */
;/* PIC C - HI-TECH PICC Compiler Version 8.05PL2 */
;
;/*
;*************************************************************************************************
;*    						       COMPARE    													* 
;*    		          																			*
;*************************************************************************************************
;																								*
;*  Description  : Source code TO turn ON LEDs on every COMPARE 
;   LED IS CONNECTED TO PORTB
;*																								*
;*************************************************************************************************
	
	INCLUDE"P18F4520.INC"		;include PIC18F4580 definitions
		ORG 0000H				;reset vector location
		CLRF PCLATH				;clearing program counter higher bits
		GOTO START				;jump to start up location defined at 30H
		ORG 0030H
		
	START						;start of program
		
		BCF TRISC,2				;make portc 2nd pin as o/p
		BCF PORTC,2				;clear RC2 pin
		MOVLW 0X0F;	
		MOVWF ADCON1;			;Set all port pin as digital
		CLRF TRISB				;make PORTB pins as output
		CLRF PORTB				;clear PORTB register
		
		BCF CCP1CON,CCP1M0		;
		BCF CCP1CON,CCP1M1		;
		BCF CCP1CON,CCP1M2		;
		BSF CCP1CON,CCP1M3		;compare mode,set output on match
		MOVLW 0XFF				;
		MOVWF CCPR1L			;values which is to be compared with,
		MOVLW 0X0A				;to create a timer count match
		MOVWF CCPR1H			; 
		BCF T1CON,T1CKPS0		;
		BCF T1CON,T1CKPS1		;prescale set to 1:1 timer rate
		BCF T1CON,TMR1CS		;timer internal clock (Fosc/4)			
		BSF T1CON,TMR1ON		;start timer
		
		BTFSS PORTC,2			;check RC2 pin HIGH
		GOTO $-1				;
		MOVLW 0XFF				;turn ON the LEDs on compare match
		MOVWF PORTB				;
	
		GOTO $					;wait for the match to occur			
        
        END						;end of program

		
		
		
		
		
		
		
