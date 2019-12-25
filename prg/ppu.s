.include "ppu.inc"

.segment "ZEROPAGE"
BGEN:		.res 1		; Background render enable
BGNOCROP:	.res 1		; Background leftmost 8px crop disable
BGPT:		.res 1		; Background pattern table to display
CEMPHB:		.res 1 		; PPU blue colour emphasis
CEMPHG:		.res 1		; PPU green colour emphasis
CEMPHR:		.res 1		; PPU red colour emphasis
COLOUREN:	.res 1		; Colour enable
NMIEN:		.res 1		; NMI enable
NMIREADY:	.res 1		; Waiting for next frame
NMITRANSFERS:	.res 1		; NMIPPUCOPY number of transfers (max queue depth 16)
NT:		.res 1		; Nametable to display
PPUCADDR:	.res 2		; PPUCOPY destination address
PPUCINPUT:	.res 2		; PPUCOPY source address
PPUCLEN:	.res 2		; PPUCOPY data length
SCROLLX:	.res 1		; Scroll position X
SCROLLY:	.res 1		; Scroll position Y
SPREN:		.res 1		; Sprite render enable
SPRNOCROP:	.res 1		; Sprite leftmost 8px crop disable
SPRPT:		.res 1		; Sprite pattern table to display
PTEMP:		.res 1		; UPDATEPPUCTRL/UPDATEPPUMASK temp variable
WAITFRAMES:	.res 1		; Number of frames to wait

.segment "BSS"
NMIPPUCADDRH:	.res 16		; NMIPPUCOPY destination addresses (high byte)
NMIPPUCADDRL:	.res 16		; NMIPPUCOPY destination addresses (low byte)
NMIPPUCINPUTH:	.res 16 	; NMIPPUCOPY source addresses (high byte)
NMIPPUCINPUTL:	.res 16		; NMIPPUCOPY source addresses (low byte)
NMIPPUCLENH:	.res 16 	; NMIPPUCOPY data lengths (high byte)
NMIPPUCLENL:	.res 16		; NMIPPUCOPY data lengths (low byte)

.segment "OAM"
SPRITE0:	.res 4		; Sprite zero
SPRITES:	.res 252	; Sprite 1-63

.segment "FUNCS"
.proc CLEARSCREEN
	;; Clears the tiles on the screen and all sprites, takes 2 frames to execute
	;; Input: none
	;; Clobbers: A X Y
	LDA #REND_DIS
	STA SPREN
	STA BGEN
	JSR UPDATEPPUMASK	; Disable rendering

	BIT PPUSTATUS		; Read PPUSTATUS to reset PPUADDR latch
	LDA #$20
	STA PPUADDR
	LDA #$00
	STA PPUADDR
	LDA #$08
	STA PPUCLEN
	LDA #$00
	STA PPUCLEN+1

	LDA #$00
	LDX #$FF
	LDY #$00
L1:
	STA PPUDATA		; Clear nametable 0 and 1 and attributes
	INY
	CPY PPUCLEN+1
	BNE L1
	LDY #$00
	INX
	CPX PPUCLEN
	BNE L1

	JSR VBWAIT		; Wait for next vblank so we don't write too much data at once

	BIT PPUSTATUS		; Read PPUSTATUS to reset PPUADDR latch
	LDA #$3F
	STA PPUADDR
	LDA #$00
	STA PPUADDR
	LDA #32
	STA PPUCLEN+1

	LDA #$0F		; 0F sets the palette colours to all black
	LDY #$00
L2:
	STA PPUDATA		; Clear palette table
	INY
	CPY PPUCLEN+1
	BNE L2

	JSR CLEARSPR		; Clear sprites from screen
	JSR RESETSCR		; Reset PPU scrolling
	JSR UPDATEPPUCTRL	; Update PPU controls

	RTS
.endproc

.proc CLEARSPR
	;; Clears the sprites from the screen
	;; Input: none
	;; Clobbers: A X
	LDA #$FF		; FF moves the sprites off the screen
	LDX #$00
L1:
	STA OAM, X		; Remove all sprites from screen
	INX
	BNE L1

	RTS
.endproc

.proc NMIPPUCOPY
	;; Performs PPUCOPYS that were queued for NMI (max queue depth 16)
	;; Input: NMITRANSFERS NMIPPUCADDR NMIPPUCINPUT NMIPPUCLEN
	;; Clobbers: A X
	LDX NMITRANSFERS	; Get number of transfers
	BEQ DONE		; Bail out if we have nothing to do
L1:
	DEX
	STX NMITRANSFERS	; Pop a transfer off the list

	LDA NMIPPUCADDRH, X
	STA PPUCADDR
	LDA NMIPPUCADDRL, X
	STA PPUCADDR+1

	LDA NMIPPUCINPUTH, X
	STA PPUCINPUT
	LDA NMIPPUCINPUTL, X
	STA PPUCINPUT+1

	LDA NMIPPUCLENH, X
	STA PPUCLEN
	LDA NMIPPUCLENL, X
	STA PPUCLEN+1		; Set up transfer

	TXA
	PHA			; Save number of transfers
	JSR PPUCOPY		; Do current transfer
	PLA			; Restore number of transfers
	TAX

	BNE L1			; Keep going if we have more transfers
