.include "apu.inc"
.include "cpu.inc"
.include "debug.inc"
.include "joys.inc"
.include "mainmenu.inc"
.include "mmc1.inc"
.include "ppu.inc"
.include "vectors.inc"

.segment "VECS"
.proc NMI
	PHA
	TXA
	PHA
	TYA
	PHA			; Push A/X/Y onto the stack

	LDA NMIREADY		; Load waiting status
	BEQ OUT			; if we are not waiting, bail out of NMI

	JSR NMIPPUCOPY		; Do queued PPU RAM copy transfers

	LDA #$00
	STA OAMADDR
	LDA #$02
	STA OAMDMA		; DMA transfer $0200-$02FF to PPU OAM

	LDA #SPR_REND_EN
	STA SPREN
	LDA #BG_REND_EN
	STA BGEN
	JSR UPDATEPPUMASK	; Enable rendering

	JSR READJOYS		; Read controllers

	DEC NMIREADY		; Reset waiting status
	LDA WAITFRAMES
	BEQ OUT
	DEC WAITFRAMES

OUT:
	LDA SOUNDREADY
	BEQ SOUNDNOTINIT
;	soundengine_update	; Play sound

SOUNDNOTINIT:
	PLA
	TAY
	PLA
	TAX
	PLA			; Pull A/X/Y from the stack

	RTI			; Exit NMI
.endproc

.proc RESET
	SEI			; Disable IRQ
	CLD			; Disable decimal mode
	LDX #%01000000
	STX APUFRAME		; Disable APU frame IRQ
	LDX #$FF
	TXS			; Initialize stack pointer
	INX			; Roll X over back to #$00
	STX PPUCTRL		; Disable PPU vblank NMI
	STX PPUMASK		; Disable PPU rendering
	STX DMCFREQ		; Disable APU DMC IRQ
	BIT PPUSTATUS		; Clear vblank bit if console reset during a vblank

VB1:
	BIT PPUSTATUS
	BPL VB1			; Wait for first vblank

MEMCLR:
	LDA #$FF
	STA $0200, X		; Initialize WRAM copy of PPU OAM
	LDA #$00
	STA $0000, X
	STA $0100, X
	STA $0300, X
	STA $0400, X
	STA $0500, X
	STA $0600, X
	STA $0700, X		; Initialize WRAM
	INX
	BNE MEMCLR

VB2:
	BIT PPUSTATUS
	BPL VB2			; Wait for second vblank	

MMC1INIT:
	LDA #MMC1_CHR_MODE1
	STA MMCCHRMODE		; CHR mode 1 (2x4k switchable pattern tables)
	LDA #MMC1_MIRROR_V
	STA MMCMIRROR		; Vertical mirroring selected
	LDA #MMC1_PRG_MODE3
	STA MMCPRGMODE		; PRG mode 3 (bank 15 fixed to CPU $C000, switchable $8000)
	JSR UPDATEMMC1CTRL

	LDA #MMC1_PRG_BANK0
	STA MMCPRG		; PRG bank 0 selected at CPU $8000
	LDA #MMC1_PRGRAM_DIS
	STA MMCRAM		; PRG RAM disabled (MMC1B on by default, ignored by MMC1A)
	JSR UPDATEMMC1PRG

	LDA #MMC1_CHR_BANK0
	STA MMCCHR0		; CHR bank 0 selected at PPU $0000
	JSR UPDATEMMC1CHR0

	LDA #MMC1_CHR_BANK1
	STA MMCCHR1		; CHR bank 1 selected at PPU $1000
	JSR UPDATEMMC1CHR1

	LDA #NMI_EN
	STA NMIEN		; Enable NMI
	JSR UPDATEPPUCTRL
	JSR CLEARSCREEN		; Clear the screen
	JMP MAINMENU		; Go to main menu
.endproc

.proc IRQ
	STA DBGA		; Stash accumulator
	PLA			; Pull processor status from the stack
	PHA			; Return processor status to the stack
	AND #CPU_FLAG_B		; Check for "B flag"
	BEQ NOBRK		; Branch if not set
	JMP BREAK		; Jump to break handler
NOBRK:
	;; TODO - sound code IRQ?

	LDA DBGA		; Restore accumulator
	RTI			; Exit IRQ
.endproc
