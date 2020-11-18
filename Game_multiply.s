#include <xc.inc>
    
extrn	LCD_Write_Message, cursor_off, deci2
    
global	Multiplygame_1

psect	udata_acs   ; reserve data space in access ram
counterMG:    ds 1    ; reserve one byte for a counter variable
delay_count:ds 1    ; reserve one byte for counter in the delay routine
table_counter: ds 1
    
psect	udata_bank4 ; reserve data anywhere in RAM (here at 0x400)
myArrayMG:    ds 0x30 ; reserve 128 bytes for message data

psect	data    
	; ******* myTable, data in programme memory, and its length *****
myTableMG:
	db	'1','.',' ','x',' ','=',' '
	db	'2','.',' ','x',' ','=',' '
	db	'3','.',' ','x',' ','=',' '
	db	'4','.',' ','x',' ','=',' '
	db	'5','.',' ','x',' ','=',' ', 0xa
					; message, plus carriage return
	myTableMG_1   EQU	 0x36	; length of data
	align	2

psect	MG_code, class= CODE	
	
Multiplygame_1: 	
	lfsr	0, myArrayMG	; Load FSR0 with address in RAM
	movlw	low highword(myTableMG)	; address of data in PM
	movwf	TBLPTRU, A		; load upper bits to TBLPTRU
	movlw	high(myTableMG)	; address of data in PM
	movwf	TBLPTRH, A		; load high byte to TBLPTRH
	movlw	low(myTableMG)	; address of data in PM
	movwf	TBLPTRL, A		; load low byte to TBLPTRL
	movlw	myTableMG_1	; bytes to read
	movwf 	counterMG, A		; our counter register
	
loop_game1: 	
	tblrd*+			; one byte from PM to TABLAT, increment TBLPRT
	movff	TABLAT, POSTINC0; move data from TABLAT to (FSR0), inc FSR0	
	decfsz	counterMG, A		; count down to zero
	bra	loop_game1		; keep going until finished
	
	lfsr	0, myArrayMG
	movlw	0x3	; output message to LCD
	lfsr	2, myArrayMG
	call	LCD_Write_Message
	lfsr    2, deci2    ;load FSR0 with adress in RAM
	movlw	0x2
	call	LCD_Write_Message
	lfsr	2, myArrayMG
	incf	INDF2
	movlw	0x1
	call	LCD_Write_Message
	return
	

	
