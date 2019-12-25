.include "apu.inc"
.include "joys.inc"
.include "mainmenu.inc"
.include "mmc1.inc"
.include "options.inc"
.include "ppu.inc"
.include "sram.inc"

.segment "BSS"
CONTINUELEVEL:	.res 1	; Level to start on from main menu
MUSICEN:	.res 1	; Music toggle
OPTIONSDRAWN:	.res 1	; Whether the options screen has been drawn
SKIPSRAMTEST:	.res 1	; Skip PRG RAM tests

.segment "MENUD"
OPTIONSBG:
	.incbin "options.nam"

MUSICATTROFF:
	.byte $00,$A0

MUSICATTRON:
	.byte $20,$00


.segment "MENUS"
.proc OPTIONS
	LDA OPTIONSDRAWN
	BEQ DRAW		; Check if we have already drawn the screen
	JMP RETURNTOOPTIONS
DRAW:
	;; Draw the screen
	LDA #REND_DIS
	STA SPREN
	STA BGEN
	JSR UPDATEPPUMASK	; Disable rendering

	; TODO - We use the main menus palettes

	LDA #$24
	STA PPUCADDR
	LDA #$00
	STA PPUCADDR+1
	LDA #$04
	STA PPUCLEN
	LDA #$00
	STA PPUCLEN+1
	LDA #<OPTIONSBG
	STA PPUCINPUT
	LDA #>OPTIONSBG
	STA PPUCINPUT+1
	JSR PPUCOPY		; Load options BG tiles into PPU

	LDA #1
	STA OPTIONSDRAWN
RETURNTOOPTIONS:
	;; We return here from the main menu since the options screen should already be
	;; drawn from a previous draw
	LDA #BG_PT0
	STA BGPT		; Select BG pattern table 0
	LDA #SPR_PT1
	STA SPRPT		; Select sprite pattern table 1
	LDA #NT_SEL1
	STA NT			; Select nametable 1
	JSR UPDATEPPUCTRL	; Update PPU controls

	LDX NMITRANSFERS

	LDA #$27
	STA NMIPPUCADDRH, X
	LDA #$D4
	STA NMIPPUCADDRL, X

	LDA #0
	STA NMIPPUCLENH, X
	LDA #2
	STA NMIPPUCLENL, X

	LDA MUSICEN		; Check if music is disabled
	BEQ MUSICOFF

	LDA #<MUSICATTRON
	STA NMIPPUCINPUTH, X
	LDA #>MUSICATTRON
	STA NMIPPUCINPUTL, X	; Music on attributes
	JMP MUSICDONE
MUSICOFF:
	LDA #<MUSICATTROFF
	STA NMIPPUCINPUTH, X
	LDA #>MUSICATTROFF
	STA NMIPPUCINPUTL, X	; Music off attributes
MUSICDONE:
	INX
	STX NMITRANSFERS	; Load music on/off toggle attributes into PPU during NMI

	; TODO - drawing a sprite like this is ugly but works for now
	LDA #$30
	STA ARROWX
	LDA #$58
	STA ARROWY
	LDA #$01
	STA ARROWTILE
	LDA #SPR_PALETTE0
	STA ARROWATTR		; Draw the options cursor

	JSR VBWAIT		; Wait for next vblank
	JMP OPTIONSLOOP		; Enter input loop
.endproc

.proc OPTIONSLOOP
	;; 30,58 "music" cursor position
	;; 30,98 "reset" cursor position
	;; 30,B8 "return" cursor position
	LDA JOY1IN
	BNE DOWNMUSIC
	JMP DONE		; Skip loop if player 1 is not pressing buttons
DOWNMUSIC:
	LDA JOY1IN
	AND #BUTTON_DOWN	; Check if player 1 is pressing down
	BEQ UPRESET
	LDA ARROWY
	CMP #$58		; Check if the cursor is in the top position
	BNE DOWNRESET
	LDA #$98
	STA ARROWY		; Move cursor down

	JMP OPTIONSDOUT
