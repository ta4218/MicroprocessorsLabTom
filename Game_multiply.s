#include <xc.inc>
    
extrn	
    
global	
    

psect	udata_acs   ; reserve data space in access ram
counterMG:    ds 1    ; reserve one byte for a counter variable
delay_count:ds 1    ; reserve one byte for counter in the delay routine
    
psect	udata_bank4 ; reserve data anywhere in RAM (here at 0x400)
myArrayMG:    ds 0x80 ; reserve 128 bytes for message data

psect	data    
	; ******* myTable, data in programme memory, and its length *****
myTableMG:
	db	'1','.',' ','x',' ','=',' '
	db	'2','.',' ','x',' ','=',' '
	db	'3','.',' ','x',' ','=',' '
	db	'4','.',' ','x',' ','=',' '
	db	'5','.',' ','x',' ','=',' ', 0xa
					; message, plus carriage return
	myTableMG   EQU	 0x36	; length of data
	align	2

psect	MG_code, class= CODE	
	
start_logo: 	
	lfsr	0, myArrayMG	; Load FSR0 with address in RAM
	movlw	low highword(myTableMG)	; address of data in PM
	movwf	TBLPTRU, A		; load upper bits to TBLPTRU
	movlw	high(myTableMG)	; address of data in PM
	movwf	TBLPTRH, A		; load high byte to TBLPTRH
	movlw	low(myTableMG)	; address of data in PM
	movwf	TBLPTRL, A		; load low byte to TBLPTRL
	movlw	myTableMG	; bytes to read
	movwf 	counterMG, A		; our counter register
	
loop: 	tblrd*+			; one byte from PM to TABLAT, increment TBLPRT
	movff	TABLAT, POSTINC0; move data from TABLAT to (FSR0), inc FSR0	
	decfsz	counterMG, A		; count down to zero
	bra	loop		; keep going until finished
		
	movlw	0x3	; output message to LCD
	lfsr	2, myArrayMG
	call	LCD_Write_Message
	lfsr    0, myArray    ;load FSR0 with adress in RAM
	
	
	
	call	cursor_off
	
	return
	
