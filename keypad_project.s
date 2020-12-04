#include <xc.inc>

global  keypad_setup, key_control,key_control_noclr, counter_kp, get_key, combined_input, input_answer
extrn	display_clear, LCD_Write_Message, delay_500ms

     
psect	data	; a table of values in program memory
keypad_table:
	db      0xBE, 0x77, 0xB7, 0xD7, 0x7B, 0xBB, 0xDB, 0x7D, 0xBD, 0xDD, 0x7E, 0xDE, 0xEE
	db      0xED, 0xEB, 0xE7    ; table of combined values for rows/columns, will compare returned value to this table
	align   2
	
psect	udata_acs	;store variables in access ram
kp_delay_count: ds 1	;one byte for counter variable 
kp_delay_count2: ds 1	;one byte for counter variable 
counter_kp: ds 1	;one byte for keypad input 
row_input:  ds 1	;one byte for row input 
col_input:  ds 1	;one byte for column input
combined_input:	ds 1	;one byte for combined row/colum sum 
table_temp: ds 1	;one byte for temporary variable from table
    
       
psect   udata_bank4	; more space in data memory in bank 4
array_kp:	ds 0x12	; space for the karray table   

psect	keypad_code, class=CODE
keypad_setup:
	setf    TRISE, A    ;PORTE input
	banksel PADCFG1	    ;select bank register PADCFG1
	bsf     REPU	    ;Set pullups on PORTE
	movlb   0x00	    
	clrf	TRISH, A    ;PORTH output to display keypad value
	return

get_key:
	goto	read_rows
	movlw	0xff		
	movwf	combined_input, A;assume combined_input 0xff unless changed
read_rows:
	clrf    LATE, A    ;Write 0s to LATE
	movlw   0x0f
	movwf   TRISE, A    ;Pins 0-3 input, Pins 4-7 output
    
	movlw   0x2		;delay for voltage to settle
	movwf   kp_delay_count, A
	call    delay
    
	movff   PORTE,  row_input

 
read_cols:
	clrf    LATE, A    ;Write 0s to LATE
	movlw   0xf0
	movwf   TRISE, A    ;Pins 0-3 output, Pins 4-7 input
    
	movlw   0x2		;delay for voltage to settle
	movwf   kp_delay_count, A
	call    delay
   
	movff   PORTE, col_input    
    
decode:
	movf    row_input, W, A
	addwf   col_input, W, A		;Combine value of rows/columns
	movwf   combined_input, A	;Move to RAM
	return
	
start_keypad:
	lfsr	2, array_kp		    ; Load FSR0 with address in RAM    
	movlw   low highword(keypad_table)  ; address of data in PM
	movwf   TBLPTRU, A		    ; load upper bits to TBLPTRU
	movlw   high(keypad_table)	    ; address of data in PM
	movwf   TBLPTRH, A		    ; load high byte to TBLPTRH
	movlw   low(keypad_table)	    ; address of data in PM
	movwf   TBLPTRL, A		    ; load low byte to TBLPTRL
	movlw   0			    ; bytes to count up
	movwf   counter_kp, A		    ; our counter register
loop_kp:     
	tblrd*+				    ; one byte from PM to TABLAT, increment TBLPRT
	movff   TABLAT, table_temp	    ; move data from TABLAT to temp location for comparison   
        incfsz  counter_kp, A		    ; count up   
	
	movf    table_temp, W, A
	cpfseq  combined_input, A	    ;compare pressed value with table
	bra     loop_kp			    ; keep going until finished
	movlw	0x1			    ;subtract one for key input
	subwf	counter_kp, A
ascii:
	movlw	0x30			    ; add 30h for ascii
	lfsr    2, counter_kp		    
	addwf	INDF2, F, A
	movf	counter_kp, W, A	    
	return

key_control:	
	movlw	0xff
	cpfslt	combined_input, A	    ;compare input to see if key pressed
	goto	key_control
	call	start_keypad		    ;decode if key pressed
	return

key_control_noclr:	
	movlw	0xff
	cpfslt	combined_input, A	    ;compare input to see if key pressed
	goto	key_control_noclr
	call	start_keypad		    ;decode if key pressed
	movlw	0x1
	call	LCD_Write_Message	    ;write to LCD immediately
	return

input_answer:
	call	key_control_noclr	    ;wait for key press
	
	movlw	0x1
	call	delay_500ms		    ;500ms delay allows one key to be pressed
	
	movlw	0x3E			    ;skip if enter pressed
	cpfseq	counter_kp, A  
	
	bra	ia_lp			    
	
	return				;return if enter pressed
	
ia_lp:	movlw	0x30			
	subwf	counter_kp, A		;remove ascii conversion
	movff	counter_kp, POSTINC1	  ; move to input_answer
	bra	input_answer
	
delay:  
	decfsz  kp_delay_count, F, A
	movlw   0x10
	movwf	kp_delay_count2, A
	call    cascade
	tstfsz  kp_delay_count, A
	bra	delay
	return
    
cascade:  ;1.25us delay
	decfsz  kp_delay_count2, F, A
	bra	cascade
	return
	
	


