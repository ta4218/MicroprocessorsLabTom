#include <xc.inc>

extrn	LCD_Write_Message, second_line
global	menu_setup

psect	udata_bank4 ; reserve data anywhere in RAM (here at 0x400)
array:	    ds	0x80

psect	udata_acs   ; reserve data space in access ram
menu_counter:    ds 1
    
psect	data    
	; ******* myTable, data in programme memory, and its length *****
welcome_message:
	db	'*','*','*','*','P','I','C',' ', 'Y','O', 'U', 'R','*','*','*','*'
	db	'*','*','*','*','*','B','R','A','I','N','S','*','*','*','*','*'				
	; message, no carriage return??
	align	2
game_selection:
	db	'0','1','2','3','4','5','6','7','8','9','A','B','C','D','E','F', 0x0a
					; message, plus carriage return
	myTable_l   EQU	1	; length of data
	align	2

psect	code, abs
	
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
	
	
	movlw	0x10	; output message to LCD	
	lfsr	2, array
	call	LCD_Write_Message
	;call	second_line
	;movlw	0x10
	;call	LCD_Write_Message
	return
	
	



