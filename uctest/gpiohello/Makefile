
# We require the toolchain avr-gcc
# from ../../avr_toolchain
#
OBJDIR=obj

OBJ_FILES=main.o diag.o
OBJECTS=$(addprefix $(OBJDIR)/,$(OBJ_FILES))
HEADERS=diag.h

MCU=attiny3217

ELF=$(OBJDIR)/test.elf
HEX=$(OBJDIR)/test.hex

LINKFLAGS=-Os

link: $(OBJECTS) $(HEADERS)
	avr-gcc -mmcu=$(MCU) -o $(ELF) $(OBJECTS) $(LINKFLAGS)
	# see how big it is
	avr-size $(ELF)
	# disassemble, so can see what the compiler did
	avr-objdump -S $(ELF) > $(OBJDIR)/image.asm
	avr-objdump -t $(ELF) > $(OBJDIR)/image.sym
	avr-objdump -t $(ELF) |grep 00 |sort  > $(OBJDIR)/image-sorted.sym
	avr-objcopy -j .text -j .data -j .rodata -O ihex $(ELF) $(HEX)

CFLAGS=-mmcu=$(MCU)  -Os -Wall
$(OBJDIR)/%.o: %.c Makefile $(HEADERS)
	@mkdir -p $(OBJDIR)
	avr-gcc -c $(CFLAGS) -o $@ $<

install: link
	pyupdi.py -d tiny3217 -c /dev/ttyUSB0 -f $(HEX)

clean:
	rm -r obj/
