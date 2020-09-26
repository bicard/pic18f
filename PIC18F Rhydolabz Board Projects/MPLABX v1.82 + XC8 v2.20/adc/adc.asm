
;/* Microchip MPLAB Version 7.4  			   	  */
;/* PIC C - HI-TECH PICC Compiler Version 8.05PL2 */
;
;/*
;*************************************************************************************************
;*    						    			  ADC  												 *
;*    		          																			 *
;*************************************************************************************************
;*																							 	 *
;*  Description  : Source code TO READ ADC VALUE AND DISPLAY IT IN LCD							 *
;*																								 *
;*************************************************************************************************


		INCLUDE "P18F4520.INC"

		LCDCOMMAND EQU  30H
		LCDDATA    EQU  31H
		VAL	       EQU  32H
		RW 	       EQU  0        ; RW = ZEROTH BIT IN PORTC-- RC0
		ENABLE     EQU  2        ; FIFTH BIT IN PORT C -- RC5
		RS         EQU  1        ; FIRST BIT IN PORT C -- RC1
		dCnt1 EQU  84H
		dCnt2 EQU  85H

		ORG 0000H
		CLRF PCLATH     	     ; FOR DOWNLOADING
		GOTO START
		ORG 0030H

START
	    CALL LCDINIT
		MOVLW H'FF'
		MOVWF TRISA
	    MOVLW 0X00   		; ALL ANALOG MODE WITH RIGHT JUSTIFIED
	    MOVWF ADCON1        ; CONTROL REGISTER 1 FOR ADC INITIALISED
		MOVLW H'92'
		MOVWF ADCON2

AGAIN
 		MOVLW 0X11  		 ; FOSC/32, CHANNEL 4(RA5), ADON & GO/DONE ==0
	    MOVWF ADCON0        ; VALUE PASSED TO CONTROL REGISTER 0
	    CALL DELAY          ; DELAY CALLED
	    BSF ADCON0,1        ; SET GO/DONE BIT --> AD CONVERSION STARTS
CONVCHK
	    BTFSC ADCON0,1      ; CHECK WHETHER CONVERSION OVER
	    GOTO CONVCHK        ; NOT OVER, GO BACK
	    MOVLW H'80'         ; VALUE TO ACTIVATE 3 BOXES OF LCD
	    CALL SNDCOMMAND
	    MOVF ADRESH,0       ; VALUE OF ADRESH IN WR
	    ANDLW H'03'         ; AND WR WITH OF
	    MOVWF VAL
	    CALL CHKVALUE       ; THE VALUE IN WR IS CHECKED
	    MOVWF LCDDATA
	    CALL SNDDATA
	    SWAPF ADRESL,0      ; VALUE OF ADRESH IN WR
	    ANDLW H'0F'         ; AND WR WITH OF
	    MOVWF VAL
	    CALL CHKVALUE       ; THE VALUE IN WR IS CHECKED
	    MOVWF LCDDATA
	    CALL SNDDATA
	    MOVF ADRESL,0       ; VALUE OF ADRESH IN WR
	    ANDLW H'0F'         ; AND WR WITH OF
	    MOVWF VAL           ; VALUE OF WR STORED IN VAL
	    CALL CHKVALUE       ; THE VALUE IN WR IS CHECKED
	    MOVWF LCDDATA
	    CALL SNDDATA
	    CALL DELAY          ; DELAY IS CALLED
	    GOTO AGAIN          ; DO IT AGAIN

CHKVALUE
	    MOVLW H'0A'
	    SUBWF VAL,0
	    BTFSC STATUS,C
	    GOTO VALATOF
	    GOTO VALZTON

VALATOF                         ; VALUE BETWEEN A AND F
	    MOVLW H'0A'             ; HEXA 0A MOVED TO WR
	    SUBWF VAL,1             ; VALUE - 0A --> VAL
	    MOVLW 'A'               ; TO SEE A TO F IN LCD
	    ADDWF VAL,0             ; 'A' + (VALUE-0A)
	    RETURN

VALZTON                     ; VALUE BETWEEN 0 AND 9
	    MOVLW '0'
	    ADDWF VAL,0             ; VALUE + '0'
	    RETURN

LCDINIT
	    clrf TRISC 		 ; THREE BITS MADE OUTPUT
	  ;  MOVWF TRISC        		 ; -> FOR LCD DISPLAY
	    CLRF TRISD        ; TRISD CLEARED
	    MOVLW H'38'        		 ; TWO ROW 8-BIT INTERFACE
	    CALL SNDCOMMAND
        MOVLW H'0C'        		 ; CURSOR OFF
	    CALL SNDCOMMAND
	    MOVLW H'01'        		 ; CLEAR DISPLAY
	    CALL SNDCOMMAND
	    MOVLW H'06'
	    CALL SNDCOMMAND			; AUTOMATIC ADDRESS INCREMENT
        MOVLW H'80'        		 ; CURSOR OFF
	    CALL SNDCOMMAND
	    RETURN

SNDCOMMAND

	    BCF PORTC,1
	    BCF PORTC,0
	    BSF PORTC,2
	    MOVWF PORTD
	    CALL DELAY
	    BCF PORTC,2
	    RETURN

SNDDATA

	    BSF PORTC,1
	    BCF PORTC,0
	    BSF PORTC,2
	    MOVF LCDDATA,0      ; DATA MOVED TO WR
	    MOVWF PORTD
	    CALL DELAY
	    BCF PORTC,2
	    RETURN

DELAY						;delay sub-routine
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
    		END



