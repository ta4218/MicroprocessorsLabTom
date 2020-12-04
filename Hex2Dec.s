#include <xc.inc>

global	h2d_16bit, ascii, h2d_hex_low, h2d_hex_high, random_numbers, h2d_rng, call_random_no
psect	udata_acs
sixteen:	ds  2 ;reserve two bytes for 16-bit value
sixteen_low:	ds  1 ;reserve one byte for low byte of 16-bit value
sixteen_high:	ds  1 ;reserve one byte for high byte of 16-bit value
eight:		ds  1 ;reserve one byte for 8-bit value
product_lhb:	ds  1 ;reserve one byte for 24-bit low high
product_llb:	ds  1 ;reserve one byte for 24-bit low low
product_hhb:	ds  1 ;reserve one byte for 24-bit high low
product_hlb:	ds  1 ;reserve one byte for 24-bit high low
sum_low:	ds  1 ;reserve one byte for 24-bit low
sum_middle:	ds  1 ;reserve one byte for 24-bit middle
sum_high:	ds  1 ;reserve one byte for 24-bit high
sixteen_low_two:ds  1 ;reserve one byte for 16- bit low
sixteen_high_two:ds 1 ;reserve one byte for 16-bit high
threetwo_low:	ds  1 ;reserve one byte for 32-bit value low
threetwo_middlelow:	ds  1 ;reserve one byte for 32-bit value middle low
threetwo_middlehigh:	ds  1 ;reserve one byte for 32-bit value middle high
threetwo_high:	ds  1 ;reserve one byte for 32-bit value high
twofour_low:	ds  1 ;reserve one byte for 24-bit value low
twofour_middle:	ds  1 ;reserve one byte for 24-bit value middle
twofour_high:	ds  1 ;reserve one byte for 24-bit value high
k_low:		ds  1 ;reserve one byte for k_low
k_high:		ds  1 ;reserve one byte for k_high
deci:		ds  2 ;reserve two byte for deci
hex_low:	ds  2 ;reserve two byte for hex_low
hex_high:	ds  2 ;reserve two byte for hex_high
h2d_count:	ds  1 ;reserve one byte for h2d counter
ascii_count:	ds  1 ;reserve one byte for ascii counter
random_numbers:	ds  20 ;reserve twenty bytes for random numbers
rng_counter:	ds  1 ;reserve one byte for rand dom numebr counter
    

psect	h2d_code, class=CODE
    

multiply:		;8-bit x 16-bit
 
    movf    eight, W, A		
    mulwf   sixteen_low, A  ;multiply low byte of 16-bit number with 8-bit value
    
    movff   PRODH, product_lhb	    ;store low high byte of 24-bit value
    movff   PRODL, product_llb	    ;store low low byte of 24-bit value
    
    mulwf   sixteen_high, A	    ;multiply high byte  of 16-bit number with 8-bit value
    movff   PRODH, product_hhb	    ;store high high byte of 24-bit value
    movff   PRODL, product_hlb	    ;store high low byte of 24-bit value
    
add:
    movf    product_lhb, W, A	    
    addwfc  product_hlb, F, A	    ;add high low byte with low high byte
    movff   product_hlb, sum_middle ;middle byte of 24-bit sum
    movlw   0x00		    ;add carry to high high byte
    addwfc  product_hhb, F, A	    
    movff   product_hhb, sum_high   ;high byte of 24-bit sum
    movff   product_llb, sum_low    ;low byte of 24-bit sum
    return
 
multiply_16:
    movff   sixteen_high_two, eight	;0x41 moved to eight
    call    multiply			;multiply hex value by 0x41
    movff   sum_low, threetwo_middlelow	    ;32-bit middle low
    movff   sum_middle, threetwo_middlehigh ;32-bit middle high
    movff   sum_high, threetwo_high	;32-bit high
    movff   sixteen_low_two, eight	;multiply hex by 0x8A
    call    multiply
    movlw   0x00
    movwf   threetwo_low, A		;set to zero
    movf    sum_low, W, A		 
    addwfc  threetwo_low, F, A		;add low byte of 24-bit value to 32-bit low
    movf    sum_middle, W, A		
    addwfc  threetwo_middlelow, F, A	;add middle byte of 24-bit value to 32-bit middle low
    movf    sum_high, W, A		;add high byte of 24-bit value to 32-bit middle high
    addwfc  threetwo_middlehigh, F, A
    movlw   0x00
    addwfc  threetwo_high, F, A		; add carry to first digit of hex to decimal conversion
    
    return
    
