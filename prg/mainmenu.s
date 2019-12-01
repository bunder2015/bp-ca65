.include "apu.inc"
.include "joys.inc"
.include "level1.inc"
.include "mainmenu.inc"
.include "mmc1.inc"
.include "options.inc"
.include "ppu.inc"
.include "sram.inc"

.segment "BSS"
MENUDRAWN:	.res 1	; Whether the menu screen has been drawn

.segment "FUNCS"
.proc STARTNEWGAME
	LDA #MMC1_PRG_BANK1
	STA MMCPRG
	JSR UPDATEMMC1PRG	; Switch bank to bank 1

	JMP LEVEL1		; Start new game
.endproc

.segment "MENUD"
MENUATTR:
	.byte $00,$00,$00,$00,$00,$00,$00,$00	; Top 2 rows of screen
	.byte $00,$00,$00,$00,$00,$00,$00,$00	; Second 2 rows of screen
	.byte $00,$00,$55,$55,$55,$55,$11,$00	; Third 2 rows of screen
	.byte $00,$00,$05,$05,$05,$05,$01,$00	; Fourth 2 rows of screen
	.byte $00,$00,$00,$00,$00,$00,$00,$00	; Fifth 2 rows of screen
	.byte $00,$00,$00,$00,$00,$00,$00,$00	; Sixth 2 rows of screen
	.byte $00,$00,$00,$00,$00,$00,$00,$00	; Seventh 2 rows of screen
	.byte $00,$00,$00,$00,$00,$00,$00,$00	; Last row of screen (lower nibbles)

MENUBG:
	.byte $00,$00,$00,$00,$00,$00,$00,$00,$80,$81,$81,$81,$81,$81,$81,$81
	.byte $81,$81,$81,$81,$81,$81,$81,$81,$82,$00,$00,$00,$00,$00,$00,$00	; Row 1 of title
	.byte $00,$00,$00,$00,$00,$00,$00,$00,$83,$00,$00,$00,$00,$00,$00,$00
	.byte $00,$00,$00,$00,$00,$00,$00,$00,$84,$00,$00,$00,$00,$00,$00,$00	; Row 2 of title
	.byte $00,$00,$00,$00,$00,$00,$00,$00,$83,$00,$00,$00,$00,$00,$00,$00
	.byte $00,$00,$00,$00,$00,$00,$00,$00,$84,$00,$00,$00,$00,$00,$00,$00	; Row 3 of title
	.byte $00,$00,$00,$00,$00,$00,$00,$00,$83,$00,$00,$00,$00,$00,$00,$00
	.byte $00,$00,$00,$00,$00,$00,$00,$00,$84,$00,$00,$00,$00,$00,$00,$00	; Row 4 of title
	.byte $00,$00,$00,$00,$00,$00,$00,$00,$85,$86,$86,$86,$86,$86,$86,$86
	.byte $86,$86,$86,$86,$86,$86,$86,$86,$87				; Row 5 of title

MENUPALS:
	.byte $0F,$30,$10,$00	; BG palette 0
	.byte $0F,$2C,$21,$11	; BG palette 1
	.byte $0F,$13,$10,$00	; BG palette 2
	.byte $0F,$30,$10,$00	; BG palette 3

	.byte $0F,$13,$10,$00	; SPR palette 0
	.byte $0F,$30,$10,$00	; SPR palette 1
	.byte $0F,$30,$10,$00	; SPR palette 2
	.byte $0F,$11,$16,$10	; SPR palette 3

MENUTEXT:
	.byte "BOILER PLATE!"

MENUTEXT1:
	.byte "New game"

MENUTEXT2:
	.byte "Continue"

MENUTEXT3:
	.byte "Options"

.segment "MENUS"
.proc MAINMENU
	LDA MENUDRAWN
	BEQ DRAW
	JMP RETURNTOMENU
