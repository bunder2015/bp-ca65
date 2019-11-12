.include "../global.inc"

.segment "PAGE15"

.proc NMI
	RTI
.endproc

.proc RESET
	JMP MAIN
.endproc

.proc IRQ
	RTI
.endproc
