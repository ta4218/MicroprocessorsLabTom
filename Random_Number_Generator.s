    #include <pic18_chip_select.inc>
    #include <xc.inc>

global	setupRNG, multiplyRNG1, multiplyRNG2, addRNG2, addRNG1
psect    udata_bank4
RANDOM:     ds  1        ;reserve 1 byte for RANDOM variable
counterRNG:    ds  1
vari:	    ds  1
vari2:	ds  1
    
    
psect    RNG_code, class=CODE    
    

setupRNG:    
    bcf    CFGS
    bsf    EEPGD
    movf   TMR0, W        ; set 0x21 as seed
    goto    startRNG
    
myTableRNG:
    myArrayRNG     EQU 0x500    ; adress in RAM for RANDOM NUMBERS
  
    
startRNG:
    lfsr    0, myArrayRNG    ;load FSR0 with adress in RAM
    movwf  RANDOM        ; assign seed to RANDOM
    movlw  10        
    movwf  counterRNG, A    ; set counter variable to 10
    
loopRNG:
    call   shiftRNG
    call   outputRNG
    movf   RANDOM, W
    tstfsz  counterRNG
    bra    loopRNG
    lfsr    0, myArrayRNG    ;load FSR0 with adress in RAM
    return
    
shiftRNG:
    RLCF    RANDOM, W        ; rotates MSB to LSB of Random and other bits shift left, stored in W
    RLCF    RANDOM, W
    BTFSC   RANDOM, 4        ; if bit 4 is 0 then next instruction skipped
    XORLW   1            ; contents of W are XORed with 1
    BTFSC   RANDOM, 5        ; if bit 5 is 0 then next instruction skipped
    XORLW   1            ; contents of W are XORed with 1
    BTFSC   RANDOM, 3        ; if bit 3 is 0 then next instruction skipped
    XORLW   1            ; contents of W are XORed with 1
    MOVWF   RANDOM            ; load W into RANDOM variable
    return
    
outputRNG:
    bcf	    RANDOM, 7        ; Clear MSB to ensure no higher than 127
    movlw   0x63            
    cpfsgt  RANDOM            ; if greater than 99, skip call save
    call    checkdouble
    return
    
checkdouble:
    movlw   0xA
    cpfslt  RANDOM
    call    saveRNG
    return
    
saveRNG:    
    movf    RANDOM, W        ;    move RANDOM into W register
    movwf   POSTINC0, A        ;    load LFSR0 with W and increment LFSR
    decfsz  counterRNG, A        ;    decrement counter to count down from 10
    return
    
multiplyRNG1:
    lfsr    2, myArrayRNG
    movff    PLUSW2, vari
    return
multiplyRNG2:
    movff   PLUSW2, vari2
    movf    vari2, W
    mulwf   vari
    return
    
addRNG1:
    lfsr    2, myArrayRNG
    movff    PLUSW2, vari
    return
addRNG2:
    movff   PLUSW2, vari2
    movf    vari2, W
    addwf   vari, W, A
    return
    

    


