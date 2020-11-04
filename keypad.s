#include <xc.inc>

 

global   keypad_setup
psect    udata_bank4
    
keypad_setup:
	setf    TRISE, A    ;Set pullups on PORTE
	banksel PADCFG1
	bsf     REPU
	movlb   0x00

 

table:
	db      0xBE, 0x77, 0xB7, 0xD7, 0x7B, 0xBB, 0xDB, 0x7D, 0xBD, 0xDD, 0x7E, 0xDE, 0xEE
	db      0xED, 0xEB, 0xE7    ; table of combined values for rows/columns, will compare returned value to this table
	align   2
    
	karray   EQU        0x400
	kcounter EQU        0x12
;ascii:
    ;db        '0', '1', '2', '3', '4', '5', '6', '7', '8', '9', 'A', 'B', 'C', 'D', 'E', 'F'
    ;align   2    

 

read_rows:
	clrf    LATE, A    ;Write 0s to LATE
	movlw   0x0f
	movwf   TRISE, A    ;Pins 0-3 input, Pins 4-7 output
    
	movlw    0x10
	movwf    0x30, A
	call    delay
	
    ;movlw   1000
    ;call    LCD_delay_ms
    
	 movff   PORTE,  0x20
 
read_cols:
	clrf    LATE, A    ;Write 0s to LATE
	movlw   0xf0
	movwf   TRISE, A    ;Pins 0-3 output, Pins 4-7 input
    
	movlw    0x10
	movwf    0x30, A
	call    delay
    
    ;movlw   1000
    ;call    LCD_delay_ms
   
	movff   PORTE, 0x21
    
decode:
	movf    0x20, 0
	addwf   0x21, 0	    ;Combine value of rows/columns
	movwf   0x22, A	    ;Move to RAM

 


start_keypad:
	lfsr     0, karray    ; Load FSR0 with address in RAM    
	movlw    low highword(table)    ; address of data in PM
	movwf    TBLPTRU, A        ; load upper bits to TBLPTRU
	movlw    high(table)    ; address of data in PM
	movwf    TBLPTRH, A        ; load high byte to TBLPTRH
	movlw    low(table)    ; address of data in PM
	movwf    TBLPTRL, A        ; load low byte to TBLPTRL
	movlw    0        ; bytes to count up
	movwf    kcounter, A        ; our counter register
kloop:     
	tblrd*+            ; one byte from PM to TABLAT, increment TBLPRT
	movff    TABLAT, 0x23; move data from TABLAT to 0x23   
            
	movf     0x23, A
	cpfseq   0x22, A	;compare pressed value with table
	incfsz   kcounter, A    ; count up
	movff    kcounter, 0x24	;move 'counter' value of keypad to 0x24
	cpfseq   0x22, A	; if value is the same then finish
	bra      kloop        ; keep going until finished
	goto     end_

 

delay:        
	decfsz    0x30, f, A
	movlw    0x10
	movwf    0x32, A
	call    cascade
	tstfsz    0x30, A
	bra    delay
	return
    
cascade:
	decfsz    0x32, f, A
	bra    cascade
	return

 

end_:
	end







