#include <xc.inc>

extrn	LCD_Setup, LCD_Write_Message, second_line, LCD_Send_Byte_I 
extrn	start_keypad, keypad_setup, DAC_Setup, DAC_Int_Hi, get_key, twofivefive, combined_input, menu_setup
	
psect	udata_acs   ; reserve data space in access ram
counter:    ds 1    ; reserve one byte for a counter variable
delay_count:ds 1    ; reserve one byte for counter in the delay routine

psect	code, abs	


	; ******* Programme FLASH read Setup Code ***********************
setup:	bcf	CFGS	; point to Flash program memory  
	bsf	EEPGD 	; access Flash program memory
	call	LCD_Setup	; setup UART
	call	keypad_setup
	goto	start
	
start:
	call	menu_setup
	
rst: 	org 0x0
	goto	start_interrupt

int_hi:	org	0x0008	; high vector, no low vector
	goto	DAC_Int_Hi

start_interrupt:	
	call	DAC_Setup
test:	movlw	0xff
	cpfslt	combined_input
	bra	test
	movlw	0x01
	movwf	LATJ, A
	end	rst