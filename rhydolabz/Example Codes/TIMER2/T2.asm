;/* Microchip MPLAB Version 7.4  			   	  */
;/* PIC C - HI-TECH PICC Compiler Version 8.05PL2 */
;
;/*
;*************************************************************************************************
;*    						       TIMER2   													* 
;*    		          																			*
;*************************************************************************************************
;																								*
;*  Description  : Source code to Toggle LED status on timer2 overflow
;   LED IS CONNECTED TO PORTB
;*																								*
;*************************************************************************************************
		
	
				Cnt equ 31H		;label 31H address as dCnt2
				
	INCLUDE"P18F4580.INC"		;include PIC18F4580 definitions
		ORG 0000H				;reset vector location
		CLRF PCLATH				;clearing program counter higher bits
		GOTO START				;jumping to start up location defined at 30H
		ORG 0030H
		
	START						;start of program
	
		MOVLW 0XFF				;
		MOVWF Cnt				;loading a count of 255
		
		CLRF TRISB				;make PORTB pins as output pins
		CLRF PORTB				;clear PORTB register
	
	
		BSF INTCON,GIE			;global interrupt enable
		BSF INTCON,PEIE			;peripheral interrupt enable
		BSF PIE1,TMR2IE			;timer2 interrupt enable
		MOVLW D'200'			;loading period register with timer overflow count
		MOVWF PR2
		
		CLRF TMR2				;clearing timer2 register
		BSF T2CON,T2CKPS0		;setting timer2 prescale rate to 1:4
		BCF T2CON,T2CKPS1		
		BCF T2CON,T2OUTPS0		;setting timer2 postscale rate to 1:10
		BSF T2CON,T2OUTPS1
		BCF T2CON,T2OUTPS2
		BSF T2CON,T2OUTPS3
		BSF T2CON,TMR2ON		;start timer2
		
		GOTO $					;wait for timer2 interrupt
		
		ORG 0008H				;interrupt service routine
		BCF PIR1,TMR2IF			;clearing timer2 interrupt flag
		DECFSZ Cnt,1			;check for Cnt==0
		GOTO EXIT
		
			;Toggle LED status
		COMF PORTB,1		
		MOVLW 0XFF				;
		MOVWF Cnt				;loading a count of 255
EXIT
		RETFIE					; return from isr
		
		END						; end of program
		
