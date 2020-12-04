#include <xc.inc>
	
global	T0_Setup, K_Int_Hi, timer3_setup
extrn	get_key

psect	int_code, class=CODE
	
K_Int_Hi:	
	btfss	TMR0IF		; check that this is timer0 interrupt
	retfie	f		; if not then return
	call	get_key
	incf	LATJ, A
	bcf	TMR0IF		; clear interrupt flag
	retfie	f		; fast return from interrupt

T0_Setup:
	clrf	TRISJ, A	; Set PORTD as all outputs
	clrf	LATJ, A		; Clear PORTD outputs
	movlw	10000011B	; Set timer0 to 16-bit, Fosc/4/16
	movwf	T0CON, A	; 1MHz clock rate, approx 4ms rollover
	bsf	TMR0IE		; Enable timer0 interrupt
	bsf	GIE		; Enable all interrupts
	return

timer3_setup:
	movlw	10100011B	; set timer 3 to 1MHz rate
	movwf	T3CON, A
	return


