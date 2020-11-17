    #include <pic18_chip_select.inc>
    #include <xc.inc>
    
psect    udata_bank4
RANDOM:     ds  1        ;reserve 1 byte for RANDOM variable
counter:    ds  1
psect    code, abs    
    
main:
    org    0x0
    goto    setup
    org    0x100
    
setup:    
    bcf    CFGS
    bsf    EEPGD
    movlw    0x21        ; set 0x21 as seed
    goto    start
    
myTable:
    myArray     EQU 0x500    ; adress in RAM for RANDOM NUMBERS
  
    
start:
    lfsr    0, myArray    ;load FSR0 with adress in RAM
    movwf  RANDOM        ; assign seed to RANDOM
    movlw  10        
    movwf  counter, A    ; set counter variable to 10
    
loop:
    call   shift
    call   output
    movf   RANDOM, W
    bra    loop
    
shift:
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
    
output:
    bcf	    RANDOM, 7        ; Clear MSB to ensure no higher than 127
    movlw   0x63            
    cpfsgt  RANDOM            ; if greater than 99, skip call save
    call    save
    return
    
save:    
    movf    RANDOM, W        ;    move RANDOM into W register
    movwf   POSTINC0, A        ;    load LFSR0 with W and increment LFSR
    decfsz  counter, A        ;    decrement counter to count down from 10
    return
    
    end main