DONE:
	RTS
.endproc

.proc PPUCOPY
	;; Copies lengths of data from the CPU to the PPU
	;; Input: PPUCADDR PPUCLEN PPUCINPUT
	;; Clobbers: A X Y
	LDA PPUCLEN
	BNE SETUP
	LDA PPUCLEN+1
	BNE SETUP		; Verify length is not zero
	BRK

SETUP:
	BIT PPUSTATUS		; Read PPUSTATUS to reset PPUADDR latch
	LDA PPUCADDR
	STA PPUADDR
	LDA PPUCADDR+1
	STA PPUADDR		; Read address and set PPUADDR

	LDX #$00
	LDY #$00		; Set loop counters
L1:
	LDA (PPUCINPUT), Y	; Load data
	STA PPUDATA		; Store to PPU
	INY
	CPY PPUCLEN+1
	BNE L1
	LDA PPUCLEN
	BEQ DONE
	INX
	CPX PPUCLEN		; Check to see if we have finished copying
	BEQ DONE		; Loop if we have not finished copying
	INC PPUCINPUT+1
	JMP L1
DONE:
	JSR RESETSCR		; Reset PPU scrolling

	RTS
.endproc

.proc RESETSCR
	;; Resets scrolling to the correct position
	;; Input: SCROLLX SCROLLY
	;; Clobbers: A
	BIT PPUSTATUS		; Read PPUSTATUS to reset PPUADDR latch

	LDA SCROLLX
	STA PPUSCROLL
	LDA SCROLLY
	STA PPUSCROLL		; Reset PPU scrolling

	RTS
.endproc

.proc UPDATEPPUCTRL
	;; Selects background/sprite pattern tables, nametables, enables/disables NMI
	;; Input: BGPT SPRPT NT NMIEN
	;; Clobbers: A
	LDA NMIEN
	AND #NMI_EN
	STA PTEMP		; Bit 7 - NMI enable toggle

	; TODO - bit 6 - PPU master/slave selection

	; TODO - bit 5 - Sprite size selection

	LDA BGPT
	AND #BG_PT1
	ORA PTEMP
	STA PTEMP		; Bit 4 - BG pattern table selection

	LDA SPRPT
	AND #SPR_PT1
	ORA PTEMP
	STA PTEMP		; Bit 3 - SPR pattern table selection

	; TODO - bit 2 - VRAM address increment mode

	LDA NT
	AND #NT_SEL3
	ORA PTEMP
	STA PTEMP		; Bits 1 and 0 - Nametable selection

	BIT PPUSTATUS		; Read PPUSTATUS to clear vblank
	STA PPUCTRL		; Write combined bitfield to PPUCTRL

	RTS
.endproc

.proc UPDATEPPUMASK
	;; Sets b+w/colour modes, enables leftmost 8px cropping, enables rendering, and colour emphasis
	;; Input: COLOUREN BGNOCROP SPRNOCROP BGEN SPREN CEMPHR CEMPHG CEMPHB
	;; Clobbers: A
	LDA CEMPHB
	AND #CLR_EMPH_BLUE
	STA PTEMP		; Bit 7 - Colour emphasis blue

	LDA CEMPHG
	AND #CLR_EMPH_GREEN
	ORA PTEMP
	STA PTEMP		; Bit 6 - Colour emphasis green

	LDA CEMPHR
	AND #CLR_EMPH_RED
	ORA PTEMP
	STA PTEMP		; Bit 5 - Colour emphasis red

	LDA SPREN
	AND #SPR_REND_EN
	ORA PTEMP
	STA PTEMP		; Bit 4 - SPR rendering enable

	LDA BGEN
	AND #BG_REND_EN
	ORA PTEMP
	STA PTEMP		; Bit 3 - BG rendering enable

	LDA SPRNOCROP
	AND #SPR_REND_NOCROP
	ORA PTEMP
	STA PTEMP		; Bit 2 - SPR leftmost 8px cropping

	LDA BGNOCROP
	AND #BG_REND_NOCROP
	ORA PTEMP
	STA PTEMP		; Bit 1 - BG leftmost 8px cropping

	LDA COLOUREN
	AND #CLR_GRAY
	ORA PTEMP
	STA PTEMP		; Bit 0 - Colour enable

	STA PPUMASK		; Write combined bitfield to PPUMASK

	RTS
.endproc

.proc VBWAIT
	;; Waits for the next vblank, or a number of vblanks
	;; Input: WAITFRAMES
	;; Clobbers: A X
	INC NMIREADY		; Store waiting status
L1:
	LDA NMIREADY		; Load waiting status
	BNE L1			; Loop if still waiting
	LDX WAITFRAMES
	BEQ DONE			; Loop if we need to wait more frames
	INC NMIREADY
	JMP L1
DONE:
	RTS
.endproc
