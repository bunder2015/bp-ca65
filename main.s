;;; main asm file

.include "global.inc"
.include "mmc1.inc"

.include "nes2header.inc"
nes2mapper 1
nes2prg 16 * 16384
nes2chr 16 * 8192
nes2bram 1 * 8192
nes2mirror 'V'
nes2tv 'N'
nes2end

.segment "ZEROPAGE"
; zp vars here

.segment "BSS"
; bss vars here

.segment "SAVERAM"
; sram vars here

.segment "OAM"
; oam here

.segment "PATTERN0"
.incbin "chr/bank0.chr"

.segment "PATTERN1"
.incbin "chr/bank1.chr"

.segment "PATTERN2"
.incbin "chr/bank2.chr"

.segment "PATTERN3"
.incbin "chr/bank3.chr"

.segment "PATTERN4"
.incbin "chr/bank4.chr"

.segment "PATTERN5"
.incbin "chr/bank5.chr"

.segment "PATTERN6"
.incbin "chr/bank6.chr"

.segment "PATTERN7"
.incbin "chr/bank7.chr"

.segment "PATTERN8"
.incbin "chr/bank8.chr"

.segment "PATTERN9"
.incbin "chr/bank9.chr"

.segment "PATTERN10"
.incbin "chr/bank10.chr"

.segment "PATTERN11"
.incbin "chr/bank11.chr"

.segment "PATTERN12"
.incbin "chr/bank12.chr"

.segment "PATTERN13"
.incbin "chr/bank13.chr"

.segment "PATTERN14"
.incbin "chr/bank14.chr"

.segment "PATTERN15"
.incbin "chr/bank15.chr"
