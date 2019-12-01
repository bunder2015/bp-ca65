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

# Locations for files used in building
bindir = bin
objdir = obj
srcdir = prg
imgdir = chr

AS65 = ca65 -g
LD65 = ld65 --dbgfile $(bindir)/$(title).dbg -m $(bindir)/map.txt

# Pseudo-targets
.PHONY: clean

all: $(bindir)/ $(objdir)/ $(bindir)/$(title).nes

clean:
	-rm $(objdir)/*.o $(bindir)/$(title).nes $(bindir)/$(title).dbg $(bindir)/map.txt

# Create empty directories for build
$(bindir)/: Makefile
	mkdir -p $(bindir)

$(objdir)/: Makefile
	mkdir -p $(objdir)

# Rules for PRG ROM
objlisto = $(foreach o,$(objlist),$(objdir)/$(o).o)

$(bindir)/map.txt $(bindir)/$(title).nes: mmc1.cfg $(objlisto)
	$(LD65) -o $(bindir)/$(title).nes -C $^

$(objdir)/%.o: $(srcdir)/%.s
	$(AS65) $< -o $@

# Rules for CHR ROM
$(objdir)/nes.o: $(imgdir)/*.chr
