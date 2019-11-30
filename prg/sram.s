.include "cpu.inc"
.include "sram.inc"

.segment "ZEROPAGE"
STEMP:		.res 2	; SRAMWIPE temp variable

.segment "SRAMD"
SRAMCONTINUE:	.res 1	; Highest level achieved
SRAMMUSIC:	.res 1	; Music toggle

.segment "SRAMF"
SRAMFOOTER:	.res 16	; SRAM footer

.segment "SRAMH"
SRAMHEADER:	.res 16	; SRAM header

.segment "FUNCD"
SRAMFOOTERTEXT:	.byte "DISCOMBOBULATION"
SRAMHEADERTEXT:	.byte "THERMOTELEPHONIC"

.segment "FUNCS"
.proc SRAMTESTA
	;; Verifies the PRG RAM header and footer, returns 1 on success
	;; Input: none
	;; Clobbers: A Y
	LDY #$00
L1:
	LDA SRAMHEADERTEXT, Y
	CMP SRAMHEADER, Y
	BNE BAD
	INY
	CPY #16
	BNE L1

	LDY #0
L2:
	LDA SRAMFOOTERTEXT, Y
	CMP SRAMFOOTER, Y
	BNE BAD
	INY
	CPY #16
	BNE L2

	LDA #1
	RTS
BAD:
	LDA #0
	RTS
.endproc

.proc SRAMTESTC
	;; Verifies the PRG RAM option variable bounds, returns 1 on success
	;; Input: none
	;; Clobbers: A
	LDA SRAMMUSIC
	CMP #2			; SRAMMUSIC range is 0-1
	BCS BAD			; Carry will be set if higher than 1
	LDA SRAMCONTINUE
	BNE BAD			; SRAMCONTINUE range is 0, anything else is nonzero
	LDA #1
	RTS
BAD:
	LDA #0
	RTS
.endproc

.proc SRAMWIPE
	;; Wipes the PRG RAM located at $6000-7FFF and places a new header/footer
	;; Input: none
	;; Clobbers: A X Y
	LDA #$00
	STA STEMP
	LDA #$60
	STA STEMP+1		; Set STEMP to $6000

	LDA #$00
	TAX
	TAY			; Clear A/X/Y
L1:
	STA (STEMP), Y
	INY
	BNE L1			; Wipe PRG RAM

	INC STEMP+1
	INX
	CPX #$20
	BNE L1

	LDA #$00
	STA CPUCADDR
	LDA #$60
	STA CPUCADDR+1
	LDA #0
	STA CPUCLEN
	LDA #16
	STA CPUCLEN+1
	LDA #<SRAMHEADERTEXT
	STA CPUCINPUT
	LDA #>SRAMHEADERTEXT
	STA CPUCINPUT+1
	JSR CPUCOPY		; Write header to PRG RAM

	LDA #$F0
	STA CPUCADDR
	LDA #$7F
	STA CPUCADDR+1
	LDA #0
	STA CPUCLEN
	LDA #16
	STA CPUCLEN+1
	LDA #<SRAMFOOTERTEXT
	STA <CPUCINPUT
	LDA #>SRAMFOOTERTEXT
	STA CPUCINPUT+1
	JSR CPUCOPY		; Write footer to PRG RAM

	LDA #1
	STA SRAMMUSIC		; Set the default music value

	RTS
.endproc
