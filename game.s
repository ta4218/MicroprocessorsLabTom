#include <xc.inc>
    
extrn	LCD_Write_Message, random_numbers, display_clear, second_line, key_control,delay_500ms,smiley
extrn	multiplyRNG1, multiplyRNG2,addRNG1, addRNG2 
extrn	write_rn, rn_one, write_one, input_answer,h2d_16bit, h2d_hex_high, h2d_hex_low, call_random_no
global	game_setup

psect	udata_acs   ; reserve data space in access ram
keys_pressed:    ds 1    ; reserve one byte for a counter variable
rn_array_pointer:ds 1    ; reserve one byte for counter in the delay routine
question_no: ds 1	 ; reserve one byte for question no counter
user_answer:   ds   4	   ; reserve four bytes for each digit of keypad input answer
four:	    ds  1	;reserve one byte for variable 4
game:	    ds  1	; reserve one byte for game selection 
ca_count:	ds 1	; reserve one byte for correct answer count
score:	    ds  1	;reserve one byte for score
    
psect	udata_bank4 ; reserve data anywhere in RAM (here at 0x400)
myArrayMG:    ds 0xA ; reserve 128 bytes for message data

psect	MG_code, class= CODE	
	
game_setup: 	
	movwf	game, A	    ; multiplication = 1, addition = 2
	call	display_clear	; clear the screen
	movlw	0x0		;setup counters
	movwf	rn_array_pointer, A	   ; random number array pointer
	movwf	score, A	; setup score tally
		
	lfsr	0, random_numbers   ;random numbers from generator
	movlw	0x1
	movwf	question_no, A	    ; setup question no count
	
game_lp:	
	movlw	0x0		    ;count for no of keys pressed
	movwf	keys_pressed, A	    ;inside loop so resets
	movlw	0x4
	movwf	four, A		    ; four = 4
	
	movlw	0x2		    ; 1 second delay
	call	delay_500ms
    
	;lfsr	2, LCD_variable
	call	display_clear	    ;clear screen
	
	movlw	0x30		
	addwf	question_no, 0, 1   ;ascii conversion
	call	write_one	    ; write one digit to LCD
	
	
	movlw	0x2E		    ; ascii '.'
	call	write_one	    ; write one digit to LCD

	movlw	0x20		    ;ascii  ' '
	call	write_one	    ; write one digit to LCD

	call	write_rn	    ;write single digit of random number to LCD
	call	write_rn	    ;write single digit of random number to LCD
	
	movlw	0x2		    ;determine if "+" or "x" moved to LCD
	cpfslt	game, A		    
	call	add_sign	    ; if game = 2
	movlw	0x1
	cpfsgt	game, A		    ;if game = 1
	call	multi_sign

	call	write_rn	    ;write single digit of random number to LCD
	call	write_rn	    ;write single digit of random number to LCD
	
	movlw	0x3D		    ; '='
	call	write_one	    
	
	lfsr	1, user_answer	    ; store user input by digit
	call	input_answer	    ;waits for answer
	call	test		    ; test if right or wrong
	incf	question_no, A	    ; increment question no
	movlw	0x6		    
	cpfseq	question_no, A		
	bra	game_lp		    ; skip loop if 5 rounds played
	movf	score, W, A	    ; move score to w for to display score
	return

multi_sign:
	movlw	0x78		    ; = 'x'
	call	write_one
	return
add_sign:	
	movlw	0x2B		    ; = '+'
	call	write_one
	return		
test:				    ; go to test based on game
	movlw	0x2	    
	cpfslt	game, A
	call	add_test	    ; if game = 2
	movlw	0x1
	cpfsgt	game, A
	call	multiply_test	    ; if game = 1
	call	test2		    ; both go to second test
	return
	
add_test:
	movf	rn_array_pointer, W, A	    ; set random array pointer
	call	addRNG1			    ; function moves random number to 'vari'
	incf	rn_array_pointer, A	    ; increments to next random number for calculation
	movf	rn_array_pointer, W, A	    
	call	addRNG2			    ; function moves random number to 'vari2' 
	incf	rn_array_pointer, A	    ; increments to next random number for next question
	call	h2d_hex_low		    ;move sum to hex_low
	movlw	0x00
	call	h2d_hex_high		    ; 2 digit number so move 0 to hex_high
	call	h2d_16bit		    ; convert to decimal
	return 
	
multiply_test:
	movf	rn_array_pointer, W, A	    ; set random array pointer
	call	multiplyRNG1		    ; function moves random number to 'vari'
	incf	rn_array_pointer, A	    ; increments to next random number for calculation
	movf	rn_array_pointer, W, A	    
	call	multiplyRNG2		    ; function moves random number to 'vari2' 
	incf	rn_array_pointer, A	    ; increments to next random number for next question
	movf	PRODH, W, A		    ; move upper byte to hex_high
	call	h2d_hex_high
	movf	PRODL, W, A		    ; move lower byte to hex_high
	call	h2d_hex_low	
	call	h2d_16bit		    ; convert to decimal
	return
	
test2:
	lfsr	2, user_answer		    ;set FSR2 to user_answer as correct 
	movlw	0x0			    ;answer is in FSR1
	cpfseq	INDF1, A		    ;compare for redunadnt zeros
	bra	counter_calc	; calculates numebr of numbers to iterate over
	movlw	0x0
	addwf	POSTINC1, A		  ;increments pointer to test for more zeros
	incf	keys_pressed, F, A	    ; increment number of zeros found
	bra	test2			    
counter_calc:
	movf	keys_pressed, W, A	    ; moves number of zeros to w
	subwf	four, F, A		    ; take numebr of zeros from 4 
	movff	four, keys_pressed	;result is number of digits in calculated anwser
test2lp:	
	movf	POSTINC2, W, A		; compare FSR2 with FSR1
	cpfseq	POSTINC1, A
	bra	fail			; goto fail immediately if wrong
	decfsz	keys_pressed, A		; loop until all digits compared
	bra	test2lp	
	bra	success			; goto sucess if all digits correct
	
fail:	
	movlw	0x4
	movwf	ca_count, A		; set counter for correct_answer
	call	correct_answer		; move correct answer to LCD
	call	smiley			; shift DDRAM address to bottom right
	movlw	0x3A			;  sad face
	call	write_one	
	movlw	0x28			
	call	write_one
	movlw	0x8			; 4 second delay
	call	delay_500ms
	return
	
success:
	call	smiley		    ; shift DDRAM address to bottom right
	movlw	0x3A		    ; HAPPY FACE
	call	write_one
	movlw	0x29
	call	write_one
	movlw	0x2
	call	delay_500ms	    ; 1 second delay
	incf	score, F , A		;increment score
	return
	
correct_answer:
	call	second_line	    ; write to second lime
	call	call_random_no	    ; sets deci to FSR1
ca_lp1:	tstfsz	INDF1, A	    ; test for zeros
	bra	ca_lp2		    ; move digit to LCD if no zero found
	movlw	0x0
	addwf	POSTINC1, F, A	    ; increment pointer to look for next zero
	decfsz	ca_count, A	    ; decrease number of digits to move to LCD
	bra	ca_lp1		; loop until no zeros found
ca_lp2:	movlw	0x30	
	addwf	POSTINC1, W, A		; convert decimals to ascii
	call	write_one	    ; write decimal to LCD
	decfsz	ca_count, A	    ; decraese count for digits to move to LCD
	bra	ca_lp2		    ; loop until all digits moved to LCD
	return
	
	



