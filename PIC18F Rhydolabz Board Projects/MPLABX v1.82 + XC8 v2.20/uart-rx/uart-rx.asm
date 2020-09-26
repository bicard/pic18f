;/* Microchip MPLAB Version 7.4  			   	  */
;/* PIC C - HI-TECH PICC Compiler Version 8.05PL2 */
;
;/*
;*************************************************************************************************
;*    						       USART_RECEPTION   													*
;*    		          																			*
;*************************************************************************************************
;																								*
;*  Description  : Source code to receive data and transmit it  back to hyperterminal
;
;*																								*
;*************************************************************************************************

		INCLUDE"P18F4520.INC"		;include PIC18F4580 definitions
			ORG 0000H				;reset vector location
			CLRF PCLATH				;clearing program counter higher bits
			GOTO START				;jump to start up location defined at 30H
			ORG 0030H

	START							;start of program

			BSF TRISC,7				;configure PORTC 7th pin as i/p pin for reception
			BCF TRISC,6				;configure PORTC 6th pin as o/p pin for transmisson
			BSF TXSTA,BRGH			; select high speed baud-rate(9600)

			; value loaded corresponding to baud-rate,9600
			MOVLW 0x81
			MOVWF SPBRG
			BCF TXSTA,SYNC			; asynchronous mode select
			BSF TXSTA,TXEN			; 8-bit transmission enable
			BSF RCSTA,SPEN			; serial port enable

			BSF INTCON,GIE			; global interrupt enable
			BSF INTCON,PEIE			; peripheral interrupt enable
			BSF PIE1,RCIE			; USART receive interrupt enable
			BSF RCSTA,SPEN			; serial port enable
			BSF RCSTA,CREN			; continuous receive enable

			GOTO $					;wait for data reception

			ORG 0008H				;interrupt vector location,isr
			BCF PIR1,RCIF			;clear receive interrupt flag
			MOVF RCREG,0
			MOVWF TXREG				;load transmit buffer with the received data
	CHECK
			BTFSS TXSTA,TRMT		;wait for complete transmission and skip if done
			GOTO CHECK
			RETFIE

			END						;end of program



