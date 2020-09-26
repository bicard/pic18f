	
;/* Microchip MPLAB Version 7.4  			   	  */
;/* PIC C - HI-TECH PICC Compiler Version 8.05PL2 */
;
;/*
;*************************************************************************************************
;*    						       USART_TRANSMISSION  													* 
;*    		          																			*
;*************************************************************************************************
;																								*
;*  Description  : Source code to TRANSMIT DATA USING USART
;*																								*
;*************************************************************************************************
		  
	   INCLUDE"P18F4520.INC"	;include PIC18F4580 definitions
			 ORG 0000H			;reset vector location
		   CLRF PCLATH			;clearing program counter higher bits
		    GOTO START			;jump to start up location defined at 30H
			 ORG 0030H
			 
	START						;start of program		
	
			BCF TRISC,6			; configure RC6(TXD pin) as o/p 	
			BSF TXSTA,BRGH		; select high speed baud-rate(9600)
			BCF BAUDCON,BRG16	; 8-bit Baud Rate Generator, SPBRG only 
							
			; value loaded corresponding to baud-rate,9600
			MOVLW 0x81
			MOVWF SPBRG		
			BCF TXSTA,SYNC		; asynchronous mode select
			BSF TXSTA,TXEN		; 8-bit transmission enable
			BSF RCSTA,SPEN		; serial port enable

		    MOVLW 'S'			
		    MOVWF TXREG			;transmit buffer loaded with data to be transmitted   
	CHECK   
			BTFSS TXSTA,TRMT	;wait for complete transmission and skip if done
		    GOTO CHECK
		    
		    GOTO $				;infinite wait
		    
		    END					;end of program
		    
			
