
;/* Microchip MPLAB Version 7.4  			   	  */
;/* PIC C - HI-TECH PICC Compiler Version 8.05PL2 */
;
;/*
;*************************************************************************************************
;*    						       MATRIX KEY BOARD    										 * 
;*    		          																			 *
;*************************************************************************************************
;																								 * 
;*  Description  : Source code TO TRANSMIT THE KEYBORD ENTRY USING USART					     *
;   (PRESS THE KEY BOARD AFTER CONNECTING THE BOARD TO THE COMPUTER USING SERIAL CABLE
;               OPEN THE HYPER-TERMINAL WITH REQUIRED BAUDRATE
;   			(RESULT WILL BE SHOWED IN THE HYPER-TERMINAL )
;*																								*
;*************************************************************************************************
	


	INCLUDE "P18F4520.INC"

KEY1 EQU 23H
KEYPREV EQU 24H
dCnt1 equ 30H			;label 30H address as dCnt1
dCnt2 equ 31H			;label 31H address as dCnt2	

	org 0000h
	CLRF PCLATH        	 ; for downloading
	goto Start	
	org 0030h
	
Start
	MOVLW 0X0F
	MOVWF ADCON1
	MOVLW B'00011110'    ; PORTB RB1:RB4 MADE INPUT and RB5:RB7 MADE OUTPUT
    MOVWF TRISB
    BCF INTCON2,7
    ;usart_transmission initialisation
   	BCF TRISC,6			 ; configure RC6(TXD pin) as o/p 	
	BSF TXSTA,BRGH		 ; select high speed baud-rate(9600)
	BCF BAUDCON,BRG16	 ; 8-bit Baud Rate Generator, SPBRG only 
					
	; value loaded corresponding to baud-rate,9600
	MOVLW 0x81
	MOVWF SPBRG		
	BCF TXSTA,SYNC		 ; asynchronous mode select
	BSF TXSTA,TXEN		 ; 8-bit transmission enable
	BSF RCSTA,SPEN		 ; serial port enable

LOOP1	

    BCF PORTB,5         ; CASE 1 - RB5:RB7 = 011
    BSF PORTB,6
    BSF PORTB,7
    CALL KEYSCAN1       ; BASED ON THE VALUE OF RB5:RB7
    
    BSF PORTB,5         ; CASE 2 - RB5:RB7 = 101
    BCF PORTB,6
    BSF PORTB,7
    CALL KEYSCAN2
  
    BSF PORTB,5         ; CASE 3 - RB5:RB7 = 110
    BSF PORTB,6
    BCF PORTB,7
    CALL KEYSCAN3

    GOTO LOOP1          ; INFINITE LOOP EXECUTED
   
KEYSCAN1
    MOVF PORTB,0        ; VALUE OF PORTB MOVED TO WR
    ANDLW H'1E'         ; AND WR WITH HEXA 'OF'-->WR
    MOVWF KEY1          ; VALUE OF WR MOVED TO KEY1
    MOVLW H'1E'         ; OF MOVED TO WR
    SUBWF KEY1,0        ; SUBTRACT KEY1 WITH OF
    BTFSC STATUS,Z      ; IF KEY1-OF ==0, GO BACK
    RETURN
    
    MOVF KEY1,0     
    MOVWF KEYPREV       ; MOVE VALUE OF KEY1 TO KEYPREV
    CALL DELAY 
    CALL DELAY       
    MOVF PORTB,0
    ANDLW H'1E'         ; AND WR WITH HEXA 'OF'-->WR
    MOVWF KEY1          ; VALUE OF WR MOVED TO KEY1
    MOVLW H'1E'
    SUBWF KEY1,0
    BTFSC STATUS,Z      ; CHECK THE Z FLAG
    RETURN
    MOVF KEYPREV,0
    SUBWF KEY1,0
    BTFSS STATUS,Z      ; CHECK THE Z FLAG
    RETURN
                        ; CASE 1 --> KEYS IN TOP ROW
    MOVLW H'1C'         ; CHECK WHETHER KEY PRESSED IS OE IE 00001110
    SUBWF KEY1,0
    BTFSS STATUS,Z 
    GOTO CODEA2
    MOVLW 'A'           ; MOVE ASCII 1 TO NUM
    CALL SNDDATA        ; SENT 1 TO USART
    CALL KEYHIGH        ; WAIT TILL THE KEY IS HIGH
    RETURN
CODEA2    
    MOVLW H'1A'         ; CHECK WHETHER KEY PREESSED IS OE IE 00001101
    SUBWF KEY1,0
    BTFSS STATUS,2 
    GOTO CODEA3
    MOVLW 'B'
    CALL SNDDATA
    CALL KEYHIGH
    RETURN
CODEA3    
    MOVLW H'16'         ; CHECK WHETHER KEY PREESSED IS OE IE 00001011
    SUBWF KEY1,0
    BTFSS STATUS,2 
    GOTO CODEA4
    MOVLW 'C'
    CALL SNDDATA
    CALL KEYHIGH
    RETURN
CODEA4   
    MOVLW H'0E'         ; CHECK WHETHER KEY PREESSED IS OE IE 00000111
    SUBWF KEY1,0
    BTFSS STATUS,2 
    RETURN
    MOVLW 'D'
    CALL SNDDATA
    CALL KEYHIGH
    RETURN

KEYSCAN2
    MOVF PORTB,0        ; VALUE OF PORTC MOVED TO WR
    ANDLW H'1E'         ; AND WR WITH HEXA 'OF'-->WR
    MOVWF KEY1          ; VALUE OF WR MOVED TO KEY1
    MOVLW H'1E'         ; OF MOVED TO WR
    SUBWF KEY1,0        ; SUBTRACT KEY1 WITH OF
    BTFSC STATUS,Z      ; IF KEY1-OF ==0, GO BACK
    RETURN
    
    MOVF KEY1,0     
    MOVWF KEYPREV       ; MOVE VALUE OF KEY1 TO KEYPREV
    CALL DELAY
    CALL DELAY     
    MOVF PORTB,0
    ANDLW H'1E'         ; AND WR WITH HEXA 'OF'-->WR
    MOVWF KEY1          ; VALUE OF WR MOVED TO KEY1
    MOVLW H'1E'
    SUBWF KEY1,0
    BTFSC STATUS,Z      ; CHECK THE Z FLAG
    RETURN
    MOVF KEYPREV,0
    SUBWF KEY1,0
    BTFSS STATUS,Z      ; CHECK THE Z FLAG
    RETURN
                    
                        ; CASE 2 KEYS IN SECOND ROW
    MOVLW H'1C'         ; CHECK WHETHER KEY PRESSED IS OE IE 00001110
    SUBWF KEY1,0
    BTFSS STATUS,Z 
    GOTO CODEB2
    MOVLW 'E'           ; MOVE ASCII 1 TO NUM
    CALL SNDDATA        ; SENT 1 TO LCD
    CALL KEYHIGH        ; WAIT TILL THE KEY IS HIGH
    RETURN
CODEB2    
    MOVLW H'1A'         ; CHECK WHETHER KEY PREESSED IS OE IE 00001101
    SUBWF KEY1,0
    BTFSS STATUS,2 
    GOTO CODEB3
    MOVLW 'F'
    CALL SNDDATA
    CALL KEYHIGH
    RETURN
CODEB3    
    MOVLW H'16'         ; CHECK WHETHER KEY PREESSED IS OE IE 00001011
    SUBWF KEY1,0
    BTFSS STATUS,2 
    GOTO CODEB4
    MOVLW 'G'
    CALL SNDDATA
    CALL KEYHIGH
    RETURN
CODEB4   
    MOVLW H'0E'         ; CHECK WHETHER KEY PREESSED IS OE IE 00000111
    SUBWF KEY1,0
    BTFSS STATUS,2 
    RETURN
    MOVLW 'H'  
    CALL SNDDATA
    CALL KEYHIGH
    RETURN
    
KEYSCAN3
    MOVF PORTB,0        ; VALUE OF PORTC MOVED TO WR
    ANDLW H'1E'         ; AND WR WITH HEXA 'OF'-->WR
    MOVWF KEY1          ; VALUE OF WR MOVED TO KEY1
    MOVLW H'1E'         ; OF MOVED TO WR
    SUBWF KEY1,0        ; SUBTRACT KEY1 WITH OF
    BTFSC STATUS,Z      ; IF KEY1-OF ==0, GO BACK
    RETURN
    
    MOVF KEY1,0     
    MOVWF KEYPREV       ; MOVE VALUE OF KEY1 TO KEYPREV
    CALL DELAY
    CALL DELAY       
    MOVF PORTB,0
    ANDLW H'1E'         ; AND WR WITH HEXA 'OF'-->WR
    MOVWF KEY1          ; VALUE OF WR MOVED TO KEY1
    MOVLW H'1E'
    SUBWF KEY1,0
    BTFSC STATUS,Z      ; CHECK THE Z FLAG
    RETURN
    MOVF KEYPREV,0
    SUBWF KEY1,0
    BTFSS STATUS,Z      ; CHECK THE Z FLAG
    RETURN

                        ; CASE 3 --> KEYS IN THIRD ROW
    MOVLW H'1C'         ; CHECK WHETHER KEY PRESSED IS OE IE 00001110
    SUBWF KEY1,0
    BTFSS STATUS,Z 
    GOTO CODEC2
    MOVLW 'I'           ; MOVE ASCII 1 TO NUM
    CALL SNDDATA      	; SENT 1 TO USART
    CALL KEYHIGH        ; WAIT TILL THE KEY IS HIGH
    RETURN
CODEC2    
    MOVLW H'1A'         ; CHECK WHETHER KEY PREESSED IS OE IE 00001101
    SUBWF KEY1,0
    BTFSS STATUS,2 
    GOTO CODEC3
    MOVLW 'J'
    CALL SNDDATA
    CALL KEYHIGH
    RETURN
CODEC3    
    MOVLW H'16'        ; CHECK WHETHER KEY PREESSED IS OE IE 00001011
    SUBWF KEY1,0
    BTFSS STATUS,2 
    GOTO CODEC4
    MOVLW 'K'  
    CALL SNDDATA
    CALL KEYHIGH
    RETURN
CODEC4   
    MOVLW H'0E'         ; CHECK WHETHER KEY PREESSED IS OE IE 00000111
    SUBWF KEY1,0
    BTFSS STATUS,2 
    RETURN
    MOVLW 'L' 
    CALL SNDDATA
    CALL KEYHIGH
    RETURN   


KEYHIGH                 ; TO WAIT UNTIL KEY IS RELEASED
    MOVF PORTB,0
    ANDLW H'1E'         ; AND WR WITH HEXA 'OF'-->WR
    MOVWF KEY1          ; VALUE OF WR MOVED TO KEY1
    MOVLW H'1E'
    SUBWF KEY1,0
    BTFSS STATUS,Z      ; CHECK THE Z FLAG
    GOTO KEYHIGH
    CALL DELAY 
    CALL DELAY
    RETURN           

SNDDATA
	   MOVWF TXREG			;transmit buffer loaded with data to be transmitted   
CHECK   
	   BTFSS TXSTA,TRMT		;wait for complete transmission and skip if done
	   GOTO CHECK		    
	   RETURN
    
DELAY						;delay sub-routine
		MOVLW 0X0F
		MOVWF dCnt1			;load 0x0f to dCnt1
D2
		MOVWF dCnt2			;load 0x0f to dCnt2
D1
		DECFSZ dCnt2,1		;decrement dCnt2 and skip if zero
		GOTO D1				;jump to label D1
		DECFSZ dCnt1,1		;decrement dCnt1 and skip if zero
		GOTO D2				;jump to label D2
		RETURN				;return from delay sub-routine
		    
        END
