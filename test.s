#include <xc.inc>

extrn	h2d_16bit
global	start_test

psect	udata_acs
test_input: ds 4
test_counter:	ds 1
high_d:	ds 1
low_d: ds 1
eight_test:	ds 1
low_d2:  ds 1
high_d2: ds 1
test_counter2: ds 1

    
psect	tst_code, class = CODE  
start_test:
	movlw	0x4
	movwf	test_counter, A
	lfsr	2, 0x600
	lfsr	1, test_input
	;movlw	0x0
	;movwf	POSTINC2
	movlw	0x1
	movwf	POSTINC2
	movlw	0x9
	movwf	POSTINC2
	movlw	0x2
	movwf	POSTINC2
	lfsr	2, 0x600
	call	test
	;call	_2byte
	call	multiply_test
	
	movlw	0x4
	movwf	test_counter2, A
	lfsr	2, test_input
	call	test2
	goto	$
	
test:
	movff	POSTINC2, POSTINC1
	decfsz	test_counter
	bra	test
	return
	
_2byte:
	movf	POSTDEC1, W
	movff	POSTDEC1, low_d
	movlw	0xA
	mulwf	POSTDEC1, 0
	movf	PRODL, W
	addwf	low_d, 1
	
	movff	POSTDEC1, high_d
	movlw	0xA
	mulwf	POSTDEC1, 0
	movf	PRODL, W
	addwf	high_d, 1
	
	return
	
multiply_test:
    
	movlw	0x20
	movwf	eight_test
	movlw	0x06
	mulwf	eight_test
	movff	PRODH, high_d2
	movff	PRODL, low_d2
	call	h2d_16bit
	return
	
test2:
	movlw	0x0
	cpfseq	INDF1
	goto	test2lp
	addwf	POSTINC1
	bra	test2
test2lp:	
	movf	POSTINC2, W
	cpfseq	POSTINC1
	goto	fail
	decfsz	test_counter2
	bra	test2lp
	return
	
fail:
	movlw	0x4
	movwf	0x60
	
	
	
	
	
	
	



