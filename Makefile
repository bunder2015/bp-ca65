#!/usr/bin/make -f
#
# Makefile for NES game
# Copyright 2011-2015 Damian Yerrick
#
# Copying and distribution of this file, with or without
# modification, are permitted in any medium without royalty
# provided the copyright notice and this notice are preserved.
# This file is offered as-is, without any warranty.
#

# This is the title of the NES program.
title = boilerplate

# Space-separated list of assembly language files that make up the
# PRG ROM.  If it gets too long for one line, you can add a backslash
# (the \ character) at the end of the line and continue on the next.
objlist = apu cpu debug joys mainmenu \
mmc1 nes options ppu sram text vectors

AS65 = ca65
LD65 = ld65
objdir = obj/nes
srcdir = prg
imgdir = chr

# Pseudo-targets
.PHONY: clean

all: $(title).nes

clean:
	-rm $(objdir)/*.o $(title).nes $(title).dbg map.txt

# Rules for PRG ROM
objlisto = $(foreach o,$(objlist),$(objdir)/$(o).o)

map.txt $(title).nes: mmc1.cfg $(objlisto)
	$(LD65) --dbgfile $(title).dbg -o $(title).nes -m map.txt -C $^

$(objdir)/%.o: $(srcdir)/%.s
	$(AS65) -g $< -o $@

$(objdir)/nes.o: $(imgdir)/*.chr

