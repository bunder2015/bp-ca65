.ifndef PPU_INC
.define PPU_INC

.globalzp BGEN, BGNOCROP, BGPT, CEMPHB, CEMPHG, CEMPHR, COLOUREN, NMIEN, NMIREADY, NMITRANSFERS, NT, PDINC, PPUCADDR, PPUCINPUT, PPUCLEN, SCROLLX, SCROLLY, SPREN, SPRNOCROP, SPRPT, SPRSZ, WAITFRAMES
.global NMIPPUCADDRH, NMIPPUCADDRL, NMIPPUCINPUTH, NMIPPUCINPUTL, NMIPPUCLENH, NMIPPUCLENL, CLEARSCREEN, CLEARSPR, NMIPPUCOPY, PPUCOPY, RESETSCR, SPRITES, UPDATEPPUCTRL, UPDATEPPUMASK, VBWAIT

; I/O addresses
OAM		= $0200
PPUCTRL		= $2000
PPUMASK 	= $2001
PPUSTATUS	= $2002
OAMADDR		= $2003
OAMDATA		= $2004
PPUSCROLL	= $2005
PPUADDR		= $2006
PPUDATA		= $2007
OAMDMA		= $4014

; PPUCTRL bitfield
NMI_EN		= %10000000
SPR_SZ16	= %00100000
SPR_SZ8		= %00000000
BG_PT1		= %00010000
BG_PT0		= %00000000
SPR_PT1		= %00001000
SPR_PT0		= %00000000
PD_INC32	= %00000100
PD_INC1		= %00000000
NT_SEL3		= %00000011
NT_SEL2		= %00000010
NT_SEL1		= %00000001
NT_SEL0		= %00000000

; PPUMASK bitfield
CLR_EMPH_BLUE	= %10000000
CLR_EMPH_GREEN	= %01000000
CLR_EMPH_RED	= %00100000
CLR_EMPH_NONE	= %00000000
SPR_REND_EN	= %00010000
BG_REND_EN	= %00001000
REND_DIS	= %00000000
SPR_REND_NOCROP	= %00000100
BG_REND_NOCROP	= %00000010
REND_CROP_EN	= %00000000
REND_CROP_DIS	= %00000110
CLR_GRAY	= %00000001
CLR_EN		= %00000000

; OAM attribute bitfield
SPR_FLIP_VERT	= %10000000
SPR_FLIP_HORIZ	= %01000000
SPR_FLIP_NONE	= %00000000
SPR_PRIO_REAR	= %00100000
SPR_PRIO_FRONT	= %00000000
SPR_PALETTE3	= %00000011
SPR_PALETTE2	= %00000010
SPR_PALETTE1	= %00000001
SPR_PALETTE0	= %00000000

.endif
