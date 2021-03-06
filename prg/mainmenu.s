.include "apu.inc"
.include "joys.inc"
.include "level1.inc"
.include "mainmenu.inc"
.include "mmc1.inc"
.include "options.inc"
.include "ppu.inc"
.include "sram.inc"

.segment "BSS"
BUTTONHELD:	.res 1	; Whether a button is being held down
MENUDRAWN:	.res 1	; Whether the menu screen has been drawn

.segment "FUNCS"
.proc STARTNEWGAME
	LDA #MMC1_PRG_BANK1
	STA MMCPRG
	JSR UPDATEMMC1PRG	; Switch bank to bank 1

	JMP LEVEL1		; Start new game
.endproc

.segment "MENUD"
MENUBG:
	.incbin "mainmenu.nam"

MENUPALS:
	.incbin "mainmenu.pal"
	.incbin "mainmenu-spr.pal"

MENUTEXT1:
	.byte "New game"

MENUTEXT2:
	.byte "Continue"

.segment "MENUS"
.proc MAINMENU
	LDA MENUDRAWN
	BEQ DRAW		; Check if we have already drawn the screen
	JMP RETURNTOMENU
DRAW:
	;; Draw the screen
	LDA #REND_DIS
	STA SPREN
	STA BGEN
	LDA #REND_CROP_DIS
	STA BGNOCROP
	STA SPRNOCROP
	JSR UPDATEPPUMASK	; Disable rendering

	LDA #PD_INC1
	STA PDINC		; Select 1x PPUDATA address increment mode
	JSR UPDATEPPUCTRL

	LDA #$3F
	STA PPUCADDR
	LDA #$00
	STA PPUCADDR+1
	LDA #0
	STA PPUCLEN
	LDA #32
	STA PPUCLEN+1
	LDA #<MENUPALS
	STA PPUCINPUT
	LDA #>MENUPALS
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
	LDA #<MENUBG
	STA PPUCINPUT
	LDA #>MENUBG
	STA PPUCINPUT+1
	JSR PPUCOPY		; Load main menu BG tiles into PPU

	LDA #1
	STA MENUDRAWN
RETURNTOMENU:
	;; We return here from the options screen since the main menu screen should already be
	;; drawn from the initial startup
	LDA #SPR_SZ8
	STA SPRSZ		; Select 8x8 sprite size
	LDA #BG_PT0
	STA BGPT		; Select BG pattern table 0
	LDA #SPR_PT1
	STA SPRPT		; Select sprite pattern table 1
	LDA #NT_SEL0
	STA NT			; Select nametable 0
	JSR UPDATEPPUCTRL	; Update PPU controls

	LDA #0
	STA SCROLLX
	STA SCROLLY		; Set initial scroll to top left corner

	LDA SKIPSRAMTEST
	BEQ SRAMTESTSTART
	JMP SKIPTEST		; Skip test if we have already run it
SRAMTESTSTART:
	;; Test the PRG RAM for valid data
	JSR SHOWSAVEICON	; Show the save icon while PRG RAM is active

	LDA #MMC1_PRGRAM_EN
	STA MMCRAM
	JSR UPDATEMMC1PRG	; Enable PRG RAM

	JSR SRAMTESTA		; Verify header and footer
	BNE SRAMTESTRUNC	; TODO - change to B when we have a checksum test
	JMP SRAMTESTFAIL
;SRAMTESTRUNB:
;	JSR SRAMTESTB		; Verify option variable checksum
;	BNE SRAMTESTRUNC
;	JMP SRAMTESTFAIL
SRAMTESTRUNC:
	JSR SRAMTESTC		; Verify option variable bounds
	BNE SRAMTESTDONE
	; TODO - additional tests here?
SRAMTESTFAIL:
	;; We failed a test, wipe PRG RAM
	JSR SHOWERRORICON	; Show the error icon
	JSR SRAMWIPE		; Wipe PRG RAM
SRAMTESTDONE:
	;; We passed all tests, or are working with a freshly initialized PRG RAM
	LDA SRAMMUSIC
	STA MUSICEN		; Load music toggle from PRG RAM and store to WRAM
	LDA SRAMCONTINUE
	STA CONTINUELEVEL	; Load continue level from PRG RAM and store to WRAM

	LDA #MMC1_PRGRAM_DIS
	STA MMCRAM
	JSR UPDATEMMC1PRG	; Disable PRG RAM until we need it again

	JSR HIDESAVEICON	; Hide the save icon

	LDA #1
	STA SKIPSRAMTEST	; Mark tests as done so we can skip them if we run the main menu again
	STA SOUNDREADY

