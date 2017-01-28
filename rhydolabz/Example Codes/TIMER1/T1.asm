;/* Microchip MPLAB Version 7.4  			   	  */
;/* PIC C - HI-TECH PICC Compiler Version 8.05PL2 */
;
;/*
;*************************************************************************************************
;*    						       TIMER1   													* 
;*    		          																			*
;*************************************************************************************************
;																								*
;*  Description  : Source code to Toggle LED status on timer1 overflow
;   LED IS CONNECTED TO PORTB
;*																								*
;*************************************************************************************************

				Cnt equ 31H		;label 31H address as dCnt2

	INCLUDE"P18F4580.INC"		;include PIC18f4580 definitions
		ORG 0000H				;reset vector location
		CLRF PCLATH				;clearing program counter higher bits
		GOTO START				;jumping to start up location defined at 30H
		ORG 0030H
		
	START						;start of program
	
		MOVLW D'50'				;
		MOVWF Cnt				;loading a count of 50
		
		CLRF TRISB				;make PORTB pins as output pins
		CLRF PORTB				;clear PORTB register			
		
		BSF INTCON,GIE			;global interrupt enable
		BSF INTCON,PEIE			;peripheral interrupt enable
		BSF PIE1,TMR1IE			;timer1 interrupt enable
		
		MOVLW 0XAF				;loading timer1 registers with 10ms count
		MOVWF TMR1L
		MOVLW 0X3C				
		MOVWF TMR1H	
		BSF T1CON,RD16			;Enables register read/write of TImer1 in one 16-bit operation	
		BCF T1CON,TMR1CS		;internal clock source (Fosc/4) select
		BCF T1CON,T1CKPS0		;timer1 1:1 prescale select
		BCF T1CON,T1CKPS0
		BSF T1CON,TMR1ON		;start timer1
		
		GOTO $					;wait for 10msec timer interrupt
		
		ORG 0008H				;interrupt service routine
		MOVLW 0XAF				;loading timer1 registerS with 10ms count after timer overflow
		MOVWF TMR1L
		MOVLW 0X3C
		MOVWF TMR1H
		BCF PIR1,TMR1IF			;clearing timer1 interrupt flag
		
		DECFSZ Cnt,1			;check for Cnt==0
		GOTO EXIT
		
		;Toggle LED status
		COMF PORTB,1		
		MOVLW D'50'				;
		MOVWF Cnt				;loading a count of 50
EXIT
		RETFIE
		END						; end of program
