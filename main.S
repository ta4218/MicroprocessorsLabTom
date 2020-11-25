#include <xc.inc>

extrn	LCD_Setup, delay_500ms
extrn	keypad_setup,  start_logo, game_select, key_control, counter_kp, display_clear, cursor_off
extrn	DAC_Setup, DAC_Int_Hi
extrn	setupRNG, game_setup
extrn   result_LCD, play_again

psect	udata_acs
on_off:	    ds  1
    
psect	code, abs	
rst: 	org	0x0
	movlw	0x0
	movwf	on_off, A	
 	goto	setup

int_hi:	org	0x0008	; high vector, no low vector

	goto	DAC_Int_Hi	

	; ******* Programme FLASH read Setup Code *********************** ****
setup:	
	bcf	CFGS	; point to Flash program memory  
	bsf	EEPGD 	; access Flash program memory
	call	LCD_Setup	; setup UART
	call	keypad_setup
	movlw	0x1
	cpfsgt	on_off
	call	DAC_Setup
	movlw	0x1
	cpfsgt	on_off
	call	timer3_setup
	
	
	call	setupRNG
	
	movlw	0x1
	cpfsgt	on_off
	goto	LCD_off
	goto	start

start:
	call	start_logo

	movlw	0x8
	call	delay_500ms
	;interrupt 10 second
	call	game_select
	;no interrupt needed
loop:	call	key_control
		
test_gt2:	
	movlw	0x32
	cpfsgt	counter_kp
	goto	test_lt1
	goto	loop
test_lt1:
	movlw	0x31
	cpfslt	counter_kp
	goto	select
	goto	loop
select:	
	movlw	0x32
	cpfslt	counter_kp
	goto	game_2
	goto	game_1
	
game_1:
	movlw	0x1
	goto	game_both

game_2:	
	movlw	0x2
	goto	game_both

game_both:
	call	game_setup
	call	result_LCD
	call	display_clear
	call	play_again
	call	cursor_off
	goto	pa_loop

pa_loop:    
	call	key_control
	
key_test:
	movlw	0x32
	cpfsgt	counter_kp
	goto	yes_or_no
	goto	pa_loop
	
zero_test:
	movlw	0x31
	cpfslt	counter_kp
	goto	select
	goto	pa_loop
	
yes_or_no:
	movlw	0x32
	cpfslt	counter_kp
	goto	LCD_off
	goto	setup
	
LCD_off:
	call	cursor_off
	call	display_clear
	call	key_control
	movlw	0x3D
	cpfseq	counter_kp
	bra	LCD_off
	call	display_clear
	incf	on_off, A
	goto	setup

timer3_setup:
	movlw	10100011B	
	movwf	T3CON, A
	return
	
			
