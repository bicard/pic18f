
;/* Microchip MPLAB Version 7.4  			   	  */
;/* PIC C - HI-TECH PICC Compiler Version 8.05PL2 */
;
;/*
;*************************************************************************************************
;*    						       I2C    										                 * 
;*    		          																			 *
;*************************************************************************************************
;																								 *
;*  Description  : Source code TO READ AND WRITE EEPROM using I2C PROTOCOL
;  																						         *
;*************************************************************************************************
		  	  
dCnt1 equ 30H		;label 30H address as dCnt1
dCnt2 equ 31H		;label 31H address as dCnt2
	  
	   		INCLUDE"P18F4520.INC"	;include PIC18F4580 definitions
			ORG 0000H			;reset vector location
		    CLRF PCLATH			;clearing program counter higher bits
		    GOTO START			;jump to start up location defined at 30H
			ORG 0030H

START					;start of program
	
		;	CLRF TRISC			;make PORTC pins as output	
		;	BSF TRISC,4			;make serial I/O pin as input
			
			;---USART INITIALISATION---;
			
			BSF TXSTA,TXEN		;transmission enable
			BCF TXSTA,SYNC		;asynchronous mode select
			BSF TXSTA,BRGH		;switch to high speed baud rate
			MOVLW 0X81			;
			MOVWF SPBRG			;value loaded for baud-rate,9600 
			BSF RCSTA,SPEN		;serial port enable
					
			;----I2C INITIALISATION----;
			
	
			BSF SSPSTAT,7		;input data sampling done at the end of data output time
			BCF SSPSTAT,6		;slew rate control disabled for standard speed mode(100kHz)
			MOVLW D'49'
			MOVWF SSPADD		;baud rate value for 100kHz
			BSF SSPCON1,SSPEN	;enabls serial port,and
								;configures SDA and SCL pins as the source of serial port pins
			BSF SSPCON1,SSPM3	;
			BCF SSPCON1,SSPM2	;
			BCF SSPCON1,SSPM1	;
			BCF SSPCON1,SSPM0	;i2c Master mode, clock=Fosc/(4*(SSPADD+1))
								;clock = 100kHz, Fosc = 20Mhz
		
			;---------I2C WRITE--------;
			
		
			CALL I2CSTART		;call for i2c START
			
			
		
			MOVLW 0XA0			;writing Device Address with write enable
			CALL VERIFY			;call for write verification
		
			MOVLW 0X01			;writing Location Address
			CALL VERIFY			;call for write verification
		
			MOVLW 'V'			;Data to be written(ASCII)to device
			CALL VERIFY			;call for write verification		
		
			CALL I2CSTOP			;call for i2c STOP
			
			;------------------------------------------------------------
			CALL DELAY			;delay before initiating an i2c read
			CALL DELAY			;delay before initiating an i2c read
			;------------------------------------------------------------
			
			;---------DUMMY WRITE-------;
			
			CALL I2CSTART		;call for i2c START
			
			MOVLW 0XA0			;writing Device Address with write enable
			CALL VERIFY			;call for write verification
		
			MOVLW 0X01			;writing Location Address
			CALL VERIFY			;call for write verification
			
			CALL I2CSTOP			;call for i2c STOP
		
			;------------------------------------------------------------
			CALL DELAY			;delay before initiating an i2c read
			;------------------------------------------------------------
			
			;----------I2C READ---------;
		
			CALL I2CSTART		;call for i2c START
			
			MOVLW 0XA1			;writing Device Address with read enable
			CALL VERIFY			;call for write verification
	
			BSF SSPCON2,RCEN	;synchronous reception enabled	
			BTFSS PIR1,SSPIF	;wait for data to be read(check SSP interrupt flag)
			GOTO $-1			;skip if set
			BCF PIR1,SSPIF		;clear flag bit				
			
			BSF SSPCON2,ACKEN	;Master acknowledge enable
			BSF SSPCON2,ACKDT	;send active low as acknowledgement from PIC to EEPROM
								;ie, from master to slave
			MOVF SSPBUF,0		;move the received data to working register	
			MOVWF TXREG
			BTFSS TXSTA,TRMT
			GOTO $-1
		
			CALL I2CSTOP		;call for i2c STOP
			
			GOTO $
			
			;--------subroutines--------;
		
I2CSTART	
				BSF SSPCON2,SEN		;START Condition Enable Bit	
				BTFSS PIR1,SSPIF	;wait for START enable(check SSP interrupt flag)
				GOTO $-1			;skip if set
				BCF PIR1,SSPIF		;clear flag bit
				RETURN				;return from subroutine
				
I2CSTOP
				BSF SSPCON2,PEN		;STOP Condition Enable Bit 		
				BTFSS PIR1,SSPIF	;wait for STOP condition(check SSP interrupt flag)
				GOTO $-1			;skip if set
				BCF PIR1,SSPIF		;clear flag bit
				RETURN				;return from subroutine
			
VERIFY:		
				MOVWF SSPBUF		;loading data to SSPBUF for i2c write
				BTFSS PIR1,SSPIF	;wait for data write(check SSP interrupt flag)
				GOTO $-1			;skip if set
				BCF PIR1,SSPIF		;clear flag bit					
				;BSF SSPCON2,ACKSTAT	;set back for ACK to initial mode once received		
				MOVF SSPBUF,0		;loading working register with SSPBUF data
				RETURN				;return from subroutine
				
DELAY								;delay sub-routine
				MOVLW 0XFF
				MOVWF dCnt1			;load 0xff to dCnt1
			D2
				MOVWF dCnt2			;load 0xff to dCnt2
			D1
				DECFSZ dCnt2,1		;decrement dCnt2 and skip if zero
				GOTO D1				;jump to label D1
				DECFSZ dCnt1,1		;decrement dCnt1 and skip if zero
				GOTO D2				;jump to label D2
				RETURN				;return from delay sub-routine
				
				END					;end of program
