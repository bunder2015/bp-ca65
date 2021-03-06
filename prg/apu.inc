.ifndef APU_INC
.define APU_INC

.globalzp SOUNDREADY

; I/O addresses
SQ1VOL		= $4000
SQ1SWEEP	= $4001
SQ1LOW		= $4002
SQ1HIGH		= $4003
SQ2VOL		= $4004
SQ2SWEEP	= $4005
SQ2LOW		= $4006
SQ2HIGH		= $4007
TRILINEAR	= $4008
TRILOW		= $400A
TRIHIGH		= $400B
NOISEVOL	= $400C
NOISELOW	= $400E
NOISEHIGH	= $400F
DMCFREQ		= $4010
DMCRAW		= $4011
DMCSTART	= $4012
DMCLENGTH	= $4013
SNDCHAN		= $4015
APUFRAME	= $4017	; Writes

.endif
