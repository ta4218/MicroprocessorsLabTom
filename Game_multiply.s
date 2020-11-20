#include <xc.inc>
    
extrn	LCD_Write_Message, cursor_off, random_numbers, display_clear, key_control, key_control_noclr,delay_1s
extrn	counter_kp, multiplyRNG1, multiplyRNG2, h2d_16bit    
global	Multiplygame_1

psect	udata_acs   ; reserve data space in access ram
counterMG:    ds 1    ; reserve one byte for a counter variable
delay_count:ds 1    ; reserve one byte for counter in the delay routine
table_counter: ds 1
LCD_variable:  ds 1
user_answer:   ds   4
ia_count:	ds  1
rng_count:	ds  1
score:	    ds  1
    
psect	udata_bank4 ; reserve data anywhere in RAM (here at 0x400)
myArrayMG:    ds 0xA ; reserve 128 bytes for message data

    
psect	MG_code, class= CODE	
	
Multiplygame_1: 	
	movlw	0x0
	movwf	delay_count, A
	movwf	counterMG, A
loop_game1: 
	
	lfsr	0, random_numbers
	
	movlw	0x1
	movwf	table_counter, A
	
xd:	call	delay_1s
    
	lfsr	2, LCD_variable
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
xd1:	incf	table_counter
	movlw	0x6
	cpfseq	table_counter
	bra	xd
	goto	$
	
write_rn:
	call	rn_one
	movlw	0x1
	call	LCD_Write_Message
	return
rn_one:
	movff	POSTINC0, INDF2
	return
write_one:
	movwf	INDF2, A
	movlw	0x1
	call	LCD_Write_Message
	return
	
input_answer:
	call	key_control_noclr
	
	call	delay_1s
	
	movlw	0x3E
	cpfseq	counter_kp
	goto	ia_lp
	call	test
	return
	
ia_lp:	movlw	0x30
	subwf	counter_kp
	movff	counter_kp, POSTINC1
	incf	counterMG
	goto	input_answer
	
test:
	call	multiply_test
	goto	test2
	
	
multiply_test:
	movf	delay_count, W
	
	call	multiplyRNG1
	incf	delay_count
	movf	delay_count, W
	call	multiplyRNG2
	incf	delay_count
	call	h2d_16bit
	return
	
test2:
	lfsr	2, user_answer
	movlw	0x0
	cpfseq	INDF1
	goto	test2lp
	addwf	POSTINC1
	bra	test2
test2lp:	
	movf	POSTINC2, W
	cpfseq	POSTINC1
	goto	fail
	decfsz	counterMG
	bra	test2lp
	goto	success
	;return
	
fail:
	movlw	0xff
	clrf	TRISF, A
	clrf	LATF, A
	movwf	LATF, A
	goto	xd1
	goto	$
	
success:
	movlw	0x10
	clrf	TRISF, A
	clrf	LATF, A
	movwf	LATF, A
	incf	score
	goto	xd1
	goto	$
	
