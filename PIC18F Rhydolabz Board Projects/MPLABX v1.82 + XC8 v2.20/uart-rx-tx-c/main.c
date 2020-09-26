#include <xc.h>
#include <stdio.h>

void main()
{
	TRISCbits.TRISC6 = 0;
	TRISCbits.TRISC7 = 1;

	TXSTAbits.BRGH = 1;
	SPBRG = 0x81;

	TXSTAbits.SYNC = 0;
	TXSTAbits.TXEN = 1;

	INTCONbits.GIE = 1;
	INTCONbits.PEIE = 1;
	PIE1bits.RCIE = 1;

    RCSTAbits.CREN = 1;
	RCSTAbits.SPEN = 1;

	TRISB = 0;
	PORTB = 0x0;

	while(1);

	return;
}


void interrupt handle_serial()
{
	PIR1bits.RCIF = 0;
	TXREG = RCREG;

	PORTB = 0xFF;

	while(TXSTAbits.TRMT!=1)
		;

	PORTB = 0x0;
}
