VASM?=vasm6502_oldstyle
C2T?=c2t
PLAYER?=mpv
OPT?=

%.bin: %.s
	$(VASM) $(OPT) -quiet -Fbin -o "$@" "$<"

play_%.bin: %.bin
	$(C2T) -2 -p $<,2a0 | $(PLAYER) - --pause


target = $(patsubst %.s,%.bin,$(wildcard *.s))

all:	$(target)

clean:
	-rm -f $(target)

.PHONY: %.out
