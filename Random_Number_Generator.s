    #include <xc.inc>

global	setupRNG, multiplyRNG1, multiplyRNG2, addRNG2, addRNG1 
extrn	h2d_rng
    
psect    udata_acs

RANDOM:		ds  1	    ;reserve 1 byte for RANDOM variable
counterRNG:	ds  1	    ;reserve 1 byte for random loop counter variable
vari:		ds  1	    ;reserve 1 byte for variable
vari2:		ds  1	    ;reserve 1 byte for variable

    
psect    RNG_code, class=CODE   
    
;******************** RANDOM NUMBER GENERATOR *********************************
    
setupRNG:    
    bcf    CFGS		    ;point to Flash program memory
    bsf    EEPGD	    ;access Flash program memory
    movf   TMR3L, W,A	    ;set TIMER3 as seed
    goto   startRNG
    
myTableRNG:
    myArrayRNG     EQU 0x500    ; adress in RAM for RANDOM NUMBERS
  
    
startRNG:
    lfsr    0, myArrayRNG   ;load FSR0 with adress in RAM
    movwf  RANDOM,A	    ;Assign seed to RANDOM
    movlw  10        
    movwf  counterRNG, A    ; set counter variable to 10
    
loopRNG:
    call   shiftRNG
    call   outputRNG
    movf    RANDOM, W,A
    tstfsz  counterRNG,A
    bra    loopRNG
    lfsr    0, myArrayRNG   ;load FSR0 with adress in RAM
    call    h2d_rng
    return
    
shiftRNG:
    rlcf    RANDOM, W,A	    ;moves MSB to carry, shifts numbers left
    rlcf    RANDOM, W,A	    ;moves all numbers left, carry initialised already
    btfsc   RANDOM, 4,A	    ;if bit 4 is 0 then next instruction skipped
    xorlw   1		    ;contents of W are XORed with 1
    btfsc   RANDOM, 5,A       ;if bit 5 is 0 then next instruction skipped
    xorlw   1		    ;contents of W are XORed with 1
    btfsc   RANDOM, 3,A       ;if bit 3 is 0 then next instruction skipped
    xorlw   1		    ;contents of W are XORed with 1
    movwf   RANDOM,A          ; load W into RANDOM variable
    return
    
outputRNG:
    bcf	    RANDOM, 7 ,A      ;Clear MSB to ensure no higher than 127
    movlw   0x63            
    cpfsgt  RANDOM,A          ;if greater than 99, skip call save
    call    checkdouble	    ;go to second check
    return
    
checkdouble:
    movlw   0xA		    ;compare number to 10, so that its not less than 10
    cpfslt  RANDOM,A
    call    saveRNG
    return
    
saveRNG:    
    movf    RANDOM, W,A	    ;move RANDOM into W register
    movwf   POSTINC0, A     ;load LFSR0 with W and increment LFSR
    decfsz  counterRNG, A   ;decrement counter to count down from 10
    return
    
;************** CALCULATIONS DONE WITH RANDOM NUMBER GENERATOR ****************    
     

multiplyRNG1:
    lfsr    2, myArrayRNG   ;point FSR2 to where random numbers stored
    movff    PLUSW2, vari   ;moves number at FSR2, which has been indexed from rn_array_pointer, to vari
    return

multiplyRNG2:
    movff   PLUSW2, vari2   ;moves number at FSR2, which has been indexed, to vari2
    movf    vari2, W,A
    mulwf   vari,A	    ;multiplies vari and vari2 to find correct answer
    return
    

addRNG1:
    lfsr    2, myArrayRNG   ;point FSR2 to where random numbers stored
    movff    PLUSW2, vari   ;moves number at FSR2, which has been indexed from rn_array_pointer, to vari
    return

addRNG2:
    movff   PLUSW2, vari2   ;moves number at FSR2, which has been indexed, to vari2
    movf    vari2, W,A
    addwf   vari, W, A	    ;adds vari and vari2 to find correct answer
    return
    

    


