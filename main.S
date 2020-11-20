#include <xc.inc>

extrn	LCD_Setup
extrn	keypad_setup,  start_logo, game_select, key_control, counter_kp, display_clear
extrn	DAC_Setup, DAC_Int_Hi
extrn	setupRNG, Multiplygame_1
extrn   h2d_setup, ascii
extrn	start_test
    
psect	code, abs	
rst: 	org	0x0
 	goto	setup

int_hi:	org	0x0008	; high vector, no low vector

	goto	DAC_Int_Hi	

	; ******* Programme FLASH read Setup Code ***********************
setup:	call	start_test
	bcf	CFGS	; point to Flash program memory  
	bsf	EEPGD 	; access Flash program memory
	call	LCD_Setup	; setup UART
	call	keypad_setup
	call	DAC_Setup
	call	setupRNG
	call	h2d_setup
	call	ascii
	goto	start

start:
	call	start_logo
	;interrupt 10 second
	call	game_select
	;no interrupt needed
loop:	call	key_control
	
	
test:	
	movlw	0x32
	cpfsgt	counter_kp
	goto	test2
	goto	loop
	
test2:	
	movlw	0x32
	cpfslt	counter_kp
	goto	game_2
	goto	game_1
	
game_1:
	call	display_clear
	call	Multiplygame_1

game_2:	
	movff	counter_kp, LATD, A
;	goto	$
			
