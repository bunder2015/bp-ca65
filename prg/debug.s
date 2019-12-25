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
DBGBG:
		.incbin "debug.nam"
DBGPALS:
		.incbin "debug.pal"

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

	LDA #PD_INC1
	STA PDINC		; Select 1x PPUDATA address increment mode
	JSR UPDATEPPUCTRL

	JSR CLEARSCREEN		; Clear the screen of tiles and sprites

	JSR VBWAIT		; Wait for the next vblank to draw register output

	LDA #REND_DIS
	STA SPREN
	STA BGEN
	JSR UPDATEPPUMASK	; Disable rendering again

	LDA #$3F
	STA PPUCADDR
	LDA #$00
	STA PPUCADDR+1
	LDA #0
	STA PPUCLEN
	LDA #16
	STA PPUCLEN+1
	LDA #<DBGPALS
	STA PPUCINPUT
	LDA #>DBGPALS
	STA PPUCINPUT+1
	JSR PPUCOPY		; Load palettes into PPU

	LDA #$20
	STA PPUCADDR
	LDA #$00
	STA PPUCADDR+1
	LDA #$04
	STA PPUCLEN
	LDA #$00
	STA PPUCLEN+1
	LDA #<DBGBG
	STA PPUCINPUT
	LDA #>DBGBG
	STA PPUCINPUT+1
	JSR PPUCOPY		; Load debug BG tiles into PPU

	LDA #$20
	STA PBADDR
	LDA #$4F
	STA PBADDR+1
	LDA DBGPC
	STA PBINPUT
	LDA DBGPC+1
	STA PBINPUT+1
	JSR PRINT2BYTES		; Print program counter

	LDA #$20
	STA PBADDR
	LDA #$86
	STA PBADDR+1
	LDA DBGA
	STA PBINPUT+1
	JSR PRINT1BYTE		; Print A register

	LDA #$20
	STA PBADDR
	LDA #$8E
	STA PBADDR+1
	LDA DBGX
	STA PBINPUT+1
	JSR PRINT1BYTE		; Print X register

	LDA #$20
	STA PBADDR
	LDA #$96
	STA PBADDR+1
	LDA DBGY
	STA PBINPUT+1
	JSR PRINT1BYTE		; Print Y register

	LDA #$20
	STA PBADDR
	LDA #$A6
	STA PBADDR+1
	LDA DBGSP
	STA PBINPUT+1
	JSR PRINT1BYTE		; Print stack pointer

	LDA #$20
	STA PBADDR
	LDA #$AE
	STA PBADDR+1
	LDA DBGPS
	STA PBINPUT+1
	JSR PRINT1BYTE		; Print processor flags

	LDA #$21
	STA PBADDR
	LDA #$06
	STA PBADDR+1
	LDA MMCPRGMODE
	LSR A
	LSR A
	STA PBINPUT+1
	JSR PRINT1BYTE		; Print MMC1 PRG mode

	LDA #$21
	STA PBADDR
	LDA #$0E
	STA PBADDR+1
	LDA DBGMPB
	STA PBINPUT+1
	JSR PRINT1BYTE		; Print MMC1 PRG bank

	LDA #$21
	STA PBADDR
	LDA #$16
	STA PBADDR+1
	LDA DBGMPD
	LSR A
	LSR A
	LSR A
	LSR A
	STA PBINPUT+1
	JSR PRINT1BYTE		; Print MMC1 PRG RAM status

	LDA #$21
	STA PBADDR
	LDA #$26
	STA PBADDR+1
	LDA MMCCHRMODE
	LSR A
	LSR A
	LSR A
	LSR A
	STA PBINPUT+1
	JSR PRINT1BYTE		; Print MMC1 CHR mode

	LDA #$21
	STA PBADDR
	LDA #$2E
	STA PBADDR+1
	LDA DBGMC0
	STA PBINPUT+1
	JSR PRINT1BYTE		; Print MMC1 CHR bank 0

	LDA #$21
	STA PBADDR
	LDA #$36
	STA PBADDR+1
	LDA MMCCHR1
	STA PBINPUT+1
	JSR PRINT1BYTE		; Print MMC1 CHR bank 1

	LDA #SPR_SZ8
	STA SPRSZ		; Select 8x8 sprite size
	LDA #BG_PT0
	STA BGPT		; Select BG pattern table 0
	LDA #SPR_PT1
	STA SPRPT		; Select sprite pattern table 1
	LDA #NT_SEL0
	STA NT			; Select nametable 0
	JSR UPDATEPPUCTRL

	LDA #0
	STA SCROLLX
	STA SCROLLY		; Set scroll to top left corner
	JSR RESETSCR

	JSR VBWAIT
LOOP:
	;; We have printed the debug information, now we hang indefinitely
	JMP LOOP
.endproc
