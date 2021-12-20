VASM?=vasm6502_oldstyle
C2T?=c2t
PLAYER?=mpv
OPT?=

%.bin: %.s
	$(VASM) $(OPT) -quiet -Fbin -L $(<:.s=.lst) -o "$@" "$<"

play_%.bin: %.bin
	$(C2T) -2 -w $<,280 | $(PLAYER) - --pause


target = $(patsubst %.s,%.bin,$(wildcard *.s))

all:	$(target)

clean:
	-rm -f $(target)

.PHONY: %.out
