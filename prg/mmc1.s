.include "mmc1.inc"
.include "vectors.inc"

; The following macro and stubs:
; Copyright 2011 Damian Yerrick
;
; Copying and distribution of this file, with or without
; modification, are permitted in any medium without royalty provided
; the copyright notice and this notice are preserved in all source
; code copies.  This file is offered as-is, without any warranty.
.macro resetstub_in segname
.segment segname
.scope
resetstub_entry:
	SEI
	LDX #$FF
	TXS
	STX $8000
	JMP RESET
.addr NMI, resetstub_entry, IRQ
.endscope
.endmacro

.segment "CODE"
resetstub_in "STUB0"
resetstub_in "STUB1"
resetstub_in "STUB2"
resetstub_in "STUB3"
resetstub_in "STUB4"
resetstub_in "STUB5"
resetstub_in "STUB6"
resetstub_in "STUB7"
resetstub_in "STUB8"
resetstub_in "STUB9"
resetstub_in "STUB10"
resetstub_in "STUB11"
resetstub_in "STUB12"
resetstub_in "STUB13"
resetstub_in "STUB14"
resetstub_in "STUB15"

.segment "ZEROPAGE"
MMCCHR0:	.res 1	; MMC1 selectable CHR ROM bank 0
MMCCHR1:	.res 1	; MMC1 selectable CHR ROM bank 1
MMCCHRMODE:	.res 1	; MMC1 CHR bank mode
MMCMIRROR:	.res 1	; MMC1 nametable mirroring mode
MMCPRG:		.res 1	; MMC1 selectable PRG ROM bank
MMCPRGMODE:	.res 1	; MMC1 PRG bank mode
MMCRAM:		.res 1	; MMC1 PRG RAM enable flag
MTEMP:		.res 1	; UPDATEMMC1CTRL/UPDATEMMC1PRG temp variable

.segment "FUNCS"
.proc UPDATEMMC1CHR0
	;; Selects the first CHR ROM bank
	;; Input: MMCCHR0
	;; Clobbers: A
	LDA MMCCHR0
	AND #MMC1_CHR_BANKS

	STA MMC1CHR0
	LSR A
	STA MMC1CHR0
	LSR A
	STA MMC1CHR0
	LSR A
	STA MMC1CHR0
	LSR A
	STA MMC1CHR0		; Write bitfield to MMC1CHR0

	RTS
.endproc

.proc UPDATEMMC1CHR1
	;; Selects the second CHR ROM bank
	;; Input: MMCCHR1
	;; Clobbers: A
	LDA MMCCHR1
	AND #MMC1_CHR_BANKS

	STA MMC1CHR1
	LSR A
	STA MMC1CHR1
	LSR A
	STA MMC1CHR1
	LSR A
	STA MMC1CHR1
	LSR A
	STA MMC1CHR1		; Write bitfield to MMC1CHR1

	RTS
.endproc

.proc UPDATEMMC1CTRL
	;; Sets PRG ROM and CHR ROM bank modes and nametable mirroring mode
	;; Input: MMCCHRMODE MMCPRGMODE MMCMIRROR
	;; Clobbers: A
	LDA MMCCHRMODE
	AND #MMC1_CHR_MODE1
	STA MTEMP		; Bit 4 - MMC1 CHR ROM bank mode

	LDA MMCPRGMODE
	AND #MMC1_PRG_MODE3
	ORA MTEMP
	STA MTEMP		; Bits 3 and 2 - MMC1 PRG ROM bank mode

	LDA MMCMIRROR
	AND #MMC1_MIRROR_H
	ORA MTEMP
	STA MTEMP		; Bits 1 and 0 - MMC1 mirroring mode

	STA MMC1CTRL
	LSR A
	STA MMC1CTRL
	LSR A
	STA MMC1CTRL
	LSR A
	STA MMC1CTRL
	LSR A
	STA MMC1CTRL		; Write combined bitfield to MMC1CTRL

	RTS
.endproc

.proc UPDATEMMC1PRG
	;; Enables/disables PRG RAM and selects the PRG ROM bank
	;; Input: MMCRAM MMCPRG
	;; Clobbers: A
	LDA MMCRAM
	AND #MMC1_PRGRAM_DIS
	STA MTEMP		; Bit 4 - PRG RAM toggle, ignored on MMC1A

	LDA MMCPRG
	AND #MMC1_PRG_BANK15
	ORA MTEMP
	STA MTEMP		; Bits 3 to 0 - PRG ROM bank

	STA MMC1PRG
	LSR A
	STA MMC1PRG
	LSR A
	STA MMC1PRG
	LSR A
	STA MMC1PRG
	LSR A
	STA MMC1PRG		; Write combined bitfield to MMC1PRG

	RTS
.endproc
