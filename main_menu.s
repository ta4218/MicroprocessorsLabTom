#include <xc.inc>

extrn	LCD_Write_Message, second_line, cursor_off, display_clear
global	menu_setup, combined_input

psect	udata_bank4 ; reserve data anywhere in RAM (here at 0x400)
array:	    ds	0x80

psect	udata_acs   ; reserve data space in access ram
menu_counter:    ds 1
    
psect	data    
; ******* myTable, data in programme memory, and its length *****
welcome_message:
	db	'<', '<', '<', ' ', 'P', 'I', 'C', ' ', 'Y', 'O', 'U', 'R', ' ', '>', '>', '>'
	db	'<', '<', '<', '<', ' ', 'B', 'R', 'A', 'I', 'N', 'S', ' ', '>', '>', '>', '>'
	db	'<', ' ', 'G', 'A', 'M', 'E', ' ', 'S', 'E', 'L', 'E', 'C', 'T', ':', ' ', '>'
	db	'<', ' ', 'P', 'R', 'E', 'S', 'S', ' ', '1', ' ', 'O', 'R', ' ', '2', ' ', '>'
	db	'<', ' ', '1', ' ', '=', ' ', 'M', 'U', 'L', 'T', 'I', 'P', 'L', 'Y', ' ', '>'
	db	'<', ' ', '2', ' ', '=', ' ', 'A', 'D', 'D', 'I', 'T', 'I', 'O', 'N', ' ', '>', 0xa
					; message, plus carriage return
	align	2
					; message, plus carriage return
	table_length   EQU	11	; length of data

psect	code, abs

; ******* Main Menu Construction ****************************************	
menu_setup:
	lfsr	0, array	; Load FSR0 with address in RAM	
	movlw	low highword(welcome_message)	; address of data in PM
	movwf	TBLPTRU, A		; load upper bits to TBLPTRU
	movlw	high(welcome_message)	; address of data in PM
	movwf	TBLPTRH, A		; load high byte to TBLPTRH
	movlw	low(welcome_message)	; address of data in PM
	movwf	TBLPTRL, A		; load low byte to TBLPTRL
	movlw	0x20
	movwf	menu_counter, 0
menu_loop: 	
	tblrd*+			; one byte from PM to TABLAT, increment TBLPRT
	movff	TABLAT, INDF0; move data from TABLAT to (FSR0), inc FSR0	
	decfsz	menu_counter, A		; count down to zero
	bra	menu_loop		; keep going until finished
	
	;movlw	0x11	; output message to LCD
	movlw	table_length	; output message to LCD	
	addlw	0xff		; don't send the final carriage return to LCD
	lfsr	2, array
	call	LCD_Write_Message
	
	call	second_line
	movlw	0x11
	addlw	0xff
	call	LCD_Write_Message
	call	cursor_off
	
	
	; ******** Game Select Construction *************************************
game_select:
	call	display_clear
	movlw	0x11
	addlw	0xff
	call	LCD_Write_Message
	
	;need interrupt
	
	call	second_line
	movlw	0x11
	addlw	0xff
	call	LCD_Write_Message
	call	cursor_off
	
	;need 10 SECOND DELAY
	
	call	display_clear
	movlw	0x11
	addlw	0xff
	call	LCD_Write_Message
	
	;need 5 second delay
	
	call	second_line
	movlw	0x11
	addlw	0xff
	call	LCD_Write_Message
	call	cursor_off
	
	return
	
	



