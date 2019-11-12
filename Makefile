title = boilerplate
version = 0.0.0
mapperfile = mmc1.cfg

CA65 = ca65
LD65 = ld65

objlist = main mmc1 \
bank0 bank1 bank2 bank3 \
bank4 bank5 bank6 bank7 \
bank8 bank9 bank10 bank11 \
bank12 bank13 bank14 bank15

chrfiles = bank0 bank1 bank2 bank3 \
bank4 bank5 bank6 bank7 \
bank8 bank9 bank10 bank11 \
bank12 bank13 bank14 bank15

incfiles = global.inc mmc1.inc

.PHONY: clean

all: bin/$(title).nes

clean:
	-rm bin/*.o bin/$(title).nes bin/$(title).dbg bin/map.txt

bin/:
	-mkdir bin

objlisto = $(foreach o,$(objlist),bin/$(o).o)

bin/map.txt bin/$(title).nes: $(mapperfile) $(objlisto)
	ld65 --dbgfile bin/$(title).dbg -m bin/map.txt -o bin/$(title).nes -C $^

chrlist = $(foreach c,$(chrfiles),chr/$(c).chr)

bin/main.o: main.s $(incfiles) $(chrlist)
	ca65 -g $< -o $@

bin/%.o: %.s $(incfiles)
	ca65 -g $< -o $@

bin/%.o: prg/%.s $(incfiles)
	ca65 -g $< -o $@