; sound init code here

	LDA MUSICEN
	BEQ SKIPTEST		; Check if music is enabled

; play music here

SKIPTEST:
	;; We skipped the tests because we ran them already
	LDX NMITRANSFERS

	LDA #$22
	STA NMIPPUCADDRH, X
	LDA #$4C
	STA NMIPPUCADDRL, X

	LDA #0
	STA NMIPPUCLENH, X
	LDA #8
	STA NMIPPUCLENL, X

	LDA CONTINUELEVEL
	BNE CONTINUE		; Check if we are starting a new game or continuing from save
	LDA #<MENUTEXT1
	STA NMIPPUCINPUTH, X
	LDA #>MENUTEXT1
	STA NMIPPUCINPUTL, X	; New game text
	JMP OUT
CONTINUE:
	LDA #<MENUTEXT2
	STA NMIPPUCINPUTH, X
	LDA #>MENUTEXT2
	STA NMIPPUCINPUTL, X	; Continue text
OUT:
	INX
	STX NMITRANSFERS	; Load menu new game / continue text into PPU during NMI

	; TODO - drawing a sprite like this is ugly but works for now
	LDA #$50
	STA ARROWX
	LDA #$90
	STA ARROWY
	LDA #$01
	STA ARROWTILE
	LDA #SPR_PALETTE0
	STA ARROWATTR		; Draw a basic cursor sprite

	JSR VBWAIT		; Wait for next vblank
	JMP MENULOOP		; Enter input loop
.endproc

.proc MENULOOP
	;; 50,90 "start/continue" cursor position
	;; 50,A0 "options" cursor position
	;; 50,B0 "credits" cursor position
	LDA JOY1IN
	BNE READY
	LDA #0
	STA BUTTONHELD
	JMP DONE2		; Skip loop if player 1 is not pressing buttons

READY:
	LDA BUTTONHELD
	BEQ DOWNSTART
	JMP DONE2		; Skip loop if player 1 is holding buttons
DOWNSTART:
	LDA JOY1IN
	AND #BUTTON_DOWN	; Check if player 1 is pressing down
	BEQ UPOPTIONS
	LDA ARROWY
	CMP #$90		; Check if the cursor is in the top position
	BNE DOWNOPTIONS
	LDA #$A0
	STA ARROWY		; Move cursor down
	JMP MENUDOUT
DOWNOPTIONS:
	LDA ARROWY
	CMP #$A0		; Check if the cursor is in the middle position
	BNE DONE2
	LDA #$B0
	STA ARROWY		; Move cursor down
MENUDOUT:
	JMP DONE

UPOPTIONS:
	LDA JOY1IN
	AND #BUTTON_UP		; Check if player 1 is pressing up
	BEQ STNEW
	LDA ARROWY
	CMP #$A0		; Check if the cursor is in the middle position
	BNE UPCREDITS
	LDA #$90
	STA ARROWY		; Move cursor up
	JMP MENUUOUT
UPCREDITS:
	LDA ARROWY
	CMP #$B0		; Check if the cursor is in the bottom position
	BNE DONE2
	LDA #$A0
	STA ARROWY		; Move cursor up
MENUUOUT:
	JMP DONE

STNEW:
	LDA JOY1IN
	AND #BUTTON_START	; Check if player 1 is pressing start
	BEQ DONE2
	LDA ARROWY
	CMP #$90		; Check if the cursor is in the top position
	BNE STOPTS
;	JSR pause_song		; Stop music
	LDA #1
	STA BUTTONHELD
	LDA #15
	STA WAITFRAMES
	JSR VBWAIT
	JSR CLEARSCREEN		; Clear screen
	LDA #0
	STA MENUDRAWN
	STA OPTIONSDRAWN
	LDA CONTINUELEVEL	; Check if we are starting a new game or continuing from save
	BNE STCONTINUE
	JMP STARTNEWGAME	; Go to new game
STCONTINUE:
	LDA CONTINUELEVEL
	;; TODO - jump to level
	BRK
STOPTS:
	LDA ARROWY
	CMP #$A0		; Check if the cursor is in the middle position
	BNE DONE2
	JSR CLEARSPR		; Clear sprites from the screen
	LDA #1
	STA BUTTONHELD
	LDA #15
	STA WAITFRAMES
	JSR VBWAIT
	JMP OPTIONS		; Go to game options menu

DONE:
	LDA #1
	STA BUTTONHELD
DONE2:
	JSR VBWAIT		; Wait for next vblank
	JMP MENULOOP		; Repeat input loop
.endproc
