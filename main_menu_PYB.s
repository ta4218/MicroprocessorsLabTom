#include <xc.inc>
    
extrn	LCD_Setup, LCD_Write_Message, second_line, LCD_Send_Byte_I, cursor_off
extrn	write_one, delay_500ms, display_clear
    
global	start_logo, game_select, result_LCD
 
   
psect	udata_acs	; reserve data space in access ram
	
counter:	ds 1    ; reserve one byte for a counter variable
delay_count:	ds 1    ; reserve one byte for counter in the delay routine
score_total:	ds 1	; reserve one byte for score total variable
result_print:	ds 1	; reserve one byte for temporary score variable
result_index:	ds 1	; reserve one byte for table counter
rltlp_count:	ds 1	; reserve one byte for character count
    
psect	udata_bank4	; reserve data anywhere in RAM (here at 0x400)
myArray:	ds 0x80 ; reserve 128 bytes for message data

psect	data    
	; ******* myTable, data in programme memory, and its length ***********
myTable:
	db	'<', '<', '<', ' ', 'P', '!', 'C', ' ', 'Y', 'O', 'U', 'R', ' ', '>', '>', '>'
	db	'<', '<', '<', '<', ' ', 'B', 'R', 'A', '!', 'N', 'S', ' ', '>', '>', '>', '>'
	db	'<', ' ', 'G', 'A', 'M', 'E', ' ', 'S', 'E', 'L', 'E', 'C', 'T', ':', ' ', '>'
	db	'<', ' ', 'P', 'R', 'E', 'S', 'S', ' ', '1', ' ', 'O', 'R', ' ', '2', ' ', '>'
	db	'<', ' ', '1', ' ', '=', ' ', 'M', 'U', 'L', 'T', 'I', 'P', 'L', 'Y', ' ', '>'
	db	'<', ' ', '2', ' ', '=', ' ', 'A', 'D', 'D', 'I', 'T', 'I', 'O', 'N', ' ', '>' 
	db	'Y', 'O', 'U', ' ', 'S', 'C', 'O', 'R', 'E', 'D', ' ', 0xa
				; message, plus carriage return
	myTable_l   EQU	 0x6C	; length of data
	align	2

psect	menu_code, class= CODE	
	
	;***************** LOGO AND MAIN MENU SCREEN **************************
	
	
start_logo: 	
	lfsr	0, myArray		; Load FSR0 with address in RAM
	movlw	low highword(myTable)	; address of data in PM
	movwf	TBLPTRU, A		; load upper bits to TBLPTRU
	movlw	high(myTable)		; address of data in PM
	movwf	TBLPTRH, A		; load high byte to TBLPTRH
	movlw	low(myTable)		; address of data in PM
	movwf	TBLPTRL, A		; load low byte to TBLPTRL
	movlw	myTable_l		; bytes to read
	movwf 	counter, A		; our counter register
	
loop: 	tblrd*+				; one byte from PM to TABLAT, increment TBLPRT
	movff	TABLAT, POSTINC0	; move data from TABLAT to (FSR0), inc FSR0	
	decfsz	counter, A		; count down to zero
	bra	loop			; keep going until finished
		
	movlw	0x11			; output message to LCD
	addlw	0xff			; don't send the final carriage return to LCD
	lfsr	2, myArray		; point FSR2 at myArray address
	call	LCD_Write_Message	
	call	second_line		; move cursor to second line
	movlw	0x11
	addlw	0xff
	call	LCD_Write_Message	; write second line
	call	cursor_off		; turn cursor off
	return
	

	; ******** Game Select Construction ***********************************
	
	
game_select:
	call	display_clear		; clear the screen
	movlw	0x11			; output first line to LCD
	addlw	0xff
	call	LCD_Write_Message
	
	call	second_line		; move cursor to second line
	movlw	0x11			; output second line to LCD
	addlw	0xff
	call	LCD_Write_Message
	call	cursor_off
	
	movlw	0x8
	call	delay_500ms		; a 4s delay is called
	
	call	display_clear		; clear the LCD
	movlw	0x11			; move first line of menu selection to LCD
	addlw	0xff
	call	LCD_Write_Message
	
	
	call	second_line
	movlw	0x11
	addlw	0xff
	call	LCD_Write_Message	; move second line of menu selection to LCD
	call	cursor_off
	return
	
	
	; ************** SCORE SCREEN *****************************************
	
	
result_LCD:
	movwf	score_total, A		; loads score_total with the player's score
	call	display_clear
	lfsr	2, myArray
	movlw	0x60
	movwf	result_index, A		; variable needed to index myArray for ASCII
	movlw	0xB
	movwf	rltlp_count, A		; set how many letters we want moved, here its 11 for 'you scored '
	
rltlp:	movf	result_index, W
	movff	PLUSW2, result_print	; moves the start address of 'YOU SCORED ' to result_print
	lfsr	2, result_print
	movlw	0x1			; writes first letter of statement to LCD
	call	LCD_Write_Message
	lfsr	2, myArray		; reset FSR2
	incf	result_index		; increment the position we want into myArray
	decfsz	rltlp_count		; decrement the counter of number of letters we want moved, skip next instruction if 0
	bra	rltlp			; branch back for next letter
	
	movlw	0x30
	addwf	score_total, 0, 0	; turn score into ASCII
	call	write_one
	
	movlw	0x2f			; ASCII for /
	call	write_one		; write to LCD
	
	movlw	0x35			; ASCII code for 5
	call	write_one		; write to LCD
	call	cursor_off
	movlw	0x8
	call	delay_500ms		; 4s delay called
	return


