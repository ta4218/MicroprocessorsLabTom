#include <xc.inc>

extrn	UART_Setup, UART_Transmit_Message  ; external subroutines
extrn	LCD_Setup, LCD_Write_Message, LCD_delay_ms
extrn	keypad_setup, get_key, counter_kp
	
psect	udata_acs   ; reserve data space in access ram
counter:    ds 1    ; reserve one byte for a counter variable
delay_count:ds 1    ; reserve one byte for counter in the delay routine
    
psect	udata_bank4 ; reserve data anywhere in RAM (here at 0x400)
myArray:    ds 0x80 ; reserve 128 bytes for message data

psect	data    
	; ******* myTable, data in programme memory, and its length *****
myTable:
	db	'0','1','2','3','4','5','6','7','8','9','A','B','C','D','E','F', 0x0a
					; message, plus carriage return
	myTable_l   EQU	1	; length of data
	align	2
    
psect	code, abs	
rst: 	org 0x0
 	goto	setup

	; ******* Programme FLASH read Setup Code ***********************
setup:	bcf	CFGS	; point to Flash program memory  
	bsf	EEPGD 	; access Flash program memory
	;call	UART_Setup	; setup UART
	call	LCD_Setup	; setup UART
	call	keypad_setup
	goto	start
	
	; ******* Main programme ****************************************
start: 	
	call	get_key
	
	;lfsr	0, myArray	; Load FSR0 with address in RAM	
	;movlw	low highword(myTable)	; address of data in PM
	;movwf	TBLPTRU, A		; load upper bits to TBLPTRU
	;movlw	high(myTable)	; address of data in PM
	;movwf	TBLPTRH, A		; load high byte to TBLPTRH
	;movlw	low(myTable)	; address of data in PM
	;movwf	TBLPTRL, A		; load low byte to TBLPTRL
 	;tblrd*+			; one byte from PM to TABLAT, increment TBLPRT
	;movff	TABLAT, INDF0; move data from TABLAT to (FSR0), inc FSR0	
	;decfsz	counter_kp, A		; count down to zero
	;bra	loop		; keep going until finished
		
	;movlw	myTable_l	; output message to UART
	;lfsr	2, myArray
	;call	UART_Transmit_Message
	
	movlw	1	; output message to LCD
	;addlw	0xff		; don't send the final carriage return to LCD	
	;lfsr	2, myArray
	call	LCD_Write_Message
	
	
	goto	start
	
	

	goto	$		; goto current line in code

	; a delay subroutine if you need one, times around loop in delay_count
delay:	decfsz	delay_count, A	; decrement until zero
	bra	delay
	return

	end	rst
	
extrn	DAC_Setup, DAC_Int_Hi

psect	code, abs
rst:	org	0x0000	; reset vector
	goto	start

int_hi:	org	0x0008	; high vector, no low vector
	goto	DAC_Int_Hi
	
start:	call	DAC_Setup
	goto	$	; Sit in infinite loop

	end	rst