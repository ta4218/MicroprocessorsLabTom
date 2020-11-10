#include <xc.inc>

global  keypad_setup, get_key, counter_kp
extrn	LCD_delay_ms
     
psect	data	; a table of values in program memory
table:
	db      0xBE, 0x77, 0xB7, 0xD7, 0x7B, 0xBB, 0xDB, 0x7D, 0xBD, 0xDD, 0x7E, 0xDE, 0xEE
	db      0xED, 0xEB, 0xE7    ; table of combined values for rows/columns, will compare returned value to this table
	align   2
	
psect	udata_acs   ; define all your local variables here (look at LCD.S), they will be put in access ram
kp_delay_count: ds 1 ; one byte for counter variable in access ram 
counter_kp: ds 1    ; one byte for counter variable in access ram
row_input:  ds 1
col_input:  ds 1
combined_input:	ds 1
table_temp: ds 1
	
    
psect   udata_bank4	; more space in data memory in bank 4
array_kp:	ds 0x12	; space for the karray table   
	;counter_kp EQU      10    ; is this a supposed to be a variable or a constant?



psect	keypad_code, class=CODE
keypad_setup:
	setf    TRISE, A    ;Set pullups on PORTE
	banksel PADCFG1
	bsf     REPU
	movlb   0x00 
	clrf	TRISH, A	;porth output to display keypad value
	return
get_key:
	goto	read_rows
read_rows:
	clrf    LATE, A    ;Write 0s to LATE
	movlw   0x0f
	movwf   TRISE, A    ;Pins 0-3 input, Pins 4-7 output
    
	;movlw   0x10
	;movwf   kp_delay_count, A
	;call    delay
	
	movlw   0x14
	call    LCD_delay_ms
    
	movff   PORTE,  row_input
 
read_cols:
	clrf    LATE, A    ;Write 0s to LATE
	movlw   0xf0
	movwf   TRISE, A    ;Pins 0-3 output, Pins 4-7 input
    
	;movlw   0x10
	;movwf   kp_delay_count, A
	;call    delay
    
	movlw   0x14
	call    LCD_delay_ms
   
	movff   PORTE, col_input
    
decode:
	movf    row_input, W, A
	addwf   col_input, W, A	    ;Combine value of rows/columns
	movwf   combined_input, A		    ;Move to RAM

start_keypad:
	lfsr	0, array_kp    ; Load FSR0 with address in RAM    
	movlw   low highword(table)    ; address of data in PM
	movwf   TBLPTRU, A        ; load upper bits to TBLPTRU
	movlw   high(table)    ; address of data in PM
	movwf   TBLPTRH, A        ; load high byte to TBLPTRH
	movlw   low(table)    ; address of data in PM
	movwf   TBLPTRL, A        ; load low byte to TBLPTRL
	movlw   0        ; bytes to count up
	movwf   counter_kp, A        ; our counter register
loop_kp:     
	tblrd*+            ; one byte from PM to TABLAT, increment TBLPRT
	movff   TABLAT, table_temp; move data from TABLAT to 0x23   
        incfsz  counter_kp, A    ; count up   
	
	movf    table_temp, W
	cpfseq  combined_input, A	;compare pressed value with table
	bra     loop_kp        ; keep going until finished
	;movff   counter_kp, 	;move 'counter' value of keypad to 0x24
	movlw	0x1
	subwf	counter_kp
	return

ascii:
	movlw	0x30
	
	lfsr    2, counter_kp
	addwf	INDF2
delay:        
	decfsz  kp_delay_count, f, A
	movlw   0x10
	movwf   0x32, A
	call    cascade
	tstfsz  0x30, A
	bra	delay
	return
    
cascade:
	decfsz  0x32, f, A
	bra	cascade
	return
	
	