multiply_24:
    movf    eight, W, A
    mulwf   twofour_high, A		 ;multiply 24-bit high byte with 8-bit
    
    movff   PRODL, threetwo_middlehigh	 ;move to low byte to 32-bit middle high    
    movff   PRODH, threetwo_high	 ;move high byte to 32 bit high
    
    movff   twofour_low, sixteen_low	 ;set up variables for 16 by 8- bit multiply
    movff   twofour_middle, sixteen_high
    call    multiply			 ;multiply 16-bit with 8 bit
    movlw   0x00
    movwf   threetwo_low, A		 ;set to zero
    movwf   threetwo_middlelow, A	 ;set to zero
    movf    sum_low, W, A		
    addwfc  threetwo_low, F, A		 ;add low byte of 24-bit value to 32-bit low
    movf    sum_middle, W, A
    addwfc  threetwo_middlelow, F, A	 ;add with carry middle byte of 24-bit to 32-bit middle low 
    movf    sum_high, W, A
    addwfc  threetwo_middlehigh, F, A	 ;add with carry high byte of 24-bit to 32-bit middle high 
    movlw   0x00
    addwfc  threetwo_high, F, A		 ;add carry to next decimal of hex to dec conversion
    return
    

h2d_rng:
    movlw   0xA
    movwf   rng_counter, A	;10 random numbers to convert
    lfsr    2, random_numbers	  
rn_loop:
    movf    POSTINC0, W, A		;move random number to	w
    call    h2d_hex_low		;move to hex-low
    movlw   0x00		;random number is 2-digit so move zeros to hex_high
    call    h2d_hex_high
    call    h2d_16bit		;multiply random number by k
    call    ascii		;convert to ascii
    decfsz  rng_counter, A		;loop for every random number
    bra	    rn_loop
    return
    
h2d_hex_low:
    movwf   hex_low, A	    
    return
    
h2d_hex_high:
    movwf   hex_high, A
    return

h2d_16bit:
    movlw   0x8A
    movwf   k_low, A
    movlw   0x41
    movwf   k_high, A
    
    movff   k_low, sixteen_low_two
    movff   k_high, sixteen_high_two
    
    movff   hex_low, sixteen_low
    movff   hex_high, sixteen_high
    call    multiply_16			;multiply initial hex with k value(for first decimal)
    lfsr    1, deci
    movff   threetwo_high, POSTINC1	;move high digit to FSR1
    movlw   3
    movwf   h2d_count, A
    goto    h2d_loop

h2d_loop:				    ;remainding decimals require 24-bit x 8-bit
    movlw   0x0A
    movwf   eight, A			    ;multiply by 10    
    movff   threetwo_low, twofour_low	;   set up correct variables for 24-bit x 8-bit
    movff   threetwo_middlelow, twofour_middle
    movff   threetwo_middlehigh, twofour_high
    call    multiply_24			    ;multiply each 24-bit value by 10
    movff   threetwo_high, POSTINC1	    ;move high digit to FSR1 and inc pointer
    decfsz  h2d_count, A		    
    bra	    h2d_loop			    ;keep looping until all decimals stored
    lfsr    1, deci			    ;reset FSR1 
    return

call_random_no:
    lfsr    1, deci	    
    return
    
ascii:
	movlw   0x5	    
	movwf   ascii_count, A	    ;loop over 4 decimals
	lfsr    1, deci		    ;set FSR1 to address of decimal random numbers
	
tst0:   decfsz  ascii_count, A	    ;test for redundant zeros at the start
	tstfsz  INDF1, A		
	goto    ascii_loop	    ;if no zero
	movlw	0
	addwf	POSTINC1, A	    ;increment pointer
	bra	tst0	    
ascii_loop:
    movlw   0x30		    ;add 30h for ascii character
    addwf   POSTINC1, W, A	    ;store in W(keep initial deci values)
    movwf   POSTINC2, A		    ;move decimal to FSR2(random_numbers), and increment
    decfsz  ascii_count, A	    
    bra	    ascii_loop		    ;loop over 4 decimals in deci
    return



