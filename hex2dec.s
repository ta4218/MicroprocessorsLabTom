#include <xc.inc>

global	h2d_setup
psect	udata_acs
sixteen:	ds  2
sixteen_low:	ds  1
sixteen_high:	ds  1
eight:		ds  1
product_lhb:	ds  2
product_llb:	ds  2
product_hhb:	ds  2
product_hlb:	ds  2
sum_low:	ds  2
sum_middle:	ds  2
sum_high:	ds  2

psect	h2d_code, class=CODE
    
h2d_setup:
    clrf    TRISE, A
    clrf    TRISJ, A
    clrf    TRISH, A
    movlw   0x61
    movwf   sixteen_high, A
    movlw   0x51
    movwf   sixteen_low, A
    movlw   0x18	
    movwf   eight, A	;8-bit value
    movff   sixteen_high, 0x500
    movff   sixteen_low, 0x501
    
    
multiply:
 
    movf    eight, 0
    mulwf   sixteen_low, 1
    
    movff   PRODH, product_lhb
    movff   PRODL, product_llb
    
    mulwf   sixteen_high, A
    movff   PRODH, product_hhb
    movff   PRODL, product_hlb
    
add:
    movf   product_lhb, 0
    addwfc  product_hlb, 1, 1
    movff   product_hlb, sum_middle
    movlw   0x00
    addwfc  product_hhb, 1, 1
    movff   product_hhb, sum_high
    movff   product_llb, sum_low
    movff   sum_high, PORTE
    movff   sum_low, PORTJ
    movff   sum_middle, PORTH
    
    return
   
    