DRAW:
	LDA #REND_DIS
	STA SPREN
	STA BGEN
	LDA #REND_CROP_DIS
	STA BGNOCROP
	STA SPRNOCROP
	JSR UPDATEPPUMASK	; Disable rendering

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

	LDA #$21
	STA PPUCADDR
	LDA #$00
	STA PPUCADDR+1
	LDA #0
	STA PPUCLEN
	LDA #153
	STA PPUCLEN+1
	LDA #<MENUBG
	STA PPUCINPUT
	LDA #>MENUBG
	STA PPUCINPUT+1
	JSR PPUCOPY		; Load title BG tiles into PPU

	LDA #$21
	STA PPUCADDR
	LDA #$4A
	STA PPUCADDR+1
	LDA #0
	STA PPUCLEN
	LDA #13
	STA PPUCLEN+1
	LDA #<MENUTEXT
	STA PPUCINPUT
	LDA #>MENUTEXT
	STA PPUCINPUT+1
	JSR PPUCOPY		; Load title BG text into PPU

	LDA #$22
	STA PPUCADDR
	LDA #$8D
	STA PPUCADDR+1
	LDA #0
	STA PPUCLEN
	LDA #7
	STA PPUCLEN+1
	LDA #<MENUTEXT3
	STA PPUCINPUT
	LDA #>MENUTEXT3
	STA PPUCINPUT+1
	JSR PPUCOPY		; Load menu options BG text into PPU

	LDA #$23
	STA PPUCADDR
	LDA #$C0
	STA PPUCADDR+1
	LDA #0
	STA PPUCLEN
	LDA #64
	STA PPUCLEN+1
	LDA #<MENUATTR
	STA PPUCINPUT
	LDA #>MENUATTR
	STA PPUCINPUT+1
	JSR PPUCOPY		; Load menu BG attributes into PPU

	LDA #1
	STA MENUDRAWN
RETURNTOMENU:
	; We return here from the options screen since the main menu screen should already be
	; drawn from the initial startup
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
	; Test the PRG RAM for valid data
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
	;; TODO - additional tests here?
SRAMTESTFAIL:
	; We failed a test, wipe PRG RAM
	JSR SHOWERRORICON	; Show the error icon
	JSR SRAMWIPE		; Wipe PRG RAM
SRAMTESTDONE:
	; We passed all tests, or working with a freshly initialized PRG RAM
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
	; We skipped the tests
	LDX NMITRANSFERS

	LDA #$22
	STA NMIPPUCADDRH, X
	LDA #$4D
	STA NMIPPUCADDRL, X

	LDA #0
	STA NMIPPUCLENH, X
	LDA #8
	STA NMIPPUCLENL, X

	LDA CONTINUELEVEL
	BNE CONTINUE
	LDA #<MENUTEXT1
	STA NMIPPUCINPUTH, X
	LDA #>MENUTEXT1
	STA NMIPPUCINPUTL, X
	JMP OUT
CONTINUE:
	LDA #<MENUTEXT2
	STA NMIPPUCINPUTH, X
	LDA #>MENUTEXT2
	STA NMIPPUCINPUTL, X
OUT:
	INX
	STX NMITRANSFERS	; Load menu new game / continue text into PPU during NMI

	; TODO - drawing a sprite like this is ugly but works for now
	LDA #$58
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
	LDA JOY1IN
	BNE DOWN
	JMP DONE		; Skip loop if player 1 is not pressing buttons

DOWN:
	LDA JOY1IN
	AND #BUTTON_DOWN	; Check if player 1 is pressing down
	BEQ UP
	LDA ARROWY
	CMP #$90		; Check if the cursor is in the top position
	BNE MENUDOUT
	LDA #$A0
	STA ARROWY		; Move cursor down
MENUDOUT:
	JMP DONE

UP:
	LDA JOY1IN
	AND #BUTTON_UP		; Check if player 1 is pressing up
	BEQ STNEW
	LDA ARROWY
	CMP #$A0		; Check if the cursor is in the bottom position
	BNE MENUUOUT
	LDA #$90
	STA ARROWY		; Move cursor up
MENUUOUT:
	JMP DONE

STNEW:
	LDA JOY1IN
	AND #BUTTON_START	; Check if player 1 is pressing start
	BEQ DONE
	LDA ARROWY
	CMP #$90		; Check if the cursor is in the top position
	BNE STOPTS
;	JSR pause_song		; Stop music
	JSR CLEARSCREEN		; Clear screen
	LDA #0
	STA MENUDRAWN
	STA OPTIONSDRAWN
	LDA CONTINUELEVEL
	BNE STCONTINUE
	JMP STARTNEWGAME	; Go to new game
STCONTINUE:
	LDA CONTINUELEVEL
	;; TODO - jump to level
	BRK
STOPTS:
	LDA ARROWY
	CMP #$A0		; Check if the cursor is in the bottom position
	BNE DONE
	JSR CLEARSPR		; Clear sprites
	JSR VBWAIT
	JMP OPTIONS		; Go to game options menu

DONE:
	JSR VBWAIT		; Wait for next vblank
	JMP MENULOOP		; Repeat input loop
.endproc
