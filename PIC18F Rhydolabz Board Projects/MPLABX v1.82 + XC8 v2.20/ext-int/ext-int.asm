
;/* Microchip MPLAB Version 7.4  			   	  */
;/* PIC C - HI-TECH PICC Compiler Version 8.05PL2 */
;
;/*
;*************************************************************************************************
;*    						       EXTERNAL INTERRUPT    										 *
;*    		          																			 *
;*************************************************************************************************
;																								*
;*  Description  : Source code TO compliment the status of BUZZER on every EXTERNAL INTERRUPT   *
;   (PRESS THE EXTERNAL INTERRUPT SWITCH IN THE BOARD )
;*																								*
;*************************************************************************************************


	INCLUDE"P18F4520.INC"	; include PIC18F4580 definitions
	ORG 0000H			; reset vector location
	CLRF PCLATH			; clearing program counter higher bits
	GOTO START			; jump to start up location ie, 30H
	ORG 0030H

START 					; start of program
	MOVLW 0X0F
	MOVWF ADCON1
	BSF TRISB,0			; make RB0 (interrupt pin) as input
	BCF TRISE,0			; make RE0 as output for buzzer input
	BSF INTCON,GIE		; global interrupt enable
	BSF INTCON,PEIE
	BSF INTCON,INT0IE	; external interrupt enable
	BSF INTCON2,RBPU	; external interrupt enable
	BCF INTCON2,INTEDG0	; external interrupt enable
	BCF PORTE,0
	GOTO $				; wait for interrupt

	ORG 0008H			; interrupt service routine, isr
	BCF INTCON,INT0IF	; clear interrupt flag

	;check if buzzer connected to RE0 	is ON and skip to OFF
    BTFSS 20H,1
	GOTO ON				; if not ON buzzer
	GOTO OFF			; if yes OFF buzzer
ON:
	BSF PORTE,0
	BSF 20H,1
	RETFIE				; return from isr
OFF:
	BCF PORTE,0
	BCF 20H,1
	RETFIE				; return from isr

	END					; end of program




