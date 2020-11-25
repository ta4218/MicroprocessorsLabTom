#include <xc.inc>
    
extrn	LCD_Write_Message, random_numbers, display_clear, second_line, key_control,delay_500ms,smiley
extrn	counter_kp, multiplyRNG1, multiplyRNG2,addRNG1, addRNG2 
extrn	write_rn, rn_one, write_one, input_answer,h2d_16bit, h2d_hex_high, h2d_hex_low, call_random_no
global	game_setup

psect	udata_acs   ; reserve data space in access ram
keys_pressed:    ds 1    ; reserve one byte for a counter variable
rn_array_pointer:ds 1    ; reserve one byte for counter in the delay routine
question_no: ds 1
user_answer:   ds   4
four:	    ds  1
game:	    ds  1
ca_count:	ds 1
score:	    ds  1  
    
psect	udata_bank4 ; reserve data anywhere in RAM (here at 0x400)
myArrayMG:    ds 0xA ; reserve 128 bytes for message data

psect	MG_code, class= CODE	
	
game_setup: 	
	movwf	game, A
	call	display_clear
	movlw	0x0
	movwf	rn_array_pointer, A
	movwf	score, A
		
	lfsr	0, random_numbers
	movlw	0x1
	movwf	question_no, A
	
game_lp:	
	movlw	0x0
	movwf	keys_pressed, A
	movlw	0x4
	movwf	four, A
	
	movlw	0x2
	call	delay_500ms
    
	;lfsr	2, LCD_variable
	call	display_clear
	
	movlw	0x30
	addwf	question_no, 0, 1
	call	write_one

	
	movlw	0x2E
	call	write_one

	movlw	0x20
	call	write_one

	call	write_rn
	call	write_rn
	
	movlw	0x2
	cpfslt	game
	call	add_sign
	movlw	0x1
	cpfsgt	game
	call	multi_sign

	call	write_rn
	call	write_rn
	
	movlw	0x3D
	call	write_one
	
	lfsr	1, user_answer
	call	input_answer
	call	test
	incf	question_no
	movlw	0x4
	cpfseq	question_no
	bra	game_lp
	movf	score, W
	return

multi_sign:
	movlw	0x78
	call	write_one
	return
add_sign:
	movlw	0x2B
	call	write_one
	return		
test:
	movlw	0x2
	cpfslt	game
	call	add_test
	movlw	0x1
	cpfsgt	game
	call	multiply_test	
	call	test2
	return
	
add_test:
	movf	rn_array_pointer, W
	call	addRNG1
	incf	rn_array_pointer
	movf	rn_array_pointer, W
	call	addRNG2
	incf	rn_array_pointer
	call	h2d_hex_low
	movlw	0x00
	call	h2d_hex_high
	call	h2d_16bit
	return 
	
multiply_test:
	movf	rn_array_pointer, W
	call	multiplyRNG1
	incf	rn_array_pointer
	movf	rn_array_pointer, W
	call	multiplyRNG2
	incf	rn_array_pointer
	movf	PRODH, W, A
	call	h2d_hex_high
	movf	PRODL, W, A
	call	h2d_hex_low
	call	h2d_16bit
	return
	
test2:
	lfsr	2, user_answer
	movlw	0x0
	cpfseq	INDF1
	bra	counter_calc
	movlw	0x0
	addwf	POSTINC1
	incf	keys_pressed, F, A
	bra	test2
counter_calc:
	movf	keys_pressed, W, A
	subwf	four, F, A
	movff	four, keys_pressed
test2lp:	
	movf	POSTINC2, W
	cpfseq	POSTINC1
	bra	fail
	decfsz	keys_pressed
	bra	test2lp
	bra	success
	
fail:	
	movlw	0x4
	movwf	ca_count, A
	call	correct_answer
	call	smiley
	movlw	0x3A
	call	write_one
	movlw	0x28
	call	write_one
	movlw	0x8
	call	delay_500ms
	return
	
success:
	call	smiley
	movlw	0x3A
	call	write_one
	movlw	0x29
	call	write_one
	movlw	0x2
	call	delay_500ms
	incf	score, F , A
	return
	
correct_answer:
	call	second_line
	call	call_random_no
ca_lp1:	tstfsz	INDF1
	bra	ca_lp2
	movlw	0x0
	addwf	POSTINC1, F, A
	decfsz	ca_count, A
	bra	ca_lp1
ca_lp2:	movlw	0x30
	addwf	POSTINC1, W, A
	call	write_one
	decfsz	ca_count, A
	bra	ca_lp2
	return
	
	



