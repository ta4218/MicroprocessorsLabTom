#include <xc.inc>

global  LCD_Setup, LCD_Write_Message, second_line, LCD_Send_Byte_I, cursor_off
global	write_rn, rn_one, write_one, display_clear, LCD_delay_ms, delay_500ms, smiley
    
extrn	key_control
    
psect	udata_acs   ; named variables in access ram
	
LCD_cnt_l:	ds 1	; reserve 1 byte for variable LCD_cnt_l
LCD_cnt_h:	ds 1	; reserve 1 byte for variable LCD_cnt_h
LCD_cnt_ms:	ds 1	; reserve 1 byte for ms counter
LCD_tmp:	ds 1	; reserve 1 byte for temporary use
LCD_counter:	ds 1	; reserve 1 byte for counting through nessage
count_500ms:	ds 1	; reserve 1 byte for delay_1s
LCD_variable:	ds 1	; reserve 1 byte for temporary use

	LCD_E	EQU 5	; LCD enable bit
    	LCD_RS	EQU 4	; LCD register select bit

psect	lcd_code,class=CODE
	
	; ******************* LCD SETUP ***************************************
    
LCD_Setup:
	clrf    LATB, A
	movlw   11000000B	; RB0:5 all outputs
	movwf	TRISB, A
	movlw   40
	call	LCD_delay_ms	; wait 40ms for LCD to start up properly
	movlw	00110000B	; Function set 4-bit
	call	LCD_Send_Byte_I
	movlw	10		; wait 40us
	call	LCD_delay_x4us
	movlw	00101000B	; 2 line display 5x8 dot characters
	call	LCD_Send_Byte_I
	movlw	10		; wait 40us
	call	LCD_delay_x4us
	movlw	00101000B	; repeat, 2 line display 5x8 dot characters
	call	LCD_Send_Byte_I
	movlw	10		; wait 40us
	call	LCD_delay_x4us
	movlw	00001111B	; display on, cursor on, blinking on
	call	LCD_Send_Byte_I
	movlw	10		; wait 40us
	call	LCD_delay_x4us
	movlw	00000001B	; display clear
	call	LCD_Send_Byte_I
	movlw	2		; wait 2ms
	call	LCD_delay_ms
	movlw	00000110B	; entry mode incr by 1 no shift
	call	LCD_Send_Byte_I
	movlw	10		; wait 40us
	call	LCD_delay_x4us
	return
	
	; ********************* LCD FUNCTIONS *********************************

LCD_Write_Message:		; Message stored at FSR2, length stored in W
	movwf   LCD_counter, A
LCD_Loop_message:
	movf    POSTINC2, W, A
	call    LCD_Send_Byte_D
	decfsz  LCD_counter, A
	bra	LCD_Loop_message
	return

LCD_Send_Byte_I:		; Transmits byte stored in W to instruction reg
	movwf   LCD_tmp, A
	swapf   LCD_tmp, W, A   ; swap nibbles, high nibble goes first
	andlw   0x0f		; select just low nibble
	movwf   LATB, A		; output data bits to LCD
	bcf	LATB, LCD_RS, A	; Instruction write clear RS bit
	call    LCD_Enable	; Pulse enable Bit 
	movf	LCD_tmp, W, A   ; swap nibbles, now do low nibble
	andlw   0x0f		; select just low nibble
	movwf   LATB, A		; output data bits to LCD
	bcf	LATB, LCD_RS, A	; Instruction write clear RS bit
        call    LCD_Enable	; Pulse enable Bit 
	return

LCD_Send_Byte_D:		; Transmits byte stored in W to data reg
	movwf   LCD_tmp, A
	swapf   LCD_tmp, W, A	; swap nibbles, high nibble goes first
	andlw   0x0f		; select just low nibble
	movwf   LATB, A		; output data bits to LCD
	bsf	LATB, LCD_RS, A	; Data write set RS bit
	call    LCD_Enable	; Pulse enable Bit 
	movf	LCD_tmp, W, A	; swap nibbles, now do low nibble
	andlw   0x0f		; select just low nibble
	movwf   LATB, A		; output data bits to LCD
	bsf	LATB, LCD_RS, A	; Data write set RS bit	    
        call    LCD_Enable	; Pulse enable Bit 
	movlw	10		; delay 40us
	call	LCD_delay_x4us
	return

LCD_Enable:			; pulse enable bit LCD_E for 500ns
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	bsf	LATB, LCD_E, A	; Take enable high
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	bcf	LATB, LCD_E, A	; Writes data to LCD
	return
    
delay_500ms:
	movwf	count_500ms, A	; a routine for 500ms delay
d1slp:	movlw	250
	call	LCD_delay_ms
	decfsz	count_500ms, A
	bra	d1slp
	return
	
	
	; ** a few delay routines below here as LCD timing can be quite critical ****
	
	
LCD_delay_ms:			; delay given in ms in W
	movwf	LCD_cnt_ms, A
lcdlp2:	movlw	250		; 1 ms delay
	call	LCD_delay_x4us	
	decfsz	LCD_cnt_ms, A
	bra	lcdlp2
	return
    
LCD_delay_x4us:			; delay given in chunks of 4 microsecond in W
	movwf	LCD_cnt_l, A	; now need to multiply by 16
	swapf   LCD_cnt_l, F, A	; swap nibbles
	movlw	0x0f	    
	andwf	LCD_cnt_l, W, A ; move low nibble to W
	movwf	LCD_cnt_h, A	; then to LCD_cnt_h
	movlw	0xf0	    
	andwf	LCD_cnt_l, F, A ; keep high nibble in LCD_cnt_l
	call	LCD_delay
	return

LCD_delay:			; delay routine	4 instruction loop == 250ns	    
	movlw 	0x00		; W=0
lcdlp1:	decf 	LCD_cnt_l, F, A	; no carry when 0x00 -> 0xff
	subwfb 	LCD_cnt_h, F, A	; no carry when 0x00 -> 0xff
	bc 	lcdlp1		; carry, then loop again
	return			; carry reset so return

	
	; ********** CURSOR MOVEMENT AND GENERAL LCD FUNCTIONS ***************
	
	
second_line:
        movlw   0011000000B	; set DDRAM address to 40h so it is on second line
	call    LCD_Send_Byte_I
	movlw   10
	call    LCD_delay_x4us
        return
    
cursor_off:
	movlw	000001100B	; display on, cursor off, blinking off
	call	LCD_Send_Byte_I
	movlw	10		; wait 40us
	call	LCD_delay_x4us
	return

display_clear:
	movlw	00000001B	; display clear
	call	LCD_Send_Byte_I
	movlw	2		; wait 2ms
	call	LCD_delay_ms
	return
	
smiley:
	movlw	0011001110B	; sets DDRAM address to right bottom of screen
	call	LCD_Send_Byte_I
	movlw	10
	call	LCD_delay_x4us	; wait 40us
	return

write_rn:
	call	rn_one		; used to write one random number digit to LCD
	movlw	0x1
	call	LCD_Write_Message
	return	
	
rn_one:
	movff	POSTINC0, INDF2	; character at FSR0 moved to FSR2 and FSR0 incremented
	return
	
write_one:
	lfsr	2, LCD_variable	; used to write one character to LCD
	movwf	INDF2, A
	movlw	0x1
	call	LCD_Write_Message
	return
	