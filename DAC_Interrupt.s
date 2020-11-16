#include <xc.inc>
	
global	DAC_Setup, DAC_Int_Hi, twofivefive
extrn	get_key, start_keypad, combined_input
psect	data   
twofivefive:	   ds 2
    
psect	dac_code, class=CODE
	
DAC_Int_Hi:	
	btfss	TMR0IF		; check that this is timer0 interrupt
	retfie	f		; if not then return
	
	call	get_key
	movlw	0xff
	movwf	LATJ, A
	cpfseq	combined_input
	call	start_keypad
	bcf	TMR0IF		; clear interrupt flag
	retfie	f		; fast return from interrupt

DAC_Setup:
	clrf	TRISJ, A
	clrf	LATJ, A
	movlw	10000100B	; Set timer0 to 16-bit, Fosc/4/16
	movwf	T0CON, A	; = 62.5KHz clock rate, approx 1sec rollover
	bsf	TMR0IE		; Enable timer0 interrupt
	bsf	GIE		; Enable all interrupts
	return
	
	end


