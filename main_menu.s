#include <xc.inc>
    
psect	udata_bank4 ; reserve data anywhere in RAM (here at 0x400)
myArray:    ds 0x80 ; reserve 128 bytes for message data
    
psect	data    
	; ******* myTable, data in programme memory, and its length *****
welcome_message:
	db	'*','*','*','*','P','I','C',' ', 'Y','O', 'U', 'R','*','*','*','*'
	db	'*','*','*','*','*','B','R','A','I','N','S','*','*','*','*','*', 0x0a				
	; message, plus carriage return
	myTable_l   EQU	32	; length of data
	align	2
game_selection:
	db	'0','1','2','3','4','5','6','7','8','9','A','B','C','D','E','F', 0x0a
					; message, plus carriage return
	myTable_l   EQU	1	; length of data
	align	2

psect	code, abs
	



