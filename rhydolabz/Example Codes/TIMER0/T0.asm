	
;/* Microchip MPLAB Version 7.4  			   	  */
;/* PIC C - HI-TECH PICC Compiler Version 8.05PL2 */
;
;/*
;*************************************************************************************************
;*    						       TIMER0   													* 
;*    		          																			*
;*************************************************************************************************
;																								*
;*  Description  : Source code to Toggle LED status on timer0 overflow
;   LED IS CONNECTED TO PORTB
;*																								*
;*************************************************************************************************
	
	
				Cnt equ 31H		;label 31H address as dCnt2

	INCLUDE"P18F4520.INC"		;include PIC18F4580 definitions
		ORG 0000H				;reset vector location
		CLRF PCLATH				;clearing program counter higher bits
		GOTO START				;jumping to start up location defined at 30H
		ORG 0030H
	
	START						;start of program	

		MOVLW D'50'				;
		MOVWF Cnt				;loading a count of 50
		MOVLW 0X0F
		MOVWF ADCON1
		CLRF TRISB				;make PORTB pins as output pins
		CLRF PORTB				;clear PORTB register
		
		MOVLW 0X3C				;loading timer0 register with 10ms count
		MOVWF TMR0L
		
		BCF T0CON,T0CS			;Internal instruction cycle clock
		BSF T0CON,T08BIT		;configured as 8-bit timer
		BCF T0CON,PSA			;assigning prescale bits for timer0	
		BSF T0CON,T0PS0			;set prescale for 1:256 TMR0 rate 
		BSF T0CON,T0PS1
		BSF T0CON,T0PS2	
		
		BSF INTCON,GIE			;global interrupt enable
		BSF INTCON,PEIE			;peripheral interrupt enable
		BSF INTCON,TMR0IE		;timer0 interrupt enable
		
		BSF T0CON,TMR0ON		;start timer0
			
		GOTO $					;wait for 10msec timer interrupt
	
		ORG 0008H				;interrupt service routine		
		MOVLW 0X3C				;loading timer0 register with 10ms count after timer overflow
		MOVWF TMR0L
		BCF INTCON,TMR0IF		;clearing timer0 interrupt flag
		
		DECFSZ Cnt,1			;check for Cnt==0
		GOTO EXIT
		
		;Toggle LED status
		COMF PORTB,1		
		MOVLW D'50'				;
		MOVWF Cnt				;loading a count of 50
EXIT
		RETFIE
		END						; end of program
