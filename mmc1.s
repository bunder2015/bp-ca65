;
; MMC1 driver for NES
; Copyright 2011 Damian Yerrick
;
; Copying and distribution of this file, with or without
; modification, are permitted in any medium without royalty provided
; the copyright notice and this notice are preserved in all source
; code copies.  This file is offered as-is, without any warranty.
;

.include "mmc1.inc"
.import NMI, RESET, IRQ

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
