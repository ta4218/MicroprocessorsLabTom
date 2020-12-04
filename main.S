#include <pic18_chip_select.inc>
#include <xc.inc>

extrn	LCD_Setup, delay_500ms
extrn	keypad_setup,  start_logo, game_select, key_control, display_clear, cursor_off
extrn	T0_Setup, K_Int_Hi
extrn	setupRNG, game_setup
extrn   result_LCD, play_again, timer3_setup;,  LCD_off

psect	udata_acs
on_off:	    ds  1   ;reserve one byte for on/off counter
key_press:  ds 1    ; reserve one byet for key_press
    
psect	code, abs	
rst: 	org	0x0
	movlw	0x0
	movwf	on_off, A	
 	goto	setup

int_hi:	org	0x0008		; high vector, no low vector

	goto	K_Int_Hi	

	; ******* Programme FLASH read Setup Code ***************************
setup:	
	bcf	CFGS		; point to Flash program memory  
	bsf	EEPGD		; access Flash program memory
	
	; ******* SETUP CODE FOR LCD, KEYPAD, INTERRUPT, TIMERS ***************
	
	call	LCD_Setup	; setup LCD
	call	keypad_setup	; SETUP KEYPAD
	;movlw	0x1
	;cpfsgt	on_off		; is on_off greater than 1, if so skip next
	call	T0_Setup	; interrupt setup 
	movlw	0x1
	cpfsgt	on_off, A	; is on_off greater than 1, if so skip next
	call	timer3_setup	; initialise TMR3
	call	setupRNG	; setup random number generator
	
	movlw	0x1		
	cpfsgt	on_off, A		; is on_off greater than 1, if so skip next
	goto	LCD_off		; turn LCD off routine
	goto	start		; start program
	
	;******************** GAME STARTS HERE *****************************

start:
	call	start_logo	; output logo to LCD
	movlw	0x8
	call	delay_500ms	; 4s delay
	call	game_select	; select game screen output to LCD
	
loop:	call	key_control	; wait for a key to pressed
	movwf	key_press, A	; move value of input into key_press
    
    
    ;************************* TESTING KEY FOR GAME SELECTION ****************
		
test_gt2:	
	movlw	0x32		; key pressed is greater than 2, keep scanning
	cpfsgt	key_press,A	; if its not greater, test key
	goto	test_lt1
	goto	loop
test_lt1:
	movlw	0x31
	cpfslt	key_press,A	; key pressed less than one, keep scanning
	goto	select		; if not less than 1, select game
	goto	loop
select:	
	movlw	0x32
	cpfslt	key_press,A	; is the key pressed less than 2, if so go to game1
	goto	game_2		; if it is 2 go to game 2
	goto	game_1
	
	
    ;********************** ENTER QUESTIONS **********************************
game_1:
	movlw	0x1
	goto	game_both	; enter game routine with W=1

game_2:	
	movlw	0x2
	goto	game_both	; enter game routine with W=2

game_both:
	call	game_setup	; setup question
	call	result_LCD	; output answer to LCD
	call	display_clear	
	call	play_again	
	call	cursor_off
	goto	pa_loop

pa_loop:    
	call	key_control	; wait for key pressed
	movwf	key_press, A	; move value of input into key_press
key_test:
	movlw	0x32
	cpfsgt	key_press,A	;if key pressed greater than 2, keep scanning
	goto	yes_or_no
	goto	pa_loop
	
zero_test:
	movlw	0x31		
	cpfslt	key_press,A	;if key pressed less than 1, keep scanning
	goto	select
	goto	pa_loop
	
yes_or_no:
	movlw	0x32		
	cpfslt	key_press,A	;if key pressed is 1, restart
	goto	LCD_off		;if key pressed is 2, standby
	goto	setup
	
LCD_off:
	call	cursor_off	
	call	display_clear
	call	key_control	    ; see which key is pressed, standby or restart
	movwf	key_press, A
	movlw	0x3D
	cpfseq	key_press,A
	bra	LCD_off		    
	call	display_clear	    ; enter standby
	incf	on_off, A	    ; increment on_off variable
	goto	setup


	
			
