.include "apu.inc"
.include "joys.inc"
.include "mainmenu.inc"
.include "mmc1.inc"
.include "options.inc"
.include "ppu.inc"

.segment "BSS"
CONTINUELEVEL:	.res 1	; Level to start on from main menu
MUSICEN:	.res 1	; Music toggle
SKIPSRAMTEST:	.res 1	; Skip PRG RAM tests

.segment "MENUD"
MUSICATTROFF:
	.byte $00,$80,$20

MUSICATTRON:
	.byte $20,$00,$00

OPTIONSATTR:
	.byte $00,$00,$00,$00,$00,$00,$00,$00	; Top 2 rows of screen
	.byte $00,$00,$04,$05,$05,$01,$00,$00	; Second 2 rows of screen
	.byte $00,$00,$00,$00,$00,$00,$00,$00	; Third 2 rows of screen
	.byte $00,$00,$00,$00,$00,$00,$00,$00	; Fourth 2 rows of screen
	.byte $00,$00,$00,$00,$00,$00,$00,$00	; Fifth 2 rows of screen
	.byte $00,$00,$00,$00,$00,$00,$00,$00	; Sixth 2 rows of screen
	.byte $00,$00,$00,$00,$00,$00,$00,$00	; Seventh 2 rows of screen
	.byte $00,$00,$00,$00,$00,$00,$00,$00	; Last 2 rows of screen (lower nibbles)

OPTIONSTEXT:
	.byte "- Options -"

OPTIONSTEXT1:
	.byte "Music:    On    Off"

OPTIONSTEXT2:
	.byte "Clear checkpoint"

OPTIONSTEXT3:
	.byte "Return to main menu"

.segment "MENU"
.proc OPTIONS
	LDA #REND_DIS
	STA SPREN
	STA BGEN
	JSR UPDATEPPUMASK	; Disable rendering

	LDA #$24
	STA PPUCADDR
	LDA #$AA
	STA PPUCADDR+1
	LDA #0
	STA PPUCLEN
	LDA #11
	STA PPUCLEN+1
	LDA #<OPTIONSTEXT
	STA PPUCINPUT
	LDA #>OPTIONSTEXT
	STA PPUCINPUT+1
	JSR PPUCOPY		; Load options title text into PPU

	LDA #$25
	STA PPUCADDR
	LDA #$66
	STA PPUCADDR+1
	LDA #0
	STA PPUCLEN
	LDA #19
	STA PPUCLEN+1
	LDA #<OPTIONSTEXT1
	STA PPUCINPUT
	LDA #>OPTIONSTEXT1
	STA PPUCINPUT+1
	JSR PPUCOPY		; Load options music text into PPU

	LDA #$26
	STA PPUCADDR
	LDA #$26
	STA PPUCADDR+1
	LDA #0
	STA PPUCLEN
	LDA #16
	STA PPUCLEN+1
	LDA #<OPTIONSTEXT2
	STA PPUCINPUT
	LDA #>OPTIONSTEXT2
	STA PPUCINPUT+1
	JSR PPUCOPY		; Load options reset text into PPU

	LDA #$26
	STA PPUCADDR
	LDA #$86
	STA PPUCADDR+1
	LDA #0
	STA PPUCLEN
	LDA #20
	STA PPUCLEN+1
	LDA #<OPTIONSTEXT3
	STA PPUCINPUT
	LDA #>OPTIONSTEXT3
	STA PPUCINPUT+1
	JSR PPUCOPY		; Load options return text into PPU

	LDA #$27
	STA PPUCADDR
	LDA #$C0
	STA PPUCADDR+1
	LDA #0
	STA PPUCLEN
	LDA #64
	STA PPUCLEN+1
	LDA #<OPTIONSATTR
	STA PPUCINPUT
	LDA #>OPTIONSATTR
	STA PPUCINPUT+1
	JSR PPUCOPY		; Load menu BG attributes into PPU

	;; TODO - We use the main menus palettes
	;; TODO - Return here from main menu if we were in the options menu previously

	LDA #BG_PT0
	STA BGPT		; Select BG pattern table 0
	LDA #SPR_PT1
	STA SPRPT		; Select sprite pattern table 1
	LDA #NT_SEL1
	STA NT			; Select nametable 1
	JSR UPDATEPPUCTRL	; Update PPU controls

	LDA MUSICEN		; Check if music is disabled
	BEQ MUSICOFF

	LDA #<MUSICATTRON
	STA PPUCINPUT
	LDA #>MUSICATTRON
	STA PPUCINPUT+1
	JMP MUSICDONE

MUSICOFF:
	LDA #<MUSICATTROFF
	STA PPUCINPUT
	LDA #>MUSICATTROFF
	STA PPUCINPUT+1

MUSICDONE:
	LDA #$27
	STA PPUCADDR
	LDA #$D4
	STA PPUCADDR+1
	LDA #0
	STA PPUCLEN
	LDA #3
	STA PPUCLEN+1
	JSR PPUCOPY		; Change attributes of music toggle based on state

;	LDA #$20
;	STA SPR1X
;	LDA #$58
;	STA SPR1Y
;	LDA #$01
;	STA SPR1TILE
;	LDA #SPR_PALETTE0
;	STA SPR1ATTR		; Draw the options cursor

	JSR VBWAIT		; Wait for next vblank
	JMP OPTIONSLOOP		; Enter input loop
.endproc

.proc OPTIONSLOOP


	JSR VBWAIT		; Wait for next vblank
	JMP OPTIONSLOOP		; Repeat input loop
.endproc
