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
	LDX #$FF
	LDY #$00		; Set loop counters

L1:
	LDA (CPUCINPUT), Y	; Load data
	STA (CPUCADDR), Y	; Store data
	INY
	CPY CPUCLEN+1
	BNE L1
	LDY #$00
	INX
	CPX CPUCLEN		; Check to see if we have finished copying
	BNE L1			; Loop if we have not finished copying

	RTS
.endproc
