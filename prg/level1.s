.include "level1.inc"
.include "ppu.inc"

.segment "LVL1D"
; TODO - put data here

.segment "LVL1S"
.proc NEWGAME
	LDA #REND_DIS
	STA SPREN
	STA BGEN
	JSR UPDATEPPUMASK	; Disable rendering

	;; TODO - Display new game start

	LDA #BG_PT0
	STA BGPT		; Select BG pattern table 0
	LDA #SPR_PT1
	STA SPRPT		; Select sprite pattern table 1
	LDA #NT_SEL0
	STA NT			; Select nametable 0
	JSR UPDATEPPUCTRL	; Update PPU controls

	JSR VBWAIT		; Wait for next vblank
	JMP STARTLOOP		; Enter input loop
.endproc

.proc STARTLOOP
	;; TODO - Input
	BRK

DONE:
	JSR VBWAIT		; Wait for next vblank
	JMP STARTLOOP
.endproc
