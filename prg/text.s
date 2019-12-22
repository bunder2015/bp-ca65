.include "ppu.inc"
.include "text.inc"

.segment "ZEROPAGE"
PBADDR:		.res 2	; PRINT1BYTE/PRINT2BYTES destination address
PBINPUT:	.res 2	; PRINT1BYTE/PRINT2BYTES source address
PBTEMP:		.res 1	; Temporary variable for PRINT1BYTE/PRINT2BYTES

.segment "FUNCS"
.proc PRINT2BYTES
	; Prints two hex bytes to the screen, assumes PPUADDR has already been set
	; Input: PBADDR PBINPUT
	; Clobbers: A X
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
	BIT PPUSTATUS			; Read PPUSTATUS to reset PPUADDR latch
	LDX PBADDR
	STX PPUADDR
	LDX PBADDR+1
	STX PPUADDR			; Read address and set PPUADDR
	STA PPUDATA			; Write to PPU

	INC PBADDR+1
	BNE PREPRIGHT
	INC PBADDR

PREPRIGHT:
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
	BIT PPUSTATUS			; Read PPUSTATUS to reset PPUADDR latch
	LDX PBADDR
	STX PPUADDR
	LDX PBADDR+1
	STX PPUADDR			; Read address and set PPUADDR
	STA PPUDATA			; Write to PPU

	INC PBADDR+1
	BNE DONE
	INC PBADDR
DONE:
	JMP PRINT1BYTE
.endproc

.proc PRINT1BYTE
	; Prints one hex byte to the screen, assumes PPUADDR has already been set
	; Input: PBADDR PBINPUT
	; Clobbers: A X
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
	BIT PPUSTATUS			; Read PPUSTATUS to reset PPUADDR latch
	LDX PBADDR
	STX PPUADDR
	LDX PBADDR+1
	STX PPUADDR			; Read address and set PPUADDR
	STA PPUDATA			; Write to PPU

	INC PBADDR+1
	BNE PREPRIGHT
	INC PBADDR

PREPRIGHT:
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
	BIT PPUSTATUS			; Read PPUSTATUS to reset PPUADDR latch
	LDX PBADDR
	STX PPUADDR
	LDX PBADDR+1
	STX PPUADDR			; Read address and set PPUADDR
	STA PPUDATA			; Write to PPU

	RTS
.endproc
