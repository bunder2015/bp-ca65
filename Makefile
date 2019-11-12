title = boilerplate
version = 0.0.0
mapperfile = mmc1.cfg

CA65 = ca65
LD65 = ld65

prgfiles = \
prg/bank0.s prg/bank1.s prg/bank2.s prg/bank3.s \
prg/bank4.s prg/bank5.s prg/bank6.s prg/bank7.s \
prg/bank8.s prg/bank9.s prg/bank10.s prg/bank11.s \
prg/bank12.s prg/bank13.s prg/bank14.s prg/bank15.s

incfiles = global.inc mmc1.inc

objlist = main.s mmc1.s $(prgfiles) $(incfiles)

all: bin/$(title).nes

clean:
	-rm bin/*.o $(title).nes

bin/:
	-mkdir bin

bin/$(title).o: bin/ $(objlist)
	$(CA65) -g \
		-t nes \
		-o bin/$(title).o \
		main.s

bin/$(title).nes: bin/$(title).o $(mapperfile)
	$(LD65) -o bin/$(title).nes \
		-C $(mapperfile) \
		--dbgfile bin/$(title).dbg \
		bin/$(title).o
