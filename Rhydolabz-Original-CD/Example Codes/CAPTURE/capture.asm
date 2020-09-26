
;/* Microchip MPLAB Version 7.4  			   	  */
;/* PIC C - HI-TECH PICC Compiler Version 8.05PL2 */
;
;/*
;*************************************************************************************************
;*    						       CAPTURE    										* 
;*    		          																			*
;*************************************************************************************************
;																								*
;*  Description  : Source code TO compliment the status of LEDs on every capture
;   LED IS CONNECTED TO PORTB
;	PROVIDE A LOW VOLTAGE at PIN RC2(CONNECT RC2 TO GROUND PIN THROUGH A WIRE TO MAKE A CAPTURE)
;*																								*
;*************************************************************************************************
		
		INCLUDE"P18F4520.INC"		;include PIC18F4580 definitions
		ORG 0000H				;reset vector location
		CLRF PCLATH				;clearing program counter higher bits
		GOTO START				;jump to start up location defined at 30H
		ORG 0030H
		
START							;start of program
	  	MOVLW 0X0F
		MOVWF ADCON1			;Set  port pin as digital
	  	CLRF TRISB				;make PORTB pins as output pins
		BSF TRISC,2				;make portc 2nd pin as input
		BSF INTCON,GIE			;global interrupt enable
		BSF INTCON,PEIE			;peripheral  interrupt enable
		BSF PIE1,CCP1IE			;CCP1 interrupt enable,capture
		BCF CCP1CON,CCP1M0
		BCF CCP1CON,CCP1M1
		BSF CCP1CON,CCP1M2
		BCF CCP1CON,CCP1M3		;capture mode,every falling edge
		SETF PORTB
		CLRF TMR1L				;
		CLRF TMR1H				;clear timer1 registers
		BCF T1CON,T1CKPS0
		BCF T1CON,T1CKPS1		;timer1 prescale set to 1:1 rate
		BCF T1CON,TMR1CS		;timer1 internal clock (Fosc/4) enable
		BSF T1CON,TMR1ON		;start timer1
		
		GOTO $					;wait for an event to occur,a falling edge
		
		ORG 0008H				;interrupt vector location,isr
		BCF PIR1,CCP1IF			;clear CCP1 interrupt flag bit
		MOVF CCPR1L,0
		MOVWF 21H
		MOVF CCPR1H,0
		MOVWF 22H
		COMF PORTB,1			;compliment the status of LEDs on every capture
		CLRF TMR1L
		CLRF TMR1H				;clear timer1 registers 
        RETFIE 					;return from isr
        
        END						;end of program
