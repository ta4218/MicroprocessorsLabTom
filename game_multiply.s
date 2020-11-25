#include <xc.inc>
    
extrn	LCD_Write_Message, cursor_off, random_numbers, display_clear, key_control, key_control_noclr,delay_1s
extrn	counter_kp, multiplyRNG1, multiplyRNG2, h2d_16bit, second_line, smiley, h2d_hex_high, h2d_hex_low
extrn	write_rn, rn_one, write_one, input_answer 
global	Multiplygame_1

psect	udata_acs   ; reserve data space in access ram
counterMG:    ds 1    ; reserve one byte for a counter variable
delay_count:ds 1    ; reserve one byte for counter in the delay routine
table_counter: ds 1
user_answer:   ds   4
score:	    ds  1
four:	    ds  1

    
psect	udata_bank4 ; reserve data anywhere in RAM (here at 0x400)
myArrayMG:    ds 0xA ; reserve 128 bytes for message data


    
psect	MG_code, class= CODE	
	
Multiplygame_1: 	
	movlw	0x0
	movwf	delay_count, A
	movwf	score, A
	
loop_game1: 
	
	lfsr	0, random_numbers
	
	movlw	0x1
	movwf	table_counter, A
	
xd:	movlw	0x0
	movwf	counterMG, A
	movlw	0x4
	movwf	four, A
	
	call	delay_1s
    
	;lfsr	2, LCD_variable
	call	display_clear
	
	movlw	0x30
	addwf	table_counter, 0, 1
	call	write_one

	
	movlw	0x2E
	call	write_one

	movlw	0x20
	call	write_one

	call	write_rn
	call	write_rn
	
	movlw	0x78
	call	write_one

	call	write_rn
	call	write_rn
	
	movlw	0x3D
	call	write_one
	
	lfsr	1, user_answer
	call	input_answer
	call	test
xd1:	incf	table_counter
	movlw	0x4
	cpfseq	table_counter
	bra	xd
	movf	score, W
	return
	
	
test:
	call	multiply_test
	call	test2
	return
	
	
multiply_test:
	movf	delay_count, W
	
	call	multiplyRNG1
	incf	delay_count
	movf	delay_count, W
	call	multiplyRNG2
	incf	delay_count
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
	incf	counterMG, F, A
	bra	test2
counter_calc:
	movf	counterMG, W, A
	subwf	four, F, A
	movff	four, counterMG
test2lp:	
	movf	POSTINC2, W
	cpfseq	POSTINC1
	bra	fail
	decfsz	counterMG
	bra	test2lp
	bra	success
	;return
	
fail:	
	call	smiley
	movlw	0x3A
	call	write_one
	movlw	0x28
	call	write_one
	call	delay_1s
	
	return
	
success:
	call	smiley
	movlw	0x3A
	call	write_one
	movlw	0x29
	call	write_one
	call	delay_1s
	incf	score, 1 , 0
	return
	
	
	
    
	
