#include <xc.inc>
    
extrn	LCD_Setup, LCD_Write_Message, second_line, LCD_Send_Byte_I, cursor_off, display_clear, delay_1s
extrn	keypad_setup, DAC_Setup, DAC_Int_Hi, get_key, combined_input
global	start_logo, game_select
psect	udata_acs   ; reserve data space in access ram
counter:    ds 1    ; reserve one byte for a counter variable
delay_count:ds 1    ; reserve one byte for counter in the delay routine
    
psect	udata_bank4 ; reserve data anywhere in RAM (here at 0x400)
myArray:    ds 0x80 ; reserve 128 bytes for message data

psect	data    
	; ******* myTable, data in programme memory, and its length *****
myTable:
	db	'<', '<', '<', ' ', 'P', '!', 'C', ' ', 'Y', 'O', 'U', 'R', ' ', '>', '>', '>'
	db	'<', '<', '<', '<', ' ', 'B', 'R', 'A', '!', 'N', 'S', ' ', '>', '>', '>', '>'
	db	'<', ' ', 'G', 'A', 'M', 'E', ' ', 'S', 'E', 'L', 'E', 'C', 'T', ':', ' ', '>'
	db	'<', ' ', 'P', 'R', 'E', 'S', 'S', ' ', '1', ' ', 'O', 'R', ' ', '2', ' ', '>'
	db	'<', ' ', '1', ' ', '=', ' ', 'M', 'U', 'L', 'T', 'I', 'P', 'L', 'Y', ' ', '>'
	db	'<', ' ', '2', ' ', '=', ' ', 'A', 'D', 'D', 'I', 'T', 'I', 'O', 'N', ' ', '>', 0xa
					; message, plus carriage return
	myTable_l   EQU	 0x61	; length of data
	align	2

psect	menu_code, class= CODE	
	
start_logo: 	
	lfsr	0, myArray	; Load FSR0 with address in RAM
	movlw	low highword(myTable)	; address of data in PM
	movwf	TBLPTRU, A		; load upper bits to TBLPTRU
	movlw	high(myTable)	; address of data in PM
	movwf	TBLPTRH, A		; load high byte to TBLPTRH
	movlw	low(myTable)	; address of data in PM
	movwf	TBLPTRL, A		; load low byte to TBLPTRL
	movlw	myTable_l	; bytes to read
	movwf 	counter, A		; our counter register
	
loop: 	tblrd*+			; one byte from PM to TABLAT, increment TBLPRT
	movff	TABLAT, POSTINC0; move data from TABLAT to (FSR0), inc FSR0	
	decfsz	counter, A		; count down to zero
	bra	loop		; keep going until finished
		
	movlw	0x11	; output message to LCD
	addlw	0xff		; don't send the final carriage return to LCD
	lfsr	2, myArray
	call	LCD_Write_Message
	call	second_line
	movlw	0x11
	addlw	0xff
	call	LCD_Write_Message
	call	cursor_off
	
	return
	
	;need interrupt here

	; ******** Game Select Construction *************************************
game_select:
	call	display_clear
	movlw	0x11
	addlw	0xff
	call	LCD_Write_Message
	
	
	
	call	second_line
	movlw	0x11
	addlw	0xff
	call	LCD_Write_Message
	call	cursor_off
	
	call	delay_1s
	
	call	display_clear
	movlw	0x11
	addlw	0xff
	call	LCD_Write_Message
	
	
	call	second_line
	movlw	0x11
	addlw	0xff
	call	LCD_Write_Message
	call	cursor_off
	
	return