DOWNRESET:
	LDA ARROWY
	CMP #$98		; Check if the cursor is in the middle position
	BNE OPTIONSDOUT
	LDA #$B8
	STA ARROWY		; Move cursor down
OPTIONSDOUT:
	JMP DONE

UPRESET:
	LDA JOY1IN
	AND #BUTTON_UP		; Check if player 1 is pressing up
	BEQ LMUSIC
	LDA ARROWY
	CMP #$98		; Check if the cursor is in the middle position
	BNE UPRETURN
	LDA #$58
	STA ARROWY		; Move cursor up

	JMP OPTIONSUOUT
UPRETURN:
	CMP #$B8		; Check if the cursor is in the bottom position
	BNE OPTIONSUOUT
	LDA #$98
	STA ARROWY		; Move cursor up
OPTIONSUOUT:
	JMP DONE

LMUSIC:
	LDA JOY1IN
	AND #BUTTON_LEFT	; Check if player 1 is pressing left
	BEQ RMUSIC
	LDA ARROWY
	CMP #$58		; Check if the cursor is in the top position
	BNE OPTIONSLOUT
	LDA MUSICEN		; Check if music is disabled
	BNE OPTIONSLOUT
	LDA #1			; Turn music toggle on
	STA MUSICEN

	LDX NMITRANSFERS

	LDA #$27
	STA NMIPPUCADDRH, X
	LDA #$D4
	STA NMIPPUCADDRL, X
	LDA #0
	STA NMIPPUCLENH, X
	LDA #2
	STA NMIPPUCLENL, X
	LDA #<MUSICATTRON
	STA NMIPPUCINPUTH, X
	LDA #>MUSICATTRON
	STA NMIPPUCINPUTL, X

	INX
	STX NMITRANSFERS	; Load attributes of music toggle into PPU during NMI

;	LDA #song_index_New20song
;	STA <sound_param_byte_0
;	JSR play_song		; Start music
OPTIONSLOUT:
	JMP DONE

RMUSIC:
	LDA JOY1IN
	AND #BUTTON_RIGHT	; Check if player 1 is pressing right
	BEQ STRETURN
	LDA ARROWY
	CMP #$58		; Check if the cursor is in the top position
	BNE OPTIONSROUT
	LDA MUSICEN		; Check if music is enabled
	BEQ OPTIONSROUT
	LDA #0
	STA MUSICEN		; Turn music toggle off

;	JSR pause_song		; Stop music

	LDX NMITRANSFERS

	LDA #$27
	STA NMIPPUCADDRH, X
	LDA #$D4
	STA NMIPPUCADDRL, X
	LDA #0
	STA NMIPPUCLENH, X
	LDA #2
	STA NMIPPUCLENL, X
	LDA #<MUSICATTROFF
	STA NMIPPUCINPUTH, X
	LDA #>MUSICATTROFF
	STA NMIPPUCINPUTL, X

	INX
	STX NMITRANSFERS	; Load attributes of music toggle into PPU during NMI
OPTIONSROUT:
	JMP DONE

STRETURN:
	LDA JOY1IN
	AND #BUTTON_START	; Check if player 1 is pressing start
	BEQ DONE
	LDA ARROWY
	CMP #$B8		; Check if the cursor is in the bottom position
	BNE DONE

	JSR SHOWSAVEICON

	LDA #MMC1_PRGRAM_EN
	STA MMCRAM
	JSR UPDATEMMC1PRG	; Enable PRG RAM

	LDA MUSICEN
	STA SRAMMUSIC		; Save music toggle to PRG RAM

	LDA #MMC1_PRGRAM_DIS
	STA MMCRAM
	JSR UPDATEMMC1PRG	; Disable PRG RAM

	JSR HIDESAVEICON

	JSR CLEARSPR
	JSR VBWAIT
	JMP MAINMENU
DONE:
	JSR VBWAIT		; Wait for next vblank
	JMP OPTIONSLOOP		; Repeat input loop
.endproc
