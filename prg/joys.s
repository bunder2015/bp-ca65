.include "joys.inc"

.segment "ZEROPAGE"
JOY1IN:		.res 1		; Joypad 1 input
JOY2IN:		.res 1		; Joypad 2 input

.segment "FUNCS"
.proc READJOYS
	;; Reads the controllers and saves the buttons pressed
	;; Input: none
	;; Clobbers: A X
	LDA #$01
	STA STROBE		; Bring strobe latch high
	LDA #$00
	STA STROBE		; Bring strobe latch low

	LDX #8			; Set loop counter
L1:
	LDA JOY1		; Read Joypad 1
	LSR A			; Shift bit into carry
	ROL JOY1IN		; Rotate carry into storage
	LDA JOY2		; Read Joypad 2
	LSR A			; Shift bit into carry
	ROL JOY2IN		; Rotate carry into storage
	DEX
	BNE L1			; Loop through 8 joypad buttons

	RTS
.endproc
