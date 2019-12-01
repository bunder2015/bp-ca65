.include "ppu.inc"
.include "text.inc"

.segment "ZEROPAGE"
PBINPUT:	.res 2	; PRINT1BYTE/PRINT2BYTES input
PBTEMP:		.res 1	; Temporary variable for PRINT1BYTE/PRINT2BYTES

.segment "FUNCS"
.proc PRINT2BYTES
	; Prints two hex bytes to the screen, assumes PPUADDR has already been set
	; Input: PBINPUT
	; Clobbers: A
	LDA PBINPUT			; Left side byte
	AND #%11110000			; Left side bits
	STA PBTEMP
	LSR PBTEMP
	LSR PBTEMP
	LSR PBTEMP
	LSR PBTEMP			; Shift left side bits into right side bits
	LDA PBTEMP
	CMP #10				; If the nibble is higher than 9 it is a hex letter
	BCS ALPHALEFT
	CLC
	ADC #$30			; Shift nibble into ASCII table range for 0-9
	JMP PRINTLEFT
ALPHALEFT:
	CLC
	ADC #$37			; Shift nibble into ASCII table range for A-F
PRINTLEFT:
	STA PPUDATA			; Write to PPU

	LDA PBINPUT			; Left side byte
	AND #%00001111			; Right side bits
	STA PBTEMP
	CMP #10				; If the nibble is higher than 9 it is a hex letter
	BCS ALPHARIGHT
	CLC
	ADC #$30			; Shift nibble into ASCII table range for 0-9
	JMP PRINTRIGHT
ALPHARIGHT:
	CLC
	ADC #$37			; Shift nibble into ASCII table range for A-F
PRINTRIGHT:
	STA PPUDATA			; Write to PPU

	JMP PRINT1BYTE
.endproc

.proc PRINT1BYTE
	; Prints one hex byte to the screen, assumes PPUADDR has already been set
	; Input: PBINPUT
	; Clobbers: A
	LDA PBINPUT+1			; Right side byte
	AND #%11110000			; Left side bits
	STA PBTEMP
	LSR PBTEMP
	LSR PBTEMP
	LSR PBTEMP
	LSR PBTEMP			; Shift left side bits into right side bits
	LDA PBTEMP
	CMP #10				; If the nibble is higher than 9 it is a hex letter
	BCS ALPHALEFT
	CLC
	ADC #$30			; Shift nibble into ASCII table range for 0-9
	JMP PRINTLEFT
ALPHALEFT:
	CLC
	ADC #$37			; Shift nibble into ASCII table range for A-F
PRINTLEFT:
	STA PPUDATA			; Write to PPU

	LDA PBINPUT+1			; Right side byte
	AND #%00001111			; Right side bits
	STA PBTEMP
	CMP #10				; If the nibble is higher than 9 it is a hex letter
	BCS ALPHARIGHT
	CLC
	ADC #$30			; Shift nibble into ASCII table range for 0-9
	JMP PRINTRIGHT
ALPHARIGHT:
	CLC
	ADC #$37			; Shift nibble into ASCII table range for A-F
PRINTRIGHT:
	STA PPUDATA			; Write to PPU

	JSR VBWAIT			; Wait for next vblank so we don't write too much data at once
	RTS
.endproc
