.include "debug.inc"
.include "ppu.inc"
.include "text.inc"

.segment "ZEROPAGE"
DBGA:		.res 1	; A register
DBGPC:		.res 2	; Program counter
DBGPS:		.res 1	; Processor status
DBGSP:		.res 1	; Stack pointer
DBGX:		.res 1	; X register
DBGY:		.res 1	; Y register

.segment "FUNCD"
DBGPALS:	.byte $01,$20,$10,$00	; BG palette 0
DBGTEXT1:	.byte "BREAK AT PC: "
DBGTEXT2:	.byte "A: "
DBGTEXT3:	.byte "X: "
DBGTEXT4:	.byte "Y: "
DBGTEXT5:	.byte "SP: "
DBGTEXT6:	.byte "PS: "

.segment "FUNCS"
.proc BREAK
	;; BRK debugger - store debug registers to memory, stop game execution, then display registers
	STX DBGX		; Stash X register
	STY DBGY		; Stash Y register
	TSX
	INX
	INX
	INX
	STX DBGSP		; Stash stack pointer
	PLA			; Pull processor status from the stack
	STA DBGPS		; Stash processor status
	PLA
	STA DBGPC+1
	PLA			; Pull program counter from the stack
	STA DBGPC		; Stash program counter

	LDA DBGPC+1
	BNE DEC1		; Decrement page if the low byte is zero
	DEC DBGPC
DEC1:
	DEC DBGPC+1
	BNE DEC2		; Decrement page if the low byte is zero
	DEC DBGPC
DEC2:
	DEC DBGPC+1		; Return program counter to address that caused the BRK

;	LDA #0
;	STA MUSICEN
;	JSR sound_stop		; Stop sound

	LDA #REND_DIS
	STA SPREN
	STA BGEN
	JSR UPDATEPPUMASK	; Disable rendering

	JSR CLEARSCREEN

	LDA #$3F
	STA PPUCADDR
	LDA #$00
	STA PPUCADDR+1
	LDA #0
	STA PPUCLEN
	LDA #4
	STA PPUCLEN+1
	LDA #<DBGPALS
	STA PPUCINPUT
	LDA #>DBGPALS
	STA PPUCINPUT+1
	JSR PPUCOPY		; Load palettes into PPU

	LDA #$20
	STA PPUCADDR
	LDA #$41
	STA PPUCADDR+1
	LDA #0
	STA PPUCLEN
	LDA #13
	STA PPUCLEN+1
	LDA #<DBGTEXT1
	STA PPUCINPUT
	LDA #>DBGTEXT1
	STA PPUCINPUT+1
	JSR PPUCOPY		; Load debug text 1 into PPU
	LDA DBGPC
	STA PBINPUT
	LDA DBGPC+1
	STA PBINPUT+1
	JSR PRINT2BYTES		; Print program counter

	LDA #$20
	STA PPUCADDR
	LDA #$61
	STA PPUCADDR+1
	LDA #0
	STA PPUCLEN
	LDA #3
	STA PPUCLEN+1
	LDA #<DBGTEXT2
	STA PPUCINPUT
	LDA #>DBGTEXT2
	STA PPUCINPUT+1
	JSR PPUCOPY		; Load debug text 2 into PPU
	LDA DBGA
	STA PBINPUT+1
	JSR PRINT1BYTE		; Print A register

	LDA #$20
	STA PPUCADDR
	LDA #$69
	STA PPUCADDR+1
	LDA #0
	STA PPUCLEN
	LDA #3
	STA PPUCLEN+1
	LDA #<DBGTEXT3
	STA PPUCINPUT
	LDA #>DBGTEXT3
	STA PPUCINPUT+1
	JSR PPUCOPY		; Load debug text 3 into PPU
	LDA DBGX
	STA PBINPUT+1
	JSR PRINT1BYTE		; Print X register

	LDA #$20
	STA PPUCADDR
	LDA #$71
	STA PPUCADDR+1
	LDA #0
	STA PPUCLEN
	LDA #3
	STA PPUCLEN+1
	LDA #<DBGTEXT4
	STA PPUCINPUT
	LDA #>DBGTEXT4
	STA PPUCINPUT+1
	JSR PPUCOPY		; Load debug text 4 into PPU
	LDA DBGY
	STA PBINPUT+1
	JSR PRINT1BYTE		; Print Y register

	LDA #$20
	STA PPUCADDR
	LDA #$81
	STA PPUCADDR+1
	LDA #0
	STA PPUCLEN
	LDA #4
	STA PPUCLEN+1
	LDA #<DBGTEXT5
	STA PPUCINPUT
	LDA #>DBGTEXT5
	STA PPUCINPUT+1
	JSR PPUCOPY		; Load debug text 5 into PPU
	LDA DBGSP
	STA PBINPUT+1
	JSR PRINT1BYTE		; Print stack pointer

	LDA #$20
	STA PPUCADDR
	LDA #$89
	STA PPUCADDR+1
	LDA #0
	STA PPUCLEN
	LDA #4
	STA PPUCLEN+1
	LDA #<DBGTEXT6
	STA PPUCINPUT
	LDA #>DBGTEXT6
	STA PPUCINPUT+1
	JSR PPUCOPY		; Load debug text 6 into PPU
	LDA DBGPS
	STA PBINPUT+1
	JSR PRINT1BYTE		; Print processor flags

	LDA #NT_SEL0
	STA NT			; Select nametable 0
	JSR UPDATEPPUCTRL

LOOP:
	JSR VBWAIT		; Wait for next vblank
	JMP LOOP		; Infinite loop
.endproc
