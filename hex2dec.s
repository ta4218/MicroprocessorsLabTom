#include <xc.inc>

global	multiply, multiply_16, multiply_24, h2d, ascii
psect	udata_acs
sixteen:	ds  2
sixteen_low:	ds  1
sixteen_high:	ds  1
eight:		ds  1
product_lhb:	ds  1
product_llb:	ds  1
product_hhb:	ds  1
product_hlb:	ds  1
sum_low:	ds  1
sum_middle:	ds  1
sum_high:	ds  1
sixteen_low_two:ds  1
sixteen_high_two:ds 1
threetwo_low:	ds  1
threetwo_middlelow:	ds  1
threetwo_middlehigh:	ds  1
threetwo_high:	ds  1
twofour_low:	ds  1
twofour_middle:	ds  1
twofour_high:	ds  1
k_low:		ds  1
k_high:		ds  1
deci:		ds  2
hex_low:	ds  2
hex_high:	ds  2
h2d_count:	ds  1
ascii_count:	ds  1    
  

psect	h2d_code, class=CODE
    

multiply:
 
    movf    eight, 0, 0
    mulwf   sixteen_low, 1
    
    movff   PRODH, product_lhb
    movff   PRODL, product_llb
    
    mulwf   sixteen_high, A
    movff   PRODH, product_hhb
    movff   PRODL, product_hlb
    
add:
    movf    product_lhb, 0, 0
    addwfc  product_hlb, 1, 1
    movff   product_hlb, sum_middle
    movlw   0x00
    addwfc  product_hhb, 1, 1
    movff   product_hhb, sum_high
    movff   product_llb, sum_low
    return
 
multiply_16:
    movff   sixteen_high_two, eight, A
    call    multiply
    movff   sum_low, threetwo_middlelow, A
    movff   sum_middle, threetwo_middlehigh, A
    movff   sum_high, threetwo_high, A
    movff   sixteen_low_two, eight, A
    call    multiply
    movlw   0x00
    movwf   threetwo_low, A
    movf    sum_low, 0, 0
    addwfc  threetwo_low, 1, 0
    movf    sum_middle, 0, 0
    addwfc  threetwo_middlelow, 1, 0
    movf    sum_high, 0, 0
    addwfc  threetwo_middlehigh, 1, 0
    movlw   0x00
    addwfc  threetwo_high, 1, 0
    
    return
    
multiply_24:
    movf    eight, 0, 0
    mulwf   twofour_high, A
    
    movff   PRODL, threetwo_middlehigh
    movff   PRODH, threetwo_high
    
    movff   twofour_low, sixteen_low, A
    movff   twofour_middle, sixteen_high, A
    call    multiply
    movlw   0x00
    movwf   threetwo_low, A
    movwf   threetwo_middlelow, A
    movf    sum_low, 0, 0
    addwfc  threetwo_low, 1, 0
    movf    sum_middle, 0, 0
    addwfc  threetwo_middlelow, 1, 0
    movf    sum_high, 0, 0
    addwfc  threetwo_middlehigh, 1, 0
    movlw   0x00
    addwfc  threetwo_high, 1, 0
    return
    
h2d:
    movlw   0x8A
    movwf   k_low, A
    movlw   0x41
    movwf   k_high, A
    
    movff   k_low, sixteen_low_two
    movff   k_high, sixteen_high_two
    
    movlw   0x09
    movwf   hex_high, A
    movlw   0x98
    movwf   hex_low, A
    
    movff   hex_low, sixteen_low
    movff   hex_high, sixteen_high
    call    multiply_16
    lfsr    1, deci
    movff   threetwo_high, POSTINC1
    movlw   3
    movwf   h2d_count, A
    
h2d_loop:
    movlw   0x0A
    movwf   eight, A
    movff   threetwo_low, twofour_low
    movff   threetwo_middlelow, twofour_middle
    movff   threetwo_middlehigh, twofour_high
    call    multiply_24
    movff   threetwo_high, POSTINC1
    decfsz  h2d_count
    bra	    h2d_loop
    return
    
ascii:
    movlw   0x4
    movwf   ascii_count, A
    lfsr    1, deci
    movlw   0x30
ascii_loop:    addwf   POSTINC1
    decfsz  ascii_count
    bra	    ascii_loop
    lfsr    1, deci
    return

    
    
    
   
