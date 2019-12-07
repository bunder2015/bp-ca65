.include "debug.inc"
.include "mmc1.inc"
.include "ppu.inc"
.include "text.inc"

.segment "ZEROPAGE"
DBGA:		.res 1	; A register
DBGMC0:		.res 1	; MMC1 CHR0 bank
DBGMPB:		.res 1	; MMC1 PRG bank
DBGMPD:		.res 1	; MMC1 PRG RAM disable
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
DBGTEXT7:	.byte "PM: "
DBGTEXT8:	.byte "CM: "
DBGTEXT9:	.byte "PB: "
DBGTEXT10:	.byte "CB0: "
DBGTEXT11:	.byte "CB1: "
DBGTEXT12:	.byte "PRD: "

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

	LDA MMCCHR0
	STA DBGMC0		; Stash MMC1 CHR0 status

	LDA #MMC1_CHR_BANK0
	STA MMCCHR0
	JSR UPDATEMMC1CHR0	; Change MMC1 CHR0 to bank 0

	LDA MMCPRG
	STA DBGMPB		; Stash MMC1 PRG bank status

	LDA MMCRAM
	STA DBGMPD		; Stash MMC1 PRG RAM status

	LDA #MMC1_PRGRAM_DIS
	STA MMCRAM
	JSR UPDATEMMC1PRG	; Disable MMC1 PRG RAM if enabled

;	LDA #0
;	STA MUSICEN
;	JSR sound_stop		; Stop sound

	LDA #REND_DIS
	STA SPREN
	STA BGEN
	JSR UPDATEPPUMASK	; Disable rendering

	JSR CLEARSCREEN		; Clear the screen of tiles and sprites

	JSR VBWAIT		; Wait for the next vblank to draw register output

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
	LDA #$82
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
	LDA #$89
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
	LDA #$8F
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
	LDA #$A1
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
	LDA #$A8
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

	LDA #$20
	STA PPUCADDR
	LDA #$E1
	STA PPUCADDR+1
	LDA #0
	STA PPUCLEN
	LDA #4
	STA PPUCLEN+1
	LDA #<DBGTEXT7
	STA PPUCINPUT
	LDA #>DBGTEXT7
	STA PPUCINPUT+1
	JSR PPUCOPY		; Load debug text 7 into PPU
	LDA MMCPRGMODE
	LSR A
	LSR A
	STA PBINPUT+1
	JSR PRINT1BYTE		; Print MMC1 PRG mode

	LDA #$20
	STA PPUCADDR
	LDA #$E9
	STA PPUCADDR+1
	LDA #0
	STA PPUCLEN
	LDA #4
	STA PPUCLEN+1
	LDA #<DBGTEXT9
	STA PPUCINPUT
	LDA #>DBGTEXT9
	STA PPUCINPUT+1
	JSR PPUCOPY		; Load debug text 9 into PPU
	LDA DBGMPB
	STA PBINPUT+1
	JSR PRINT1BYTE		; Print MMC1 PRG bank

	LDA #$20
	STA PPUCADDR
	LDA #$F0
	STA PPUCADDR+1
	LDA #0
	STA PPUCLEN
	LDA #5
	STA PPUCLEN+1
	LDA #<DBGTEXT12
	STA PPUCINPUT
	LDA #>DBGTEXT12
	STA PPUCINPUT+1
	JSR PPUCOPY		; Load debug text 12 into PPU
	LDA DBGMPD
	LSR A
	LSR A
	LSR A
	LSR A
	STA PBINPUT+1
	JSR PRINT1BYTE		; Print MMC1 PRG RAM status

	LDA #$21
	STA PPUCADDR
	LDA #$01
	STA PPUCADDR+1
	LDA #0
	STA PPUCLEN
	LDA #4
	STA PPUCLEN+1
	LDA #<DBGTEXT8
	STA PPUCINPUT
	LDA #>DBGTEXT8
	STA PPUCINPUT+1
	JSR PPUCOPY		; Load debug text 8 into PPU
	LDA MMCCHRMODE
	LSR A
	LSR A
	LSR A
	LSR A
	STA PBINPUT+1
	JSR PRINT1BYTE		; Print MMC1 CHR mode

	LDA #$21
	STA PPUCADDR
	LDA #$08
	STA PPUCADDR+1
	LDA #0
	STA PPUCLEN
	LDA #5
	STA PPUCLEN+1
	LDA #<DBGTEXT10
	STA PPUCINPUT
	LDA #>DBGTEXT10
	STA PPUCINPUT+1
	JSR PPUCOPY		; Load debug text 10 into PPU
	LDA DBGMC0
	STA PBINPUT+1
	JSR PRINT1BYTE		; Print MMC1 CHR bank 0

	LDA #$21
	STA PPUCADDR
	LDA #$10
	STA PPUCADDR+1
	LDA #0
	STA PPUCLEN
	LDA #5
	STA PPUCLEN+1
	LDA #<DBGTEXT11
	STA PPUCINPUT
	LDA #>DBGTEXT11
	STA PPUCINPUT+1
	JSR PPUCOPY		; Load debug text 11 into PPU
	LDA MMCCHR1
	STA PBINPUT+1
	JSR PRINT1BYTE		; Print MMC1 CHR bank 1

	LDA #NT_SEL0
	STA NT			; Select nametable 0
	JSR UPDATEPPUCTRL

LOOP:
	;; We have printed the debug information, now we hang indefinitely
	JMP LOOP
.endproc
