#include <xc.inc>

extrn	LCD_Setup, LCD_Write_Message, second_line, LCD_Send_Byte_I, cursor_off, display_clear
extrn	start_keypad, keypad_setup, DAC_Setup, DAC_Int_Hi, get_key, twofivefive, combined_input
	
psect	udata_acs   ; reserve data space in access ram
counter:    ds 1    ; reserve one byte for a counter variable
delay_count:ds 1    ; reserve one byte for counter in the delay routine
    
psect	udata_bank4 ; reserve data anywhere in RAM (here at 0x400)
myArray:    ds 0x80 ; reserve 128 bytes for message data

psect	data    
	; ******* myTable, data in programme memory, and its length *****
myTable:
	db	'<', '<', '<', ' ', 'P', 'I', 'C', ' ', 'Y', 'O', 'U', 'R', ' ', '>', '>', '>'
	db	'<', '<', '<', '<', ' ', 'B', 'R', 'A', 'I', 'N', 'S', ' ', '>', '>', '>', '>'
	db	'<', ' ', 'G', 'A', 'M', 'E', ' ', 'S', 'E', 'L', 'E', 'C', 'T', ':', ' ', '>'
	db	'<', ' ', 'P', 'R', 'E', 'S', 'S', ' ', '1', ' ', 'O', 'R', ' ', '2', ' ', '>'
	db	'<', ' ', '1', ' ', '=', ' ', 'M', 'U', 'L', 'T', 'I', 'P', 'L', 'Y', ' ', '>'
	db	'<', ' ', '2', ' ', '=', ' ', 'A', 'D', 'D', 'I', 'T', 'I', 'O', 'N', ' ', '>', 0xa
					; message, plus carriage return
	myTable_l   EQU	 0x61	; length of data
	align	2
	
psect	code, abs	


	; ******* Programme FLASH read Setup Code ***********************
setup:	bcf	CFGS	; point to Flash program memory  
	bsf	EEPGD 	; access Flash program memory
	call	LCD_Setup	; setup UART
	call	keypad_setup
	;goto	start
	
rst: 	org 0x0
	goto	start_interrupt
	; ******* Main Menu Construction ****************************************
start: 	lfsr	0, myArray	; Load FSR0 with address in RAM
	movlw	low highword(myTable)	; address of data in PM
	movwf	TBLPTRU, A		; load upper bits to TBLPTRU
	movlw	high(myTable)	; address of data in PM
	movwf	TBLPTRH, A		; load high byte to TBLPTRH
	movlw	low(myTable)	; address of data in PM
	movwf	TBLPTRL, A		; load low byte to TBLPTRL
	movlw	myTable_l	; bytes to read
	movwf 	counter, A		; our counter register
	
loop: 	;tblrd*+			; one byte from PM to TABLAT, increment TBLPRT
	;movff	TABLAT, POSTINC0; move data from TABLAT to (FSR0), inc FSR0	
	;decfsz	counter, A		; count down to zero
	;bra	loop		; keep going until finished
	call	display_clear
	movlw	0x2
	addlw	0xff
	call	LCD_Write_Message	
	;movlw	0x11	; output message to LCD
	;addlw	0xff		; don't send the final carriage return to LCD
	movlw	0x1
	;lfsr	2, myArray
	call	LCD_Write_Message
	goto	$
	;bra	loop
	;call	second_line
	;movlw	0x11
	;addlw	0xff
	;call	LCD_Write_Message
	;call	cursor_off
	
	;need interrupt here

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
	
	goto	start_interrupt
	

int_hi:	org	0x0008	; high vector, no low vector
	goto	DAC_Int_Hi

start_interrupt:	
	call	DAC_Setup
	movlw	0xff
	cpfslt	combined_input
	goto	$
	goto	loop
	;goto	$	; Sit in infinite loop
	;goto	setup
	end	rst