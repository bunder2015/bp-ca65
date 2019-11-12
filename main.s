;;; main asm file

.include "global.inc"
.include "mmc1.inc"

OAM = $0200

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
