#include <xc.inc>
    
extrn	LCD_Write_Message, cursor_off, random_numbers, display_clear, key_control, key_control_noclr,delay_1s
extrn	counter_kp, addRNG1, addRNG2, h2d_16bitadd 
global	add_game

psect	udata_acs   ; reserve data space in access ram
counter_keyinput:    ds 1    ; reserve one byte for a counter variable
question_no: ds 1
LCD_variable_add:  ds 1
user_answer_add:   ds   3
score_add:	    ds  1
rn_array_pointer:   ds	1
add_answer:	    ds  1
fouradd:	    ds  1
    
psect	udata_bank4 ; reserve data anywhere in RAM (here at 0x400)


    
psect	MG_code, class= CODE	
	
add_game: 	
	movlw	0x0
	movwf	score_add, A
	movwf   rn_array_pointer, A
	lfsr	0, random_numbers
	
	movlw	0x1
	movwf	question_no, A
	
addgamelp:
    
	movlw	0x0
	movwf	counter_keyinput, A
	movlw	0x4
	movwf	fouradd, A
	call	delay_1s
    
	lfsr	2, LCD_variable_add
	call	display_clear
	
	movlw	0x30
	addwf	question_no, 0, 1
	call	write_oneadd

	
	movlw	0x2E
	call	write_oneadd

	movlw	0x20
	call	write_oneadd

	call	write_rnadd
	call	write_rnadd
	
	movlw	0x2B
	call	write_oneadd

	call	write_rnadd
	call	write_rnadd
	
	movlw	0x3D
	call	write_oneadd
	
	lfsr	1, user_answer_add
	call	input_answer_add	
	incf	question_no
	movlw	0x4
	cpfseq	question_no
	bra	addgamelp
	movf	score_add, W
	return
	
write_rnadd:
	call	rn_oneadd
	movlw	0x1
	call	LCD_Write_Message
	return
rn_oneadd:
	movff	POSTINC0, INDF2
	return
write_oneadd:
	lfsr	2, LCD_variable_add
	movwf	INDF2, A
	movlw	0x1
	call	LCD_Write_Message
	return
	
input_answer_add:
	call	key_control_noclr
	
	call	delay_1s
	
	movlw	0x3E
	cpfseq	counter_kp
	bra	ia_lpadd
	call	testa
	return
	
ia_lpadd:	
	movlw	0x30
	subwf	counter_kp
	movff	counter_kp, POSTINC1
	bra	input_answer_add
	
testa:
	;lfsr	2, user_answer_add
	call    add_test
	call	add_test2
	return
 add_test:
	movf	rn_array_pointer, W
	
	call	addRNG1
	incf	rn_array_pointer
	movf	rn_array_pointer, W
	call	addRNG2
	incf	rn_array_pointer
	;movwf	INDF0, A
	;lfsr	2, add_answer
	call	h2d_16bitadd
	return   

add_test2:
	lfsr	2, user_answer_add
	movlw	0x0
	cpfseq	INDF1
	bra	counter_calc_add
	movlw	0x0
	addwf	POSTINC1
	incf	counter_keyinput, A
	bra	add_test2

counter_calc_add:
	movf	counter_keyinput, W, A
	subwf	fouradd, F, A
	movff	fouradd, counter_keyinput

add_test3:	
	movf	POSTINC2, W
	cpfseq	POSTINC1
	bra	failadd
	decfsz	counter_keyinput
	bra	add_test3
	bra	successadd
	;return
	
failadd:
	movlw	0xff
	clrf	TRISF
	clrf	LATF
	movwf	LATF, A
	return
	;goto	xd1
	goto	$
	
successadd:
	movlw	0x10
	clrf	TRISF
	clrf	LATF
	movwf	LATF, A
	incf	score_add, 1 , 0
	return
	;goto	xd1
	goto	$
	
	
	
    
	

	
	
	
    
	




