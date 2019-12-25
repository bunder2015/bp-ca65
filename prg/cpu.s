.include "cpu.inc"

.segment "ZEROPAGE"
CPUCADDR:	.res 2	; CPUCOPY destination address
CPUCINPUT:	.res 2	; CPUCOPY source address
CPUCLEN:	.res 2	; CPUCOPY data length

.segment "FUNCS"
.proc CPUCOPY
 	;; Copies lengths of data within the CPU address space
	;; Input: CPUCADDR CPUCLEN CPUCINPUT
	;; Clobbers: A X Y
	LDA CPUCLEN
	BNE SETUP
	LDA CPUCLEN+1
	BNE SETUP		; Verify length is not zero
	BRK

SETUP:
	LDX #$00
	LDY #$00		; Set loop counters

L1:
	LDA (CPUCINPUT), Y	; Load data
	STA (CPUCADDR), Y	; Store data
	INY
	CPY CPUCLEN+1
	BNE L1
	LDA CPUCLEN
	BEQ DONE
	INX
	CPX CPUCLEN		; Check to see if we have finished copying
	BEQ DONE		; Loop if we have not finished copying
	INC CPUCINPUT+1
	JMP L1
DONE:
	RTS
.endproc
