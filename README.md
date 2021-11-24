# Apple ][ revival

## Useful links

Some of these can be found in the docs folder

 - https://mirrors.apple2.org.za/Apple%20II%20Documentation%20Project/Books/W.%20Gayler%20-%20The%20Apple%20II%20Circuit%20Description.pdf ([repo copy](docs/W.%20Gayler%20-%20The%20Apple%20II%20Circuit%20Description.pdf))
 - https://ia803001.us.archive.org/31/items/understanding_the_apple_ii/understanding_the_apple_ii.pdf (referred by UAII in this doc) ([repo copy](docs/understanding_the_apple_ii.pdf))
 - https://downloads.reactivemicro.com/Apple%20II%20Items/Hardware/II_&_II+/Schematic/ ([repo copy](docs/Apple%20II%20Schematics.pdf))
 - http://www.willegal.net/appleii/appleii-repair.htm


## ROM

 - Current ROM chip : 9316 ([datasheet](docs/ROM9316.pdf))
 - Semi-compatibles: EPROM 2716 and EEPROM 28C16 ([datasheet](docs/2716.pdf))

9316 and 2716 compatibles on all pins except:
 - 18: CS2 on 9316 | /EP on 2716
 - 20: CS1 on 9316 | /G  on 2716
 - 21: CS3 on 9316 | Vpp on 2716

On Apple II, the Chip Select combination of all ROM chips is 010. CS1 (20) and CS3 (21) should be LOW and CS2 (18) should be up on one ROM chip to be enabled. (UAII p. 136)

On 2716, read is done when /EP (pin 18) and /G (pin 20) are LOW, inhibition is when /G (pin 20) is HIGH or standby when /EP is HIGH (like inhibition but consume less power but ). Vpp (pin 21) shoud be always HIGH (and can also be 25V if programming mode).
28C16 EEPROM is fully compatible with 2716.

### Dumps

Using socket adapter described below, I've dumped all the ROM chips present in the Apple ][ to validate them against
binary Apple II ROM image. Dumps are located in `dumprom/` folder.

At first sight:

 - ROM D0 is OK
 - ROM D8 is OK
 - ROM E0 is OK
 - ROM E8 is OK
 - ROM F0 is KO
 - ROM F8 is OK

After further testing, rom F0 doesn't dump the same thing after each read. The rom chip is probably dead, it's a good lead !!

### Socket adapter

With those info we can create our socket adapter.

What need to be considered:
_(In this list, xyz state corespond to pin 18/20/21 state)_

 - Data/adress/voltage pin are ok
 - Pin 21 may received 25V if TL866II is in programmer mode, and thus may destroy the 9316 chip
 - (With a 9316 on TL866II)  In read mode, TL866II will send 001 but 9316 chip expect 100 -> KO
 - (With a 2716 on Apple II) In read mode, Apple II will send 100 but 2716 expect 001 -> KO
 - (With a 2716 on Apple II) In deselect mode, Apple II will send 111 and 2716 expect \*11 to be deselected -> OK
 - (With a 2716 on Apple II) In inhibit mode, Apple II may send 000 but 2716 expect \*11 or 1\*1 to be deselected -> KO
 - The good news is, pin 20 is ok in all mode

So, to make a 9316 on TL866II adapter:
 - In this mode, we will force CS as the correct value, except pin 20 that is correct (we will have deselect support, even if this is not really important)
 - Cut pin 21 and connect dangling port to expected state (LOW, ie port 12)
 - Cut pin 18 and connect dangling port to expected state (HIGH, i.e. port 24)

![](pics/9316_adapt_1.jpg)
![](pics/9316_adapt_2.jpg)
![](pics/9316_adapt_3.jpg)

And to make a 2716 on Apple II adapter:
 - Pin 21 can be forced to high (not doing so will put 2716 in unexpected state)
 - The good news is, pin 20 is ok for all cases
 - Pin 18 should in fact be reversed, this can be done with a NC7S04 (cf. http://www.willegal.net/appleii/appleii-integer.htm)
 - Another solution is to force pin 18 value to pin 20 BUT inhibition won't work (i.e. no language card support)
 - Cut pin 21 and connect dangling port to expected state (HIGH, ie port 24)
 - Cut pin 18 and connect dangling port to port 20

### TL866II+

Minipro is the way to go:
```
yay -S minipro
```

Reading:
```
minipro -p M2716@DIP24 -r out.bin
```

### References

 - UAII (chapter 6, p. 149 for socket adapter)
 - http://www.willegal.net/appleii/appleii-integer.htm
 - 9316 -> 2716 mapping (i.e. to read Apple II rom on TL866II) :  https://www.mikesarcade.com/cgi-bin/spies.cgi?action=url&type=info&page=9316.txt